# Five Nines Architecture Setup Guide

## Goal
Achieve 99.999% uptime (5.26 minutes downtime/year) at $0/month using 6 cloud providers with automatic failover.

## Architecture Overview
```
Cloudflare DNS (free tier)
    ↓ (load balancing + health checks)
    ├─→ AWS S3 + CloudFront (50GB/month free)
    ├─→ GCP Firebase Hosting (10GB/month free)
    ├─→ Azure Static Web Apps (100GB/month free)
    ├─→ Vercel (100GB/month free)
    ├─→ Netlify (100GB/month free)
    └─→ GitLab Pages (unlimited free)
```

**Total Bandwidth**: 460GB+/month at $0 cost

## Phase 1: Cloud Provider Setup

### 1. AWS S3 + CloudFront
```bash
# Create S3 bucket
aws s3 mb s3://peacefulrobot-site --region us-east-1
aws s3 website s3://peacefulrobot-site --index-document index.html

# Create CloudFront distribution
aws cloudfront create-distribution \
  --origin-domain-name peacefulrobot-site.s3-website-us-east-1.amazonaws.com \
  --default-root-object index.html

# Note the distribution ID and domain name
```

**Free Tier**: 50GB transfer/month, 2M HTTP requests

### 2. GCP Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and initialize
firebase login
cd peacefulrobot.github.io
firebase init hosting

# Deploy
firebase deploy --only hosting
```

**Free Tier**: 10GB storage, 360MB/day transfer

### 3. Azure Static Web Apps
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login and create resource
az login
az staticwebapp create \
  --name peacefulrobot \
  --resource-group peacefulrobot-rg \
  --source peacefulrobot.github.io \
  --location eastus2 \
  --branch main \
  --token $GITHUB_TOKEN
```

**Free Tier**: 100GB bandwidth/month

### 4. Existing Providers (Already Configured)
- ✅ Vercel: https://peacefulrobot-github-io.vercel.app/
- ✅ Netlify: Configure via web UI
- ✅ GitLab Pages: https://peacefulrobot-github-io-5de419.gitlab.io/

## Phase 2: Cloudflare Setup

### 1. Transfer DNS to Cloudflare
1. Sign up at https://dash.cloudflare.com/sign-up
2. Add site: peacefulrobot.com
3. Update nameservers at GoDaddy:
   - Remove GoDaddy nameservers
   - Add Cloudflare nameservers (provided during setup)
4. Wait for DNS propagation (24-48 hours)

### 2. Configure Load Balancing
```bash
# Create origin pools (one per cloud provider)
curl -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/load_balancers/pools" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "name": "aws-pool",
    "origins": [{"name": "aws", "address": "d1234.cloudfront.net", "enabled": true}],
    "monitor": "$MONITOR_ID",
    "notification_email": "alerts@peacefulrobot.com"
  }'

# Repeat for GCP, Azure, Vercel, Netlify, GitLab
```

### 3. Configure Health Checks
```bash
# Create health monitor
curl -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/load_balancers/monitors" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "https",
    "description": "Health check for peacefulrobot.com",
    "method": "GET",
    "path": "/",
    "interval": 60,
    "retries": 2,
    "timeout": 5,
    "expected_codes": "200"
  }'
```

### 4. Create Load Balancer
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/load_balancers" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "name": "peacefulrobot.com",
    "default_pools": ["$AWS_POOL", "$GCP_POOL", "$AZURE_POOL", "$VERCEL_POOL", "$NETLIFY_POOL", "$GITLAB_POOL"],
    "fallback_pool": "$GITLAB_POOL",
    "steering_policy": "dynamic_latency",
    "session_affinity": "cookie"
  }'
```

## Phase 3: Automated Deployment

### GitHub Actions (Already Created)
- `.github/workflows/multi-cloud-deploy.yml` deploys to AWS, GCP, Azure
- Vercel/Netlify auto-deploy from GitHub
- GitLab CI deploys to GitLab Pages

### Required Secrets
Add to GitHub repository settings:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `CLOUDFRONT_DISTRIBUTION_ID`
- `FIREBASE_TOKEN`
- `AZURE_STATIC_WEB_APPS_API_TOKEN`

## Phase 4: Monitoring

### UptimeRobot Setup
1. Sign up at https://uptimerobot.com (free: 50 monitors)
2. Create monitors for each endpoint:
   - AWS CloudFront URL
   - GCP Firebase URL
   - Azure Static Web Apps URL
   - Vercel URL
   - Netlify URL
   - GitLab Pages URL
3. Configure alerts (email/SMS/webhook)

### Monitor Configuration
- Check interval: 5 minutes
- Alert after: 2 consecutive failures
- Notification channels: Email + webhook to Matrix/Mastodon

## Expected Results

### Uptime Calculation
- Single provider: 99.9% (43.8 minutes downtime/month)
- 6 providers with failover: 99.999% (5.26 minutes downtime/year)

### Cost Breakdown
- AWS: $0 (within free tier)
- GCP: $0 (within free tier)
- Azure: $0 (within free tier)
- Vercel: $0 (hobby plan)
- Netlify: $0 (starter plan)
- GitLab Pages: $0 (free tier)
- Cloudflare: $0 (free tier)
- UptimeRobot: $0 (free tier)

**Total: $0/month**

## Failover Behavior

1. Cloudflare health check detects failure on primary (AWS)
2. Automatic failover to next healthy pool (GCP)
3. Traffic routed to GCP within 60 seconds
4. Email/webhook alert sent
5. When AWS recovers, traffic gradually shifts back

## Next Steps

1. ✅ GitHub Actions workflow created
2. ⏳ Sign up for AWS, GCP, Azure free tiers
3. ⏳ Deploy to all 6 providers
4. ⏳ Transfer DNS to Cloudflare
5. ⏳ Configure load balancing and health checks
6. ⏳ Set up UptimeRobot monitoring
7. ⏳ Test failover scenarios

## Testing Failover

```bash
# Simulate AWS failure by blocking CloudFront
# Cloudflare should automatically route to GCP

# Monitor DNS resolution
watch -n 5 'dig peacefulrobot.com'

# Check which provider is serving
curl -I https://peacefulrobot.com | grep -i server
```
