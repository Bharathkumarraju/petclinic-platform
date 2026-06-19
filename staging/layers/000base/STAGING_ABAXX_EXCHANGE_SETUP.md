# staging.abaxx.exchange Infrastructure Setup

Complete setup guide for the staging.abaxx.exchange domain including Route53, SES, and ACM.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Parent Domain                             │
│                  abaxx.exchange                              │
│              (Cloudflare or Route53)                         │
│                                                              │
│  NS Delegation: staging → AWS Route53                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              13-route53 (Route53 Layer)                      │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Route53 Hosted Zone                                  │  │
│  │  staging.abaxx.exchange                               │  │
│  │                                                        │  │
│  │  Reads remote state from:                             │  │
│  │  • 09-ses (SES identities & DKIM)                     │  │
│  │  • 12-acm (Certificate validation)                    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  Auto-created DNS Records:                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ SES Validation Records                                │  │
│  │ • _amazonses.staging.abaxx.exchange (TXT)             │  │
│  │ • <token1>._domainkey.staging.abaxx.exchange (CNAME)  │  │
│  │ • <token2>._domainkey.staging.abaxx.exchange (CNAME)  │  │
│  │ • <token3>._domainkey.staging.abaxx.exchange (CNAME)  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ ACM Validation Records                                │  │
│  │ • _<hash>.staging.abaxx.exchange (CNAME)              │  │
│  │   (for both us-east-1 and ap-southeast-1)             │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
         ▲                           ▲
         │                           │
┌────────┴────────┐       ┌──────────┴──────────┐
│   09-ses        │       │     12-acm          │
│                 │       │                     │
│ • SES Domain    │       │ • ACM Certificate   │
│   Identity      │       │   (us-east-1)       │
│ • DKIM Tokens   │       │ • ACM Certificate   │
│                 │       │   (ap-southeast-1)  │
└─────────────────┘       └─────────────────────┘
```

## Deployment Steps

### Prerequisites

Ensure you have:
- AWS credentials configured
- Terraform 1.14.x installed
- Access to the parent domain (abaxx.exchange) for NS delegation

### Step 1: Deploy SES (09-ses)

```bash
cd layers/000base/09-ses

# Verify the domain is configured
grep -A 3 "ses_domains" locals.tf
# Should include "staging.abaxx.exchange"

terraform init
terraform plan
terraform apply
```

**What this creates:**
- SES domain identity for staging.abaxx.exchange
- DKIM configuration for email authentication
- SES configuration set for logging to S3
- Outputs: verification token and DKIM tokens

### Step 2: Deploy ACM (12-acm)

```bash
cd ../12-acm

# Verify ACM certificates are configured
grep -A 5 "staging_abaxx_exchange" main.tf

terraform init
terraform plan
terraform apply
```

**What this creates:**
- ACM certificate in us-east-1 (for CloudFront)
  - Domain: staging.abaxx.exchange
  - SAN: *.staging.abaxx.exchange
- ACM certificate in ap-southeast-1 (for regional resources)
  - Domain: staging.abaxx.exchange
  - SAN: *.staging.abaxx.exchange
- Outputs: validation records for DNS

### Step 3: Deploy Route53 (13-route53)

```bash
cd ../13-route53

terraform init
terraform plan
# Review: Should show creation of hosted zone + SES + ACM validation records
terraform apply
```

**What this creates:**
- Route53 public hosted zone for staging.abaxx.exchange
- SES verification TXT record (reads from 09-ses state)
- SES DKIM CNAME records (3 records, reads from 09-ses state)
- ACM validation CNAME records (reads from 12-acm state)
- Outputs: zone ID and name servers

### Step 4: Configure NS Delegation

**Get the name servers:**
```bash
cd layers/000base/13-route53
terraform output staging_abaxx_exchange_name_servers
```

You'll get 4 AWS name servers like:
```
[
  "ns-1234.awsdns-56.org",
  "ns-789.awsdns-12.com",
  "ns-345.awsdns-67.net",
  "ns-890.awsdns-34.co.uk"
]
```

**Configure delegation at parent domain:**

#### Option A: Parent domain in Cloudflare

In your Cloudflare Terraform:

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

  zone_id = var.cloudflare_zone_id  # abaxx.exchange zone
  name    = "staging"
  type    = "NS"
  value   = each.value
  ttl     = 300
}
```

#### Option B: Manual configuration

In your DNS provider for abaxx.exchange, add 4 NS records:
- Name: `staging`
- Type: `NS`
- TTL: 300
- Values: (paste each of the 4 name servers)

### Step 5: Verify Everything

```bash
# Wait 2-5 minutes for DNS propagation

# Check NS delegation
dig NS staging.abaxx.exchange
# Should return the 4 AWS name servers

# Check SES verification record
dig TXT _amazonses.staging.abaxx.exchange
# Should return the verification token

# Check DKIM records
dig CNAME $(terraform output -json ses_dkim_records | jq -r 'keys[0]')
# Should return CNAME to .dkim.amazonses.com

# Verify SES domain status
aws ses get-identity-verification-attributes \
  --identities staging.abaxx.exchange \
  --region ap-southeast-1
# Status should be "Success"

# Check ACM certificates
aws acm describe-certificate \
  --certificate-arn $(terraform output -json | jq -r '.acm_validation_records.value | keys[0]') \
  --region us-east-1
# Status should be "ISSUED"
```

## Layer Dependencies

```
09-ses (SES)
  ↓
12-acm (ACM)
  ↓
13-route53 (Route53 + DNS Records)
  ↓
NS Delegation at Parent Domain
  ↓
Automatic Validation (SES + ACM)
```

## What Gets Validated Automatically

Once NS delegation is configured and DNS propagates:

1. **SES Domain Verification** (~5-10 minutes)
   - AWS SES reads the TXT record at `_amazonses.staging.abaxx.exchange`
   - Domain status changes to "Verified"
   - You can now send emails from @staging.abaxx.exchange

2. **SES DKIM** (~5-10 minutes)
   - AWS SES reads the 3 CNAME records
   - DKIM status changes to "Success"
   - Emails will have DKIM signatures for better deliverability

3. **ACM Certificates** (~5-10 minutes)
   - ACM reads the validation CNAME records
   - Certificate status changes to "ISSUED"
   - Certificates in both us-east-1 and ap-southeast-1 are ready

## Using the Infrastructure

### Using the Route53 Zone

```hcl
data "terraform_remote_state" "route53" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/13-route53/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# Create DNS records
resource "aws_route53_record" "app" {
  zone_id = data.terraform_remote_state.route53.outputs.staging_abaxx_exchange_zone_id
  name    = "app.staging.abaxx.exchange"
  type    = "A"
  ttl     = 300
  records = ["1.2.3.4"]
}
```

### Using SES

```bash
# Send a test email
aws ses send-email \
  --from "noreply@staging.abaxx.exchange" \
  --destination "ToAddresses=test@example.com" \
  --message "Subject={Data=Test},Body={Text={Data=Hello}}" \
  --region ap-southeast-1
```

### Using ACM Certificates

```hcl
# For CloudFront (must use us-east-1)
data "terraform_remote_state" "acm" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/12-acm/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  # ...
  viewer_certificate {
    acm_certificate_arn = data.terraform_remote_state.acm.outputs.staging_abaxx_exchange_acm_us_east_1[0].arn
  }
}

# For ALB in ap-southeast-1
resource "aws_lb_listener" "https" {
  # ...
  certificate_arn = data.terraform_remote_state.acm.outputs.staging_abaxx_exchange_acm_ap_southeast_1[0].arn
}
```

## Terraform State Files

```
s3://abaxx-exch-tf-state-nonprod/
├── abaxxsingapore/
│   └── abex-aws-env-staging/
│       └── layers/
│           └── 000base/
│               ├── 09-ses/terraform.tfstate
│               ├── 12-acm/terraform.tfstate
│               └── 13-route53/terraform.tfstate
```

## Outputs Available

### From 09-ses
- `ses_domain_identities` - Domain verification tokens
- `ses_domain_dkim_tokens` - DKIM tokens
- `ses_dns_records` - Formatted DNS records

### From 12-acm
- `staging_abaxx_exchange_acm_us_east_1` - Certificate validation options (us-east-1)
- `staging_abaxx_exchange_acm_ap_southeast_1` - Certificate validation options (ap-southeast-1)

### From 13-route53
- `staging_abaxx_exchange_zone_id` - Hosted zone ID
- `staging_abaxx_exchange_name_servers` - Name servers for NS delegation
- `ses_verification_records` - Created SES TXT records
- `ses_dkim_records` - Created DKIM CNAME records
- `acm_validation_records` - Created ACM validation records

## Troubleshooting

### SES Not Verifying

```bash
# Check DNS record exists
dig TXT _amazonses.staging.abaxx.exchange

# Check SES status
aws ses get-identity-verification-attributes \
  --identities staging.abaxx.exchange \
  --region ap-southeast-1

# If pending, wait 5-10 minutes after NS delegation
```

### ACM Not Validating

```bash
# Check validation records exist
aws route53 list-resource-record-sets \
  --hosted-zone-id $(cd layers/000base/13-route53 && terraform output -raw staging_abaxx_exchange_zone_id)

# Check certificate status
aws acm list-certificates --region us-east-1
aws acm list-certificates --region ap-southeast-1

# If pending, wait 5-10 minutes after NS delegation
```

### DNS Not Resolving

```bash
# Check if NS delegation is working
dig NS staging.abaxx.exchange @8.8.8.8

# If not showing AWS name servers, check parent domain configuration
# DNS changes can take up to 48 hours but usually < 5 minutes with Cloudflare
```

## Maintenance

### Adding More Domains to SES

Edit `layers/000base/09-ses/locals.tf`:

```hcl
ses_domains = [
  "staging.abaxx.exchange",
  "anotherdomain.com",  # Add new domain
]
```

Then:
1. Apply 09-ses
2. Apply 13-route53 (will create records for staging.abaxx.exchange only)
3. Manually create DNS records for other domains in their respective zones

### Updating ACM Certificates

To add more SANs to the certificate, edit `layers/000base/12-acm/main.tf`:

```hcl
subject_alternative_names = [
  "*.staging.abaxx.exchange",
  "new-subdomain.staging.abaxx.exchange",  # Add new SAN
]
```

Then:
1. Apply 12-acm (creates new validation records)
2. Apply 13-route53 (automatically creates new validation records)

## Security Notes

- The Route53 zone is public (required for DNS)
- SES is in sandbox mode by default (requires AWS support ticket to remove)
- ACM certificates auto-renew before expiry
- DKIM keys are managed by AWS (automatic rotation)
- DNS records have 300s TTL for faster updates

## Cost Considerations

- Route53 hosted zone: $0.50/month
- Route53 queries: $0.40 per million queries (first 1B)
- SES: $0.10 per 1,000 emails sent
- ACM certificates: Free
- No charge for DNS validation records

## Next Steps

After setup is complete:

1. ✅ Create application DNS records in the zone
2. ✅ Configure SES sending policies and limits
3. ✅ Set up SES suppression list
4. ✅ Configure SES notifications (bounces, complaints)
5. ✅ Use ACM certificates in CloudFront/ALB/API Gateway
6. ✅ Monitor SES reputation metrics
7. ✅ Request SES production access if needed
