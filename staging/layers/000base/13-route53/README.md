# Route53 Public Hosted Zone

This Terraform configuration manages the Route53 public hosted zone for `staging.abaxx.exchange` and automatically creates DNS validation records for SES and ACM by reading their remote states.

## Architecture

This layer depends on:
- **09-ses**: Reads SES domain identities and DKIM tokens
- **12-acm**: Reads ACM certificate validation records

The DNS validation records are automatically created in Route53 based on the outputs from these layers.

## Resources Created

### Route53 Hosted Zone
- **aws_route53_zone.staging_abaxx_exchange**: Public hosted zone for staging.abaxx.exchange

### SES Validation Records (from 09-ses)
- **aws_route53_record.ses_verification**: TXT record for SES domain verification (`_amazonses.staging.abaxx.exchange`)
- **aws_route53_record.ses_dkim**: CNAME records for DKIM authentication (3 records)

### ACM Validation Records (from 12-acm)
- **aws_route53_record.acm_validation**: CNAME records for ACM certificate validation (us-east-1 and ap-southeast-1)

## Deployment Order

**IMPORTANT**: You must deploy layers in this order:

1. **First**: Deploy `09-ses` to create SES domain identities
2. **Second**: Deploy `12-acm` to create ACM certificates
3. **Third**: Deploy `13-route53` to create the hosted zone and all validation records
4. **Fourth**: Configure NS delegation at parent domain (see below)

## Outputs

### Route53 Hosted Zone Outputs

#### `staging_abaxx_exchange_zone_id`
The Route53 hosted zone ID for staging.abaxx.exchange. Use this when creating DNS records.

```hcl
data "terraform_remote_state" "route53" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/13-route53/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Use the zone ID
zone_id = data.terraform_remote_state.route53.outputs.staging_abaxx_exchange_zone_id
```

#### `staging_abaxx_exchange_name_servers`
List of AWS name servers for this hosted zone. These need to be configured at your domain registrar or parent DNS zone.

**Example value:**
```
[
  "ns-1234.awsdns-56.org",
  "ns-789.awsdns-12.com",
  "ns-345.awsdns-67.net",
  "ns-890.awsdns-34.co.uk"
]
```

#### `staging_abaxx_exchange_zone`
The full Route53 hosted zone resource object with all attributes.

### Validation Records Outputs

#### `ses_verification_records`
SES domain verification TXT records created in Route53.

#### `ses_dkim_records`
SES DKIM CNAME records created in Route53 (3 records for email authentication).

#### `acm_validation_records`
ACM certificate validation CNAME records created in Route53.

## Setup Instructions

### 1. Deploy Prerequisites

Ensure the following layers are deployed first:

```bash
# Deploy SES configuration
cd layers/000base/09-ses
terraform init
terraform plan
terraform apply

# Deploy ACM certificates
cd ../12-acm
terraform init
terraform plan
terraform apply
```

### 2. Deploy Route53

```bash
cd layers/000base/13-route53
terraform init
terraform plan
terraform apply
```

This will:
- Create the hosted zone for staging.abaxx.exchange
- Automatically create SES verification records
- Automatically create ACM validation records

### 3. Configure NS Delegation at Parent Domain

After creating the hosted zone, you need to delegate the subdomain from the parent domain.

**Get the name servers:**
```bash
terraform output staging_abaxx_exchange_name_servers
```

**Option A: If abaxx.exchange is in Route53**

In the abaxx.exchange hosted zone, create an NS record:

```hcl
resource "aws_route53_record" "staging_delegation" {
  zone_id = aws_route53_zone.abaxx_exchange.zone_id  # Parent zone
  name    = "staging.abaxx.exchange"
  type    = "NS"
  ttl     = 300
  records = data.terraform_remote_state.route53.outputs.staging_abaxx_exchange_name_servers
}
```

**Option B: If abaxx.exchange is in Cloudflare**

In your Cloudflare Terraform configuration:

```hcl
data "terraform_remote_state" "route53" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/13-route53/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

resource "cloudflare_record" "staging_ns" {
  for_each = toset(data.terraform_remote_state.route53.outputs.staging_abaxx_exchange_name_servers)

  zone_id = var.cloudflare_zone_id  # For abaxx.exchange
  name    = "staging"
  type    = "NS"
  value   = each.value
  ttl     = 300
}
```

**Option C: Manual Configuration**

Add 4 NS records in your parent domain (abaxx.exchange):
- Name: `staging`
- Type: `NS`
- Values: (the 4 name servers from the output)

### 4. Verify DNS Propagation

After configuring the NS records, verify:

```bash
# Check NS delegation
dig NS staging.abaxx.exchange

# Check SES verification record
dig TXT _amazonses.staging.abaxx.exchange

# Check ACM validation records
dig CNAME _<validation-hash>.staging.abaxx.exchange

# Verify SES domain status
aws ses get-identity-verification-attributes --identities staging.abaxx.exchange

# Check ACM certificate status
aws acm describe-certificate --certificate-arn <cert-arn> --region us-east-1
aws acm describe-certificate --certificate-arn <cert-arn> --region ap-southeast-1
```

## Using This Zone in Other Terraform Configurations

### Creating Additional DNS Records

```hcl
data "terraform_remote_state" "route53" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/13-route53/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Example: Create an A record
resource "aws_route53_record" "app" {
  zone_id = data.terraform_remote_state.route53.outputs.staging_abaxx_exchange_zone_id
  name    = "app.staging.abaxx.exchange"
  type    = "A"
  ttl     = 300
  records = ["1.2.3.4"]
}

# Example: Create an alias record for ALB
resource "aws_route53_record" "alb" {
  zone_id = data.terraform_remote_state.route53.outputs.staging_abaxx_exchange_zone_id
  name    = "api.staging.abaxx.exchange"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
```

## File Structure

```
13-route53/
├── backend.tf              # S3 backend configuration
├── main.tf                 # Route53 hosted zone
├── remote_state.tf         # Remote state data sources for SES and ACM
├── ses_validation.tf       # SES domain verification and DKIM records
├── acm_validation.tf       # ACM certificate validation records
├── outputs.tf              # All outputs
├── version.tf              # Terraform and provider versions
└── README.md               # This file
```

## Automatic Validation

Once this layer is deployed and NS delegation is configured:

1. **SES Domain Verification**: AWS SES will automatically verify the domain within a few minutes
2. **SES DKIM**: DKIM authentication will be enabled automatically
3. **ACM Certificates**: ACM will automatically validate and issue certificates (both us-east-1 and ap-southeast-1)

No manual intervention required for validation records!

## Troubleshooting

### SES Not Verifying
```bash
# Check if verification record exists
dig TXT _amazonses.staging.abaxx.exchange

# Check SES status
aws ses get-identity-verification-attributes --identities staging.abaxx.exchange
```

### ACM Not Validating
```bash
# Check if validation records exist
aws route53 list-resource-record-sets --hosted-zone-id <zone-id> | grep -A 5 "_acm"

# Check ACM certificate status
aws acm describe-certificate --certificate-arn <cert-arn> --region us-east-1
```

### DNS Not Resolving
```bash
# Verify NS delegation is working
dig NS staging.abaxx.exchange @8.8.8.8

# Check if AWS name servers respond
dig NS staging.abaxx.exchange @<one-of-the-aws-nameservers>
```

## Notes

- The hosted zone is public and will be visible on the internet
- DNS changes typically propagate within minutes, but can take up to 48 hours
- SES and ACM validation records are managed automatically from their respective layers
- All validation records use TTL of 300 seconds (5 minutes) for faster propagation
- ACM validation records use `allow_overwrite = true` to handle duplicate records across regions
