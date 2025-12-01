# Peaceful Robot - Multi-Cloud GitOps Infrastructure

## 🔒 IMPORTANT: For All AI Assistants

**Before working on this project, ALL AI assistants MUST read:**

```
.ai/SECURITY_RULES.md
```

**This is MANDATORY for:**
- ChatGPT, Claude, Gemini (tell them to read it)
- Amazon Q, Cursor, Aider, Copilot (reads automatically)

Privacy, safety, and security are NON-NEGOTIABLE.

---

## 🎯 Project Overview

**Multi-cloud GitOps infrastructure achieving 99.999% uptime at $0/month.**

### ✅ Currently Working (Production Ready)
- **GitLab Pages (Source of Truth)**: https://peacefulrobot-com-cec744.gitlab.io/
- **Vercel**: https://peacefulrobot-github-io.vercel.app/
- **Main Domain**: https://www.peacefulrobot.com/

### Architecture
- **GitLab**: Source of truth (`gitlab.com/peaceful-robot/peacefulrobot.com`)
- **GitHub**: Deployment target mirror (`github.com/peacefulrobot/peacefulrobot-infra`)
- **Current Uptime**: 99.9% (3 working platforms)
- **Target Uptime**: 99.999% (6 platforms with load balancing)
- **Cost**: $0.00/month (all platforms on free tiers)

### Repositories
- **Content Source**: https://gitlab.com/peaceful-robot/peacefulrobot.com
- **Infrastructure**: https://gitlab.com/peaceful-robot/peacefulrobot-infra
- **GitHub Mirror**: https://github.com/peacefulrobot/peacefulrobot-infra

---

## 🚀 Quick Start for AI Agents

### 1. Content Deployment (Current Status: ✅ WORKING)

```bash
# Backup current content
mkdir -p content_backup && cp index.html content_backup/index.html.$(date +%Y%m%d_%H%M%S)

# Deploy to available platforms
./scripts/deploy-to-all-platforms.sh

# Verify deployments
curl -I https://peacefulrobot-github-io-5de419.gitlab.io/
curl -I https://peacefulrobot-github-io.vercel.app/
curl -I https://www.peacefulrobot.com/
```

### 2. Content Synchronization from GitLab (Source of Truth)

```bash
# Set GitLab Personal Access Token
export CONTENT_REPO_TOKEN="glpat-your-token-here"

# Sync content from GitLab repository
./scripts/sync-content.sh

# Or validate only (test before full sync)
./scripts/sync-content.sh --validate-only
```

### 3. GitLab CI/CD Pipeline (Automated)

```bash
# Manual trigger via GitLab API
curl -X POST \
  -H "PRIVATE-TOKEN: your-gitlab-token" \
  "https://gitlab.com/api/v4/projects/your-project-id/trigger/pipeline" \
  -d '{"ref":"main","variables[WEBHOOK_EVENT]":"manual_deploy"}'
```

### 4. GitHub Actions (External Platforms)

```bash
# Manual trigger GitHub Actions workflow
gh workflow run multi-cloud-deploy.yml --repo peacefulrobot/peacefulrobot-infra
```

---

## 📁 Project Structure

```
peacefulrobot-infra/
├── 📄 index.html                      # Main website content
├── 📄 .gitlab-ci.yml                  # GitLab CI/CD pipeline
├── 📄 .github/workflows/multi-cloud-deploy.yml  # GitHub Actions
├── 📁 scripts/
│   ├── 📄 deploy-to-all-platforms.sh  # Multi-platform deployment
│   ├── 📄 sync-content.sh             # GitLab content sync
│   ├── 📄 webhook_handler.py          # Webhook coordination
│   └── 📄 requirements.txt            # Python dependencies
├── 📁 tools/
│   ├── 📄 security_check.py           # Security validation
│   └── 📄 update_godaddy_dns.py       # DNS management
└── 📁 Documentation/
    ├── 📄 DEPLOYMENT_GUIDE.md         # Complete deployment guide
    ├── 📄 AUTOMATED_DEPLOYMENT_ARCHITECTURE.md  # Architecture docs
    ├── 📄 ENVIRONMENT_CONFIG.md       # Environment variables guide
    └── 📄 STATUS.md                   # Current deployment status
```

---

## 🛠️ Platform-Specific Instructions

### Vercel Deployment
```bash
# Set Vercel token
export VERCEL_TOKEN="your-vercel-token"

# Deploy
cd . && vercel --token $VERCEL_TOKEN --prod --yes

# Check status
curl -I https://peacefulrobot-github-io.vercel.app/
```

### Netlify Deployment
```bash
# Set Netlify token
export NETLIFY_AUTH_TOKEN="your-netlify-token"

# Deploy
netlify deploy --prod --auth $NETLIFY_AUTH_TOKEN
```

### AWS S3 + CloudFront
```bash
# Set AWS credentials
export AWS_ACCESS_KEY_ID="your-aws-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret"
export AWS_S3_BUCKET="peacefulrobot-site"

# Deploy to S3
aws s3 sync . s3://$AWS_S3_BUCKET --delete --exclude ".git/*"

# Invalidate CloudFront (if configured)
if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    aws cloudfront create-invalidation \
        --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
        --paths "/*"
fi
```

### GitLab Pages (Local Preparation)
```bash
# Prepare content for GitLab Pages
mkdir -p public
cp index.html public/
cp -r * public/ 2>/dev/null || true

# GitLab CI will handle the actual deployment
```

---

## 🔄 Automated Workflows

### GitLab-Centric Deployment Flow
```
Content Change → GitLab Webhook → Infrastructure Sync → Multi-Platform Deploy
```

1. **Content Update**: Changes pushed to `gitlab.com/peaceful-robot/peacefulrobot.com`
2. **Webhook Trigger**: GitLab webhook triggers infrastructure repository
3. **Content Sync**: GitLab CI pulls and validates latest content
4. **Platform Deploy**: Deploy to Vercel, Netlify, AWS, GCP, Azure, GitLab Pages
5. **Health Check**: Verify all deployments are working
6. **Load Balancer Update**: Update Cloudflare with new endpoints

### Manual Deployment Process
```bash
# 1. Sync from GitLab (if needed)
CONTENT_REPO_TOKEN="your-token" ./scripts/sync-content.sh

# 2. Backup current content
cp index.html index.html.backup.$(date +%Y%m%d_%H%M%S)

# 3. Deploy to all platforms
./scripts/deploy-to-all-platforms.sh

# 4. Verify deployment status
cat deployment_status.json
jq '.platforms[]' deployment_status.json

# 5. Test all endpoints
curl -s https://peacefulrobot-github-io-5de419.gitlab.io/ | grep "Peaceful Robot"
curl -s https://peacefulrobot-github-io.vercel.app/ | grep "Peaceful Robot"
```

---

## 🔐 Required Environment Variables

### GitLab CI/CD Variables
```yaml
CONTENT_REPO_TOKEN: "glpat-access-token"     # Access content repository
CONTENT_REPO_URL: "https://gitlab.com/peaceful-robot/peacefulrobot.com.git"
VERCEL_TOKEN: "..."                           # Vercel deployment token
NETLIFY_AUTH_TOKEN: "..."                     # Netlify authentication token
GITHUB_TOKEN: "ghp-deployment-token"          # GitHub Actions access
WEBHOOK_URL: "https://your-webhook-server.com/webhook"
```

### GitHub Actions Secrets
```yaml
GITLAB_CONTENT_REPO_TOKEN: "glpat-access-token"    # Access GitLab content
GITLAB_INFRA_REPO_TOKEN: "glpat-infra-token"       # Access GitLab infra
VERCEL_TOKEN: "..."                                 # Vercel deployment
NETLIFY_AUTH_TOKEN: "..."                           # Netlify auth
AWS_ACCESS_KEY_ID: "..."                            # AWS access
AWS_SECRET_ACCESS_KEY: "..."                        # AWS secret
AWS_S3_BUCKET: "peacefulrobot-site"                # S3 bucket
CLOUDFRONT_DISTRIBUTION_ID: "..."                  # CloudFront ID
FIREBASE_TOKEN: "..."                               # Firebase CLI token
AZURE_STATIC_WEB_APPS_API_TOKEN: "..."              # Azure SWA token
```

---

## 📊 Monitoring & Health Checks

### Current Status
```bash
# Check all deployment endpoints
echo "=== GitLab Pages (Source) ===" && curl -s -I https://peacefulrobot-com-cec744.gitlab.io/
echo "=== Vercel ===" && curl -s -I https://peacefulrobot-github-io.vercel.app/
echo "=== Main Domain ===" && curl -s -I https://www.peacefulrobot.com/

# Content verification
curl -s https://peacefulrobot-github-io.vercel.app/ | grep -E "(title|Peaceful Robot)"
curl -s https://peacefulrobot-com-cec744.gitlab.io/ | grep -E "(title|Peaceful Robot)"
```

### Uptime Targets
- **Current**: 99.9% (3 platforms)
- **Target**: 99.999% (6 platforms with load balancing)
- **Downtime Budget**: 5.26 minutes per year
- **Monitoring**: UptimeRobot + GitLab CI/CD + GitHub Actions

---

## 🆘 Troubleshooting Guide

### Common Issues

#### 1. GitLab Content Sync Fails
```bash
# Check if token is valid
curl -H "PRIVATE-TOKEN: your-token" \
  "https://gitlab.com/api/v4/projects/peaceful-robot%2Fpeacefulrobot.com"

# Test content repository access
git clone https://oauth2:your-token@gitlab.com/peaceful-robot/peacefulrobot.com.git temp
```

#### 2. Vercel 404 Error
```bash
# Redeploy with fresh token
unset VERCEL_TOKEN && export VERCEL_TOKEN="new-valid-token"
vercel --token $VERCEL_TOKEN --prod --yes

# Check project settings in Vercel dashboard
```

#### 3. Platform Deployment Failures
```bash
# Check deployment script logs
cat deployment_status.json | jq '.'

# Validate content before deployment
./scripts/deploy-to-all-platforms.sh --help
```

#### 4. Content Inconsistency
```bash
# Force resync from GitLab
CONTENT_REPO_TOKEN="your-token" ./scripts/sync-content.sh

# Compare content across platforms
diff <(curl -s https://peacefulrobot-github-io.vercel.app/) \
     <(curl -s https://peacefulrobot-github-io-5de419.gitlab.io/)
```

---

## 📚 Documentation References

- **🔧 Setup Guide**: `DEPLOYMENT_GUIDE.md`
- **🏗️ Architecture**: `AUTOMATED_DEPLOYMENT_ARCHITECTURE.md`
- **⚙️ Environment Config**: `ENVIRONMENT_CONFIG.md`
- **📊 Current Status**: `STATUS.md`
- **✅ Accomplishments**: `ACCOMPLISHED.md`
- **🛡️ Security Policy**: `SECURITY_POLICY.md`
- **🎯 Five Nines Setup**: `FIVE_NINES_SETUP.md`

---

## 🔄 GitOps Best Practices

### 1. GitLab as Source of Truth
- **Content Repository**: `peaceful-robot/peacefulrobot.com` - Single source for all website content
- **Infrastructure Repository**: `peaceful-robot/peacefulrobot-infra` - Deployment automation
- **GitHub Mirror**: `peacefulrobot/peacefulrobot-infra` - Deployment target only

### 2. Deployment Pipeline
```yaml
# GitLab CI Pipeline Stages
stages:
  - sync        # Sync content from source repository
  - validate    # Validate content security and structure
  - deploy      # Deploy to multiple platforms
  - notify      # Send webhook notifications
```

### 3. Security Checklist
- [ ] No credentials in code or commits
- [ ] Use environment variables for all secrets
- [ ] Validate content security headers
- [ ] Test deployments in staging first
- [ ] Monitor for security vulnerabilities
- [ ] Keep tokens up to date (90-day rotation)

---

## 🎯 Success Criteria

### Deployment Validation
- [x] GitLab Pages serving correct content (source of truth)
- [x] Vercel serving correct content
- [x] Main domain redirecting correctly
- [x] HTTPS certificates working
- [x] Content consistency across active platforms
- [x] Deployment automation functional
- [⚠️] Netlify needs fixing (404 error)
- [ ] AWS/GCP/Azure deployments needed

### Next Phase Targets
- [ ] Add 3 more platforms (AWS, GCP, Azure)
- [ ] Configure Cloudflare load balancing
- [ ] Set up automated health checks
- [ ] Implement 99.999% uptime monitoring
- [ ] Add automated failover testing

---

## 💰 Cost Analysis

### Current Free Tier Usage
- **GitLab Pages**: $0 (unlimited)
- **GitLab CI**: $0 (400 minutes/month)
- **GitHub Actions**: $0 (2000 minutes/month)
- **Vercel**: $0 (Hobby plan - 100GB bandwidth)
- **Netlify**: $0 (Starter plan - 100GB bandwidth)
- **Cloudflare**: $0 (Free tier)

### Total Monthly Cost: $0.00
### Target: Maintain $0.00/month with 99.999% uptime

---

## 🤝 Contributing Guidelines

### For AI Agents
1. **Read this README completely** before making any changes
2. **Check current status** in `STATUS.md`
3. **Follow security guidelines** in `.ai/SECURITY_RULES.md`
4. **Test in staging** before production deployments
5. **Document all changes** and update relevant files

### For Humans
1. Read `.ai/SECURITY_RULES.md` first
2. Follow security checklist before commits
3. Never commit credentials or personal info
4. Use environment variables for all secrets
5. Test deployments thoroughly

---

## 📞 Emergency Procedures

### Deployment Rollback
```bash
# Restore from backup
cp content_backup/index.html.backup.* index.html

# Redeploy with previous version
./scripts/deploy-to-all-platforms.sh
```

### Platform-Specific Rollbacks
```bash
# GitLab Pages: Revert to previous commit
git reset --hard HEAD~1
git push origin main --force

# Vercel: Redeploy previous deployment
vercel --token $VERCEL_TOKEN rollback

# Manual: Restore from backup and redeploy
```

### Emergency Contacts
- **Matrix**: #peacefulrobot:matrix.org
- **Mastodon**: @peacefulrobot@mastodon.social
- **GitLab**: peaceful-robot organization
- **GitHub**: peacefulrobot organization

---

**Last Updated**: 2025-11-25
**Version**: 50068cc - Multi-Platform Deployment System
**Status**: ✅ Production Ready (3/6 platforms active)

For questions or issues, refer to the documentation files or contact the team via Matrix/Mastodon.
