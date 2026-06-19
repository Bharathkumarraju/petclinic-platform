# SES Domain Verification

This document explains how to use the SES domain identity outputs from this Terraform state.

## ⚠️ IMPORTANT: Route53 Integration

**For `staging.abaxx.exchange`**: The DNS validation records are automatically created in the [13-route53](../13-route53/) layer. You don't need to create them manually in Cloudflare or elsewhere.

**For other domains** (not in Route53): Use the instructions below to create validation records in Cloudflare or other DNS providers.

## Configuration in this Repository (AWS SES)

### 1. Add your domains to the `ses_domains` list in `locals.tf`:

```hcl
ses_domains = [
  "example.com",
  "mail.example.com",
]
```

### 2. Apply the Terraform configuration:

```bash
terraform init
terraform plan
terraform apply
```

## Using Outputs in Cloudflare Terraform Repository

### Reading the Remote State

In your Cloudflare Terraform repository, add a remote state data source:

```hcl
data "terraform_remote_state" "ses" {
  backend = "s3"
  config = {
    bucket = "abaxx-exch-tf-state-nonprod"
    key    = "abaxxsingapore/abex-aws-env-staging/layers/000base/09-ses/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
```

### Creating Cloudflare DNS Records

#### Option 1: Using the structured `ses_dns_records` output (Recommended)

```hcl
locals {
  # Extract all DNS records from SES output
  ses_dns_records = data.terraform_remote_state.ses.outputs.ses_dns_records
}

# Create TXT records for domain verification
resource "cloudflare_record" "ses_verification" {
  for_each = local.ses_dns_records

  zone_id = var.cloudflare_zone_id
  name    = each.value.verification_record.name
  type    = each.value.verification_record.type
  value   = each.value.verification_record.value
  ttl     = 300
}

# Create CNAME records for DKIM
resource "cloudflare_record" "ses_dkim" {
  for_each = merge([
    for domain, records in local.ses_dns_records : {
      for idx, dkim in records.dkim_records : "${domain}-dkim-${idx}" => {
        domain = domain
        name   = dkim.name
        value  = dkim.value
      }
    }
  ]...)

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = "CNAME"
  value   = each.value.value
  ttl     = 300
}
```

#### Option 2: Using individual outputs

```hcl
# Get domain identities
locals {
  ses_identities = data.terraform_remote_state.ses.outputs.ses_domain_identities
  ses_dkim       = data.terraform_remote_state.ses.outputs.ses_domain_dkim_tokens
}

# Create verification TXT records
resource "cloudflare_record" "ses_verification" {
  for_each = local.ses_identities

  zone_id = var.cloudflare_zone_id
  name    = "_amazonses.${each.value.domain}"
  type    = "TXT"
  value   = each.value.verification_token
  ttl     = 300
}

# Create DKIM CNAME records
resource "cloudflare_record" "ses_dkim" {
  for_each = merge([
    for domain, dkim_data in local.ses_dkim : {
      for idx, token in dkim_data.dkim_tokens : "${domain}-${idx}" => {
        domain = domain
        token  = token
      }
    }
  ]...)

  zone_id = var.cloudflare_zone_id
  name    = "${each.value.token}._domainkey.${each.value.domain}"
  type    = "CNAME"
  value   = "${each.value.token}.dkim.amazonses.com"
  ttl     = 300
}
```

## Available Outputs

### `ses_domain_identities`
Contains domain identity information including verification tokens:
```hcl
{
  "example.com" = {
    domain             = "example.com"
    arn                = "arn:aws:ses:ap-southeast-1:..."
    verification_token = "abc123..."
  }
}
```

### `ses_domain_dkim_tokens`
Contains DKIM tokens for each domain:
```hcl
{
  "example.com" = {
    domain      = "example.com"
    dkim_tokens = ["token1", "token2", "token3"]
  }
}
```

### `ses_dns_records` (Recommended)
Pre-formatted DNS records ready for Cloudflare:
```hcl
{
  "example.com" = {
    verification_record = {
      type  = "TXT"
      name  = "_amazonses.example.com"
      value = "abc123..."
    }
    dkim_records = [
      {
        type  = "CNAME"
        name  = "token1._domainkey.example.com"
        value = "token1.dkim.amazonses.com"
      },
      # ... 2 more DKIM records
    ]
  }
}
```

## DNS Records Explained

### 1. Domain Verification TXT Record
- **Purpose**: Proves you own the domain to AWS SES
- **Format**: `_amazonses.yourdomain.com` TXT record
- **Required**: Yes, for sending emails

### 2. DKIM CNAME Records (3 records)
- **Purpose**: Email authentication to prevent spoofing
- **Format**: `<token>._domainkey.yourdomain.com` CNAME records
- **Required**: Highly recommended for deliverability

### 3. MX Record (Optional, create manually if needed)
- **Purpose**: If you want to receive emails via SES
- **Format**: `yourdomain.com` MX record pointing to `inbound-smtp.region.amazonaws.com`
- **Required**: Only if receiving emails

## Verification

After creating the DNS records in Cloudflare:

1. Wait for DNS propagation (usually < 5 minutes with Cloudflare)
2. Check SES console or run:
   ```bash
   aws ses get-identity-verification-attributes --identities example.com
   ```
3. Domain status should change to "Verified" within a few minutes

## Troubleshooting

- DNS records may take a few minutes to propagate
- Ensure Cloudflare proxy (orange cloud) is **disabled** for verification records
- DKIM records must be CNAME records, not TXT
- Verification TXT record must be under `_amazonses` subdomain
