# Environment Configuration Guide
# Automated Deployment System

This document outlines all the environment variables and secrets needed to configure the automated deployment system for Peaceful Robot's multi-cloud GitOps infrastructure.

## Overview

The automated deployment system coordinates between two repositories:
- **Content Repository**: `peaceful-robot/peacefulrobot.com` (source of truth)
- **Infrastructure Repository**: `peacefulrobot-infra` (deployment coordinator)

## Repository Configuration

### GitLab Configuration

#### Content Repository (peaceful-robot/peacefulrobot.com)
```yaml
# GitLab CI/CD Variables (Settings > CI/CD > Variables)
CONTENT_REPO_TOKEN: "glpat-..."           # Personal Access Token for content repo
INFRA_REPO_WEBHOOK_URL: "https://gitlab.com/peaceful-robot/peacefulrobot-infra/-/hooks"  # Webhook URL
```

#### Infrastructure Repository (peacefulrobot-infra)
```yaml
# GitLab CI/CD Variables (Settings > CI/CD > Variables)
CONTENT_REPO_TOKEN: "glpat-..."           # Token to access content repository
VERCEL_TOKEN: "..."                        # Vercel deployment token
NETLIFY_AUTH_TOKEN: "..."                 # Netlify authentication token
GITHUB_TOKEN: "..."                       # GitHub personal access token
GITHUB_REPO_OWNER: "peacefulrobot"        # GitHub repository owner
GITHUB_REPO_NAME: "peacefulrobot-infra"   # GitHub repository name
WEBHOOK_URL: "https://your-webhook-server.com/webhook"  # Webhook endpoint
```

### GitHub Configuration

#### Infrastructure Repository (peacefulrobot-infra)
```yaml
# GitHub Secrets (Settings > Secrets and variables > Actions)
CONTENT_REPO_TOKEN: "glpat-..."                    # GitLab PAT for content repo access
INFRA_REPO_TOKEN: "ghp_..."                        # GitHub PAT for this repo
GITHUB_TOKEN: "ghp_..."                            # GitHub token for API calls
VERCEL_TOKEN: "..."                               # Vercel deployment token
VERCEL_ORG_ID: "..."                              # Vercel organization ID
VERCEL_PROJECT_ID: "..."                          # Vercel project ID
NETLIFY_AUTH_TOKEN: "..."                         # Netlify authentication token
NETLIFY_SITE_ID: "..."                            # Netlify site ID
AWS_ACCESS_KEY_ID: "..."                          # AWS access key
AWS_SECRET_ACCESS_KEY: "..."                      # AWS secret key
AWS_S3_BUCKET: "peacefulrobot-site"              # S3 bucket name
CLOUDFRONT_DISTRIBUTION_ID: "..."                 # CloudFront distribution ID
FIREBASE_TOKEN: "..."                             # Firebase CLI token
AZURE_STATIC_WEB_APPS_API_TOKEN: "..."            # Azure SWA token
GITLAB_TOKEN: "glpat-..."                         # GitLab token for API calls
GITLAB_PROJECT_ID: "..."                          # GitLab project ID
MATRIX_WEBHOOK_URL: "..."                         # Matrix notification webhook
MASTODON_TOKEN: "..."                             # Mastodon access token
```

## Platform-Specific Configuration

### Vercel Configuration
```bash
# Get Vercel token
npm i -g vercel
vercel login
vercel token

# Get organization and project IDs
vercel ls
```

### Netlify Configuration
```bash
# Get Netlify token
netlify login
netlify status

# Get site ID
netlify sites:list
```

### AWS Configuration
```bash
# Configure AWS CLI
aws configure

# Create S3 bucket
aws s3 mb s3://peacefulrobot-site --region us-east-1

# Create CloudFront distribution (note the distribution ID)
```

### Google Firebase Configuration
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and get token
firebase login
firebase projects:list

# Initialize project
firebase init hosting
```

### Azure Static Web Apps Configuration
```bash
# Install Azure CLI
# Get API token from Azure Portal > Static Web Apps > Overview
```

## Webhook Configuration

### GitLab Webhooks
```yaml
# In Content Repository (peaceful-robot/peacefulrobot.com)
# Settings > Webhooks
URL: "https://your-webhook-server.com/webhook/gitlab"
Secret Token: "your-webhook-secret"
Trigger Events:
  - Push events
  - Pipeline events
```

### GitHub Webhooks (if using external webhook server)
```yaml
# In Infrastructure Repository
# Settings > Webhooks
URL: "https://your-webhook-server.com/webhook/github"
Secret: "your-github-webhook-secret"
Events: repository_dispatch
```

## Environment Variables by Component

### Webhook Handler (scripts/webhook_handler.py)
```bash
# Required for webhook handler
GITLAB_WEBHOOK_SECRET="your-gitlab-webhook-secret"
GITHUB_TOKEN="ghp_..."
INFRA_REPO_OWNER="peacefulrobot"
INFRA_REPO_NAME="peacefulrobot-infra"
GITLAB_TOKEN="glpat-..."
GITLAB_PROJECT_ID="..."

# Optional
PORT=5000
DEBUG=false
```

### Deployment Scripts
```bash
# scripts/deploy-to-all-platforms.sh
VERCEL_TOKEN="..."
NETLIFY_AUTH_TOKEN="..."
AWS_ACCESS_KEY_ID="..."
AWS_SECRET_ACCESS_KEY="..."
AWS_S3_BUCKET="peacefulrobot-site"
CLOUDFRONT_DISTRIBUTION_ID="..."
FIREBASE_TOKEN="..."
AZURE_STATIC_WEB_APPS_API_TOKEN="..."
```

### Content Synchronization Script
```bash
# scripts/sync-content.sh
CONTENT_REPO_URL="https://gitlab.com/peaceful-robot/peacefulrobot.com.git"
CONTENT_REPO_TOKEN="glpat-..."
AUTO_PUSH="true"  # Set to "false" for dry-run mode
```

## Security Best Practices

### 1. Token Management
- Use minimal required scopes for all tokens
- Rotate tokens regularly
- Store tokens in repository secrets, never in code
- Use different tokens for different environments

### 2. Webhook Security
- Use webhook secrets for all webhook endpoints
- Implement signature verification
- Use HTTPS for all webhook endpoints
- Rate limit webhook requests

### 3. Access Control
- Limit repository access to required users
- Use branch protection rules
- Enable two-factor authentication
- Regularly audit access permissions

## Testing Configuration

### Test Webhook Endpoints
```bash
# Test GitLab webhook
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Gitlab-Token: your-webhook-secret" \
  -d '{"object_kind":"push","ref":"refs/heads/main","commits":[{"id":"test123","message":"test"}]}' \
  https://your-webhook-server.com/webhook/gitlab

# Test deployment trigger
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"event_type":"manual_trigger","source":"test"}' \
  https://your-webhook-server.com/trigger/deployment
```

### Test CI/CD Pipelines
```bash
# Manually trigger GitHub Actions
gh workflow run multi-cloud-deploy.yml

# Manually trigger GitLab CI
curl -X POST \
  -H "PRIVATE-TOKEN: your-gitlab-token" \
  "https://gitlab.com/api/v4/projects/your-project-id/trigger/pipeline" \
  -d '{"ref":"main","variables[WEBHOOK_EVENT]":"manual_test"}'
```

## Monitoring Configuration

### UptimeRobot Setup
Create monitors for:
- GitLab Pages: `https://peacefulrobot-github-io-5de419.gitlab.io/`
- Vercel: `https://peacefulrobot-github-io.vercel.app/`
- Netlify: `https://peacefulrobot.netlify.app/`
- AWS CloudFront: `https://d1234.cloudfront.net/`
- Firebase: `https://your-project.web.app/`
- Azure: `https://your-app.azurestaticapps.net/`

### Alert Configuration
- Email alerts for all platforms
- Matrix notifications for critical failures
- Webhook alerts to monitoring systems

## Troubleshooting

### Common Issues

1. **Authentication Failures**
   - Check token permissions and expiration
   - Verify repository access
   - Test tokens with API calls

2. **Webhook Delivery Issues**
   - Verify webhook URLs are accessible
   - Check webhook secret configuration
   - Review webhook logs

3. **Deployment Failures**
   - Check platform-specific credentials
   - Verify deployment configurations
   - Review CI/CD logs

4. **Cross-Repository Coordination**
   - Verify webhook triggers
   - Check repository permissions
   - Review synchronization logs

### Log Locations
- GitLab CI: Project > CI/CD > Pipelines
- GitHub Actions: Actions tab in repository
- Webhook Handler: `webhook.log` file
- Deployment Scripts: Console output and artifacts

## Cost Optimization

### Free Tier Monitoring
- GitLab CI: 400 minutes/month
- GitHub Actions: 2000 minutes/month
- Platform free tiers: Monitor usage

### Resource Optimization
- Cache dependencies in CI/CD
- Use smaller Docker images
- Optimize build processes
- Monitor bandwidth usage across platforms

---

*This configuration enables automated, secure, and cost-effective multi-cloud deployment with 99.999% uptime target.*