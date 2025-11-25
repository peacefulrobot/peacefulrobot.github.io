# Environment Configuration Guide
# Automated Deployment System with GitLab as Source of Truth

This document outlines all the environment variables and secrets needed to configure the automated deployment system for Peaceful Robot's multi-cloud GitOps infrastructure, with **GitLab as the single source of truth**.

## Overview

The automated deployment system coordinates between:
- **Content Source**: `gitlab.com/peaceful-robot/peacefulrobot.com` (GitLab Primary)
- **Infrastructure**: `peaceful-robot/peacefulrobot-infra` (GitLab Infrastructure)
- **Deployment Targets**: Multiple cloud platforms

## Repository Configuration

### GitLab Configuration (Primary Source)

#### Content Repository (gitlab.com/peaceful-robot/peacefulrobot.com)
```yaml
# GitLab CI/CD Variables (Settings > CI/CD > Variables)
INFRA_REPO_WEBHOOK_URL: "https://gitlab.com/peaceful-robot/peacefulrobot-infra/-/hooks"
WEBHOOK_SECRET: "secure-webhook-secret"
CONTENT_DEPLOY_TOKEN: "glpat-deploy-token"
```

#### Infrastructure Repository (gitlab.com/peaceful-robot/peacefulrobot-infra)
```yaml
# GitLab CI/CD Variables (Settings > CI/CD > Variables)
CONTENT_REPO_URL: "https://gitlab.com/peaceful-robot/peacefulrobot.com.git"
CONTENT_REPO_TOKEN: "glpat-access-token"
VERCEL_TOKEN: "..."
NETLIFY_AUTH_TOKEN: "..."
GITHUB_TOKEN: "ghp-deployment-token"
GITHUB_REPO_OWNER: "peacefulrobot"
GITHUB_REPO_NAME: "peacefulrobot-infra"
WEBHOOK_URL: "https://your-webhook-server.com/webhook"
```

### GitHub Configuration (Deployment Target Only)

#### Infrastructure Repository Mirror (github.com/peacefulrobot/peacefulrobot-infra)
```yaml
# GitHub Secrets (Settings > Secrets and variables > Actions)
GITLAB_CONTENT_REPO_TOKEN: "glpat-access-token"        # Access GitLab content repo
GITLAB_INFRA_REPO_TOKEN: "glpat-infra-token"           # Access GitLab infra repo
DEPLOYMENT_TOKEN: "ghp-deploy-only"                    # Deployment operations only
VERCEL_TOKEN: "..."                                    # Vercel deployment token
VERCEL_ORG_ID: "..."                                   # Vercel organization ID
VERCEL_PROJECT_ID: "..."                               # Vercel project ID
NETLIFY_AUTH_TOKEN: "..."                              # Netlify authentication token
NETLIFY_SITE_ID: "..."                                 # Netlify site ID
AWS_ACCESS_KEY_ID: "..."                               # AWS access key
AWS_SECRET_ACCESS_KEY: "..."                           # AWS secret key
AWS_S3_BUCKET: "peacefulrobot-site"                   # S3 bucket name
CLOUDFRONT_DISTRIBUTION_ID: "..."                      # CloudFront distribution ID
FIREBASE_TOKEN: "..."                                  # Firebase CLI token
AZURE_STATIC_WEB_APPS_API_TOKEN: "..."                 # Azure SWA token
MATRIX_WEBHOOK_URL: "..."                              # Matrix notification webhook
MASTODON_TOKEN: "..."                                  # Mastodon access token
```

## Platform-Specific Configuration

### GitLab Configuration (Primary)
```bash
# Content Repository Setup
# 1. Configure webhooks in peacefulrobot.com
# 2. Set up protected branches
# 3. Configure deploy tokens for infrastructure access

# Infrastructure Repository Setup  
# 1. Configure CI/CD variables
# 2. Set up webhook triggers
# 3. Configure GitLab Pages deployment
```

### Vercel Configuration (GitHub Actions Target)
```bash
# Get Vercel token (configured in GitHub Actions)
npm i -g vercel
vercel login
vercel token

# Get organization and project IDs
vercel ls
```

### Netlify Configuration (GitHub Actions Target)
```bash
# Get Netlify token (configured in GitHub Actions)
netlify login
netlify status

# Get site ID
netlify sites:list
```

### AWS Configuration
```bash
# Configure AWS CLI (for GitHub Actions)
aws configure

# Create S3 bucket
aws s3 mb s3://peacefulrobot-site --region us-east-1

# Create CloudFront distribution (note the distribution ID)
```

### Google Firebase Configuration (GitHub Actions Target)
```bash
# Install Firebase CLI (for GitHub Actions)
npm install -g firebase-tools

# Login and get token
firebase login
firebase projects:list

# Initialize project
firebase init hosting
```

### Azure Static Web Apps Configuration (GitHub Actions Target)
```bash
# Install Azure CLI (for GitHub Actions)
# Get API token from Azure Portal > Static Web Apps > Overview
```

## Webhook Configuration

### GitLab Webhooks (Primary Source)

#### Content Repository (peaceful-robot/peacefulrobot.com)
```yaml
# Settings > Webhooks
URL: "https://gitlab.com/peaceful-robot/peacefulrobot-infra/-/hooks/content-sync"
Secret Token: "your-webhook-secret"
Trigger Events:
  - Push events
  - Merge request events
```

#### Infrastructure Repository (peaceful-robot/peacefulrobot-infra)
```yaml
# Settings > Webhooks
URL: "https://github.com/peacefulrobot/peacefulrobot-infra/dispatch"
Secret Token: "your-github-webhook-secret"
Events: repository_dispatch
```

## Environment Variables by Component

### GitLab CI Pipeline (Primary Infrastructure)
```bash
# .gitlab-ci.yml environment
CONTENT_REPO_URL: "https://gitlab.com/peaceful-robot/peacefulrobot.com.git"
CONTENT_REPO_TOKEN: "glpat-access-token"
VERCEL_TOKEN: "..."
NETLIFY_AUTH_TOKEN: "..."
GITHUB_TOKEN: "ghp-deployment-only"
GITHUB_REPO_OWNER: "peacefulrobot"
GITHUB_REPO_NAME: "peacefulrobot-infra"
WEBHOOK_URL: "https://your-webhook-server.com/webhook"
```

### GitHub Actions Workflow (Deployment Target)
```bash
# .github/workflows/multi-cloud-deploy.yml environment
GITLAB_CONTENT_REPO_TOKEN: "glpat-access-token"
GITLAB_INFRA_REPO_TOKEN: "glpat-infra-token"
VERCEL_TOKEN: "..."
NETLIFY_AUTH_TOKEN: "..."
AWS_ACCESS_KEY_ID: "..."
AWS_SECRET_ACCESS_KEY: "..."
FIREBASE_TOKEN: "..."
AZURE_STATIC_WEB_APPS_API_TOKEN: "..."
MATRIX_WEBHOOK_URL: "..."
MASTODON_TOKEN: "..."
```

### Webhook Handler (GitLab Infrastructure)
```bash
# scripts/webhook_handler.py environment
GITLAB_WEBHOOK_SECRET: "your-gitlab-webhook-secret"
GITHUB_TOKEN: "ghp-deployment-token"
INFRA_REPO_OWNER: "peacefulrobot"
INFRA_REPO_NAME: "peacefulrobot-infra"
GITLAB_PROJECT_ID: "your-gitlab-project-id"
PORT: 5000
DEBUG: false
```

### Deployment Scripts (GitLab Infrastructure)
```bash
# scripts/deploy-to-all-platforms.sh environment
VERCEL_TOKEN: "..."
NETLIFY_AUTH_TOKEN: "..."
AWS_ACCESS_KEY_ID: "..."
AWS_SECRET_ACCESS_KEY: "..."
AWS_S3_BUCKET: "peacefulrobot-site"
CLOUDFRONT_DISTRIBUTION_ID: "..."
FIREBASE_TOKEN: "..."
AZURE_STATIC_WEB_APPS_API_TOKEN: "..."
```

### Content Synchronization Script (GitLab Infrastructure)
```bash
# scripts/sync-content.sh environment
CONTENT_REPO_URL: "https://gitlab.com/peaceful-robot/peacefulrobot.com.git"
CONTENT_REPO_TOKEN: "glpat-access-token"
AUTO_PUSH: "true"
```

## Security Best Practices

### 1. GitLab as Source of Truth
- Use GitLab's enterprise security features
- Implement protected branches and merge requests
- Configure deploy tokens for infrastructure access
- Enable webhook signature verification

### 2. Token Management
- Use GitLab deploy tokens for infrastructure operations
- Limit GitHub token scope to deployment only
- Rotate tokens regularly (90-day cycle)
- Store tokens in repository secrets, never in code

### 3. Access Control
- **GitLab Content Repo**: Content team write access
- **GitLab Infra Repo**: Infrastructure team write access
- **GitHub Mirror**: Read-only for deployment operations
- **Platform Tokens**: Minimal required scopes

### 4. Webhook Security
- Use webhook secrets for all GitLab webhook endpoints
- Implement signature verification in webhook handler
- Use HTTPS for all webhook endpoints
- Rate limit webhook requests

## Testing Configuration

### Test GitLab Webhook Endpoints
```bash
# Test GitLab content repository webhook
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-Gitlab-Token: your-webhook-secret" \
  -d '{"object_kind":"push","ref":"refs/heads/main","commits":[{"id":"test123","message":"test"}]}' \
  https://gitlab.com/peaceful-robot/peacefulrobot-infra/-/hooks/content-sync

# Test deployment trigger
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"event_type":"manual_trigger","source":"gitlab_test"}' \
  https://your-webhook-server.com/trigger/deployment
```

### Test CI/CD Pipelines
```bash
# Manually trigger GitLab CI (infrastructure repository)
curl -X POST \
  -H "PRIVATE-TOKEN: your-gitlab-token" \
  "https://gitlab.com/api/v4/projects/your-project-id/trigger/pipeline" \
  -d '{"ref":"main","variables[WEBHOOK_EVENT]":"manual_test"}'

# Manually trigger GitHub Actions (deployment target)
gh workflow run multi-cloud-deploy.yml --repo peacefulrobot/peacefulrobot-infra
```

## Monitoring Configuration

### UptimeRobot Setup (GitLab-Centric)
Create monitors for:
- **GitLab Pages**: `https://peaceful-robot/peacefulrobot-infra.gitlab.io/`
- **Vercel**: `https://peacefulrobot-github-io.vercel.app/`
- **Netlify**: `https://peacefulrobot.netlify.app/`
- **AWS CloudFront**: `https://d1234.cloudfront.net/`
- **Firebase**: `https://your-project.web.app/`
- **Azure**: `https://your-app.azurestaticapps.net/`

### Alert Configuration
- **GitLab**: Built-in email alerts for CI/CD failures
- **External Platforms**: UptimeRobot email/webhook alerts
- **Matrix/Mastodon**: Custom webhook notifications
- **Critical Issues**: Multi-channel alerting

## Troubleshooting

### GitLab-Centric Issues

1. **Content Repository Access**
   ```bash
   # Verify GitLab deploy token
   curl -H "PRIVATE-TOKEN: your-token" \
     "https://gitlab.com/api/v4/projects/peaceful-robot%2Fpeacefulrobot.com"
   ```

2. **Webhook Delivery**
   ```bash
   # Check GitLab webhook delivery status
   # Settings > Webhooks > Recent Deliveries
   ```

3. **CI/CD Pipeline Issues**
   ```bash
   # Check GitLab CI logs
   # CI/CD > Pipelines > Select pipeline > View logs
   ```

### Cross-Repository Coordination

1. **GitLab to GitHub Synchronization**
   ```bash
   # Test content sync script
   ./scripts/sync-content.sh --validate-only
   
   # Check GitHub Actions logs
   # Actions tab in GitHub repository
   ```

2. **Deployment Failures**
   - Check GitLab CI logs for infrastructure issues
   - Check GitHub Actions logs for deployment issues
   - Verify platform-specific credentials
   - Review webhook delivery status

## Cost Optimization (GitLab-Centric)

### GitLab Benefits
- **GitLab Pages**: Unlimited free hosting (primary)
- **GitLab CI**: 400 minutes/month free (generous)
- **GitLab Monitoring**: Built-in analytics and monitoring
- **GitLab Security**: Enterprise features included

### Resource Optimization
- Cache dependencies in GitLab CI/CD
- Use smaller Docker images for GitLab runners
- Optimize build processes for GitLab CI
- Monitor GitLab CI minutes usage

## GitLab Source of Truth - Operational Benefits

### 1. **Simplified Workflow**
- All content changes originate in GitLab
- Single webhook system for all updates
- Consistent deployment pipeline
- Unified access control

### 2. **Enhanced Reliability**
- GitLab Pages as primary hosting (unlimited)
- GitLab CI as primary deployment pipeline
- Built-in monitoring and alerting
- Enterprise-grade security

### 3. **Cost Efficiency**
- GitLab Pages: $0 (unlimited)
- GitLab CI: $0 (400 minutes/month)
- Reduced external dependencies
- Simplified infrastructure

### 4. **Better Integration**
- Native GitLab integration
- Built-in webhook system
- Advanced monitoring
- Enterprise security features

---

*This configuration enables automated, secure, and cost-effective multi-cloud deployment with GitLab as the single source of truth, achieving 99.999% uptime target.*