# Automated Deployment System Setup Guide

This guide provides step-by-step instructions for setting up the automated deployment system that coordinates content synchronization and multi-cloud deployment for Peaceful Robot.

## Prerequisites

- GitLab account with access to `peaceful-robot/peacefulrobot.com` and `peacefulrobot-infra`
- GitHub account with access to `peacefulrobot/peacefulrobot-infra`
- Administrative access to configure platform integrations (Vercel, Netlify, AWS, etc.)

## Phase 1: Repository Setup

### 1.1 Configure GitLab Repositories

#### Content Repository (peaceful-robot/peacefulrobot.com)
1. Navigate to **Settings > Webhooks**
2. Add webhook:
   - **URL**: `https://your-webhook-server.com/webhook/gitlab`
   - **Secret Token**: Generate a secure webhook secret
   - **Trigger Events**: Push events, Pipeline events
3. Click **Add webhook**
4. Note the webhook URL and secret for later use

#### Infrastructure Repository (peacefulrobot-infra)
1. Navigate to **Settings > CI/CD > Variables**
2. Add the following variables:
   ```
   CONTENT_REPO_TOKEN: [GitLab Personal Access Token]
   VERCEL_TOKEN: [Vercel token]
   NETLIFY_AUTH_TOKEN: [Netlify token]
   GITHUB_TOKEN: [GitHub Personal Access Token]
   GITHUB_REPO_OWNER: peacefulrobot
   GITHUB_REPO_NAME: peacefulrobot-infra
   WEBHOOK_URL: [Your webhook server URL]
   ```

### 1.2 Configure GitHub Repository

1. Navigate to **Settings > Secrets and variables > Actions**
2. Add the following secrets:
   ```
   CONTENT_REPO_TOKEN: [GitLab Personal Access Token]
   INFRA_REPO_TOKEN: [GitHub Personal Access Token]
   GITHUB_TOKEN: [GitHub Personal Access Token]
   VERCEL_TOKEN: [Vercel token]
   VERCEL_ORG_ID: [Vercel organization ID]
   VERCEL_PROJECT_ID: [Vercel project ID]
   NETLIFY_AUTH_TOKEN: [Netlify token]
   NETLIFY_SITE_ID: [Netlify site ID]
   AWS_ACCESS_KEY_ID: [AWS access key]
   AWS_SECRET_ACCESS_KEY: [AWS secret key]
   AWS_S3_BUCKET: peacefulrobot-site
   CLOUDFRONT_DISTRIBUTION_ID: [CloudFront distribution ID]
   FIREBASE_TOKEN: [Firebase CLI token]
   AZURE_STATIC_WEB_APPS_API_TOKEN: [Azure SWA token]
   GITLAB_TOKEN: [GitLab Personal Access Token]
   GITLAB_PROJECT_ID: [GitLab project ID]
   MATRIX_WEBHOOK_URL: [Matrix webhook URL]
   MASTODON_TOKEN: [Mastodon token]
   ```

## Phase 2: Platform Configuration

### 2.1 Vercel Setup
```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Get organization and project IDs
vercel ls

# Set up environment variables in Vercel dashboard
# Add the secrets from GitHub Actions to Vercel environment variables
```

### 2.2 Netlify Setup
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Create new site or connect existing
netlify sites:create

# Get site ID
netlify sites:list

# Configure environment variables in Netlify dashboard
```

### 2.3 AWS S3 and CloudFront Setup
```bash
# Install AWS CLI
# Configure AWS credentials
aws configure

# Create S3 bucket
aws s3 mb s3://peacefulrobot-site --region us-east-1

# Enable static website hosting
aws s3 website s3://peacefulrobot-site --index-document index.html

# Create CloudFront distribution
# Note the distribution ID for later use

# Set bucket policy for CloudFront access
```

### 2.4 Google Firebase Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project
firebase init hosting

# Deploy to test
firebase deploy --only hosting
```

### 2.5 Azure Static Web Apps Setup
1. Create Azure Static Web App in Azure Portal
2. Note the deployment token from the overview page
3. Configure custom domain if needed

## Phase 3: Webhook Server Setup

### Option A: Deploy to Cloud Platform

#### Using Railway (Recommended - Free Tier)
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Deploy from repository
railway link
railway up

# Configure environment variables in Railway dashboard
```

#### Using Render
1. Connect GitHub repository to Render
2. Configure build command: `pip install -r scripts/requirements.txt`
3. Configure start command: `gunicorn scripts.webhook_handler:app`
4. Add environment variables

#### Using Heroku
```bash
# Install Heroku CLI
# Login to Heroku
heroku login

# Create app
heroku create your-webhook-handler

# Set environment variables
heroku config:set GITLAB_WEBHOOK_SECRET=your-secret
heroku config:set GITHUB_TOKEN=your-token
# ... add other variables

# Deploy
git push heroku main
```

### Option B: Deploy to VPS/Server
```bash
# Clone repository
git clone https://gitlab.com/peaceful-robot/peacefulrobot-infra.git
cd peacefulrobot-infra

# Install dependencies
pip install -r scripts/requirements.txt

# Set environment variables
export GITLAB_WEBHOOK_SECRET="your-secret"
export GITHUB_TOKEN="your-token"
# ... add other variables

# Run with Gunicorn
gunicorn scripts.webhook_handler:app --bind 0.0.0.0:5000

# Set up reverse proxy with Nginx
# Configure SSL certificate
```

### 3.1 Configure Webhook Server
1. Update webhook URLs in GitLab repository settings
2. Test webhook endpoint: `curl https://your-webhook-server.com/health`
3. Verify webhook delivery in GitLab project settings

## Phase 4: DNS and Load Balancing

### 4.1 Cloudflare Setup
1. Add peacefulrobot.com to Cloudflare
2. Update nameservers at domain registrar
3. Configure load balancing:
   - Create origin pools for each platform
   - Set up health checks
   - Configure load balancer rules

### 4.2 Health Check Configuration
```bash
# Configure health check endpoints
AWS: https://d123.cloudfront.net/
GCP: https://your-project.web.app/
Azure: https://your-app.azurestaticapps.net/
Vercel: https://peacefulrobot-github-io.vercel.app/
Netlify: https://peacefulrobot.netlify.app/
GitLab: https://peacefulrobot-github-io-5de419.gitlab.io/
```

## Phase 5: Monitoring Setup

### 5.1 UptimeRobot Configuration
1. Sign up at https://uptimerobot.com
2. Add monitors for all platform URLs
3. Configure alert contacts (email, webhook)
4. Set check intervals (5 minutes recommended)

### 5.2 Alert Configuration
```yaml
# Email alerts for all platforms
# Webhook alerts to Matrix/Mastodon
# Slack notifications (optional)
```

## Phase 6: Testing and Validation

### 6.1 Test Content Synchronization
```bash
# Manual sync test
./scripts/sync-content.sh --validate-only

# Test webhook endpoint
curl -X POST https://your-webhook-server.com/trigger/deployment \
  -H "Content-Type: application/json" \
  -d '{"event_type":"test","source":"manual"}'
```

### 6.2 Test Deployment Workflows
```bash
# Manually trigger GitHub Actions
gh workflow run multi-cloud-deploy.yml

# Manually trigger GitLab CI
curl -X POST \
  -H "PRIVATE-TOKEN: your-gitlab-token" \
  "https://gitlab.com/api/v4/projects/your-project-id/trigger/pipeline" \
  -d '{"ref":"main","variables[WEBHOOK_EVENT]":"manual_test"}'
```

### 6.3 Test Platform Deployments
```bash
# Test individual platform deployments
./scripts/deploy-to-all-platforms.sh

# Check deployment status across all platforms
# Verify content matches across all endpoints
```

### 6.4 Test Failover
```bash
# Temporarily disable one platform
# Verify Cloudflare automatically routes to others
# Test DNS resolution changes
```

## Phase 7: Production Deployment

### 7.1 Final Checklist
- [ ] All secrets configured in both repositories
- [ ] Webhook endpoints responding
- [ ] All platform deployments working
- [ ] Health checks configured
- [ ] Load balancing active
- [ ] Monitoring and alerting functional
- [ ] SSL certificates configured
- [ ] DNS propagated

### 7.2 Enable Automation
1. **Enable automatic pushes** in sync script (set `AUTO_PUSH=true`)
2. **Enable webhook triggers** in GitLab repositories
3. **Configure scheduled sync** (daily health check)
4. **Enable all platform auto-deployments**

### 7.3 Monitor Initial Operations
- Watch first few automated deployments
- Verify webhook delivery timing
- Check platform health check responses
- Monitor DNS propagation and load balancing

## Troubleshooting

### Common Issues

#### Webhook Delivery Failures
```bash
# Check webhook server logs
tail -f webhook.log

# Test webhook URL accessibility
curl -I https://your-webhook-server.com/webhook/gitlab

# Verify webhook secret configuration
# Check GitLab project webhook settings
```

#### Deployment Failures
```bash
# Check GitHub Actions logs
# Check GitLab CI/CD logs
# Verify platform credentials
# Test individual platform deployment manually
```

#### Content Synchronization Issues
```bash
# Test manual sync
./scripts/sync-content.sh

# Check content repository access
git clone https://oauth2:TOKEN@gitlab.com/peaceful-robot/peacefulrobot.com.git

# Verify commit messages and timestamps
```

#### Platform-Specific Issues
- **Vercel**: Check project settings and domain configuration
- **Netlify**: Verify site settings and build configuration
- **AWS**: Check S3 permissions and CloudFront distribution
- **GCP**: Verify Firebase project and hosting configuration
- **Azure**: Check Static Web App settings and deployment token

## Maintenance

### Regular Tasks
- Rotate tokens every 90 days
- Review webhook delivery success rates
- Monitor platform usage against free tier limits
- Update dependencies in webhook handler
- Review and optimize CI/CD pipeline performance

### Backup and Recovery
- Backup webhook handler configuration
- Document platform settings and credentials
- Test disaster recovery procedures
- Maintain rollback capabilities

## Cost Optimization

### Free Tier Management
- Monitor usage across all platforms
- Optimize build times to reduce CI/CD minutes
- Use CDN effectively to reduce bandwidth costs
- Implement caching strategies

### Resource Optimization
- Use minimal Docker images
- Cache dependencies in CI/CD
- Optimize build processes
- Monitor and alert on cost thresholds

---

*This setup provides automated, secure, and cost-effective multi-cloud deployment achieving 99.999% uptime target.*