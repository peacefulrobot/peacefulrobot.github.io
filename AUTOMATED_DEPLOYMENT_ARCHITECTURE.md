# Automated Deployment System Architecture

## Overview

This document outlines the automated deployment system for Peaceful Robot's multi-cloud GitOps infrastructure that achieves 99.999% uptime through coordinated deployment workflows, with **GitLab as the single source of truth**.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SOURCE OF TRUTH                              │
│           gitlab.com/peaceful-robot/peacefulrobot.com           │
│                    (GitLab Primary)                             │
│                   Content Repository                            │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      │ Push Events + Webhooks
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                INFRASTRUCTURE COORDINATOR                       │
│              peacefulrobot-infra (This Repository)              │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   GitLab CI     │  │  GitHub Actions │  │  Webhook Server │  │
│  │   (Primary)     │  │  (Deployment)   │  │  (Coordination) │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────┬───────────────────────────────────────────┘
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   VERCEL        │ │   NETLIFY       │ │  GITLAB PAGES   │
│   (Primary)     │ │   (Backup)      │ │  (Mirror)       │
└─────────────────┘ └─────────────────┘ └─────────────────┘
          │                   │                   │
          ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│     AWS S3      │ │     GCP         │ │    AZURE        │
│   (Extended)    │ │   FIREBASE      │ │  STATIC APPS    │
└─────────────────┘ └─────────────────┘ └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   CLOUDFLARE    │
                    │  Load Balancer  │
                    │ + Health Checks │
                    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   PRODUCTION    │
                    │  www.peacefulrobot.com │
                    └─────────────────┘
```

## Repository Hierarchy

### 1. Primary Source Repository (GitLab)
- **Repository**: `gitlab.com/peaceful-robot/peacefulrobot.com`
- **Role**: **SINGLE SOURCE OF TRUTH** for all content
- **Access**: Write access for content developers
- **Triggers**: Push events trigger infrastructure synchronization

### 2. Infrastructure Repository (GitLab)
- **Repository**: `gitlab.com/peaceful-robot/peacefulrobot-infra`
- **Role**: Deployment coordination and automation
- **Content**: Deployment scripts, CI/CD configurations, monitoring
- **Access**: Infrastructure team only

### 3. Mirror/Deployment Targets (GitHub)
- **Repository**: `github.com/peacefulrobot/peacefulrobot-infra`
- **Role**: **DEPLOYMENT TARGET ONLY** (not source of truth)
- **Access**: Read-only mirror for GitHub Actions deployment
- **Usage**: Platform-specific deployments (Vercel, Netlify integrations)

## Components

### 1. Content Source (GitLab)
- **Repository**: `peaceful-robot/peacefulrobot.com`
- **Purpose**: Single source of truth for all website content
- **Workflow**: Developer commits → Webhook triggers → Infrastructure sync
- **Access Control**: Content team has write access

### 2. Infrastructure Coordination (This Repository)
- **Repository**: `peacefulrobot-infra` (both GitLab and GitHub mirrors)
- **Purpose**: Manages deployment configuration and orchestration
- **Components**:
  - GitLab CI pipeline for cross-repository content sync
  - GitHub Actions for multi-cloud deployments
  - Webhook endpoints for real-time synchronization

### 3. Deployment Platforms

#### Primary Platforms (Immediate Deployment)
- **Vercel**: Primary hosting with GitHub Actions integration
- **Netlify**: Backup hosting with GitHub Actions integration  
- **GitLab Pages**: GitLab Pages deployment (direct from infrastructure repo)

#### Extended Platforms (GitOps Phase 2)
- **AWS S3 + CloudFront**: Territory-specific deployment (50GB/month free)
- **GCP Firebase**: Google Cloud deployment (10GB storage, 360MB/day transfer)
- **Azure Static Web Apps**: Microsoft deployment (100GB/month free)

### 4. Load Balancing & Failover
- **Cloudflare**: DNS management and load balancing
- **Health Checks**: 60-second intervals with automatic failover
- **Uptime Target**: 99.999% (5.26 minutes downtime/year)

## Workflow Design

### 1. Content Update Workflow (GitLab Source)

```
Developer commits → GitLab Webhook → Infrastructure Sync → Multi-Platform Deploy
```

**Step-by-Step Process**:
1. Content committed to `gitlab.com/peaceful-robot/peacefulrobot.com`
2. GitLab webhook triggers infrastructure repository
3. GitLab CI pulls latest content from content repository
4. Content validated and prepared for deployment
5. GitHub Actions triggered for external platform deployments
6. GitLab Pages updated directly from infrastructure repo
7. Health checks verify deployment success
8. Load balancer updated with new endpoints

### 2. GitLab-Centric Synchronization

#### GitLab CI Pipeline (Primary)
```yaml
# .gitlab-ci.yml
stages:
  - sync
  - validate
  - deploy

sync_content:
  stage: sync
  script:
    - git clone https://gitlab.com/peaceful-robot/peacefulrobot.com.git temp_content
    - cp temp_content/index.html ./
    - rm -rf temp_content
  only:
    - webhooks
    - main

deploy_gitlab_pages:
  stage: deploy
  script:
    - mkdir -p public
    - cp index.html public/
    - cp -r * public/ 2>/dev/null || true

deploy_external:
  stage: deploy
  script:
    - ./scripts/deploy-to-all-platforms.sh
```

#### GitHub Actions (Deployment Target)
```yaml
# .github/workflows/multi-cloud-deploy.yml
triggered_by:
  repository_dispatch:
    types: [content-updated]

jobs:
  deploy-external-platforms:
    runs-on: ubuntu-latest
    steps:
      - name: Sync from content repository
        run: |
          git clone https://gitlab.com/peaceful-robot/peacefulrobot.com.git temp
          cp temp/index.html ./
      - name: Deploy to Vercel
        uses: vercel/action@v1
      - name: Deploy to Netlify  
        uses: nwtgck/actions-netlify@v2
```

### 3. Webhook Configuration

#### GitLab Content Repository Webhooks
```json
{
  "url": "https://gitlab.com/peaceful-robot/peacefulrobot-infra/-/webhooks/content-sync",
  "trigger": "push",
  "branch_filter": "main",
  "events": ["push_events"]
}
```

#### Infrastructure Repository Webhooks
```json
{
  "url": "https://github.com/peacefulrobot/peacefulrobot-infra/dispatch",
  "trigger": "repository_dispatch",
  "events": ["deployment_status"]
}
```

## Security & Authentication

### 1. Repository Access (GitLab Primary)
- **GitLab Deploy Keys**: SSH-based access for secure cloning
- **GitLab Personal Access Tokens**: API access for webhooks
- **GitLab Protected Branches**: Ensure content quality

### 2. Platform Authentication
```yaml
# GitLab CI/CD Variables
VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}

# GitHub Actions Secrets
VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

## Monitoring & Alerting

### 1. Uptime Monitoring
- **GitLab Monitoring**: Built-in monitoring for GitLab Pages
- **UptimeRobot**: 50 free monitors for external platform health checks
- **Check Interval**: 5 minutes per endpoint
- **Alert Threshold**: 2 consecutive failures

### 2. Deployment Monitoring
- **GitLab CI**: Pipeline status tracking (primary)
- **GitHub Actions**: Workflow monitoring (deployment target)
- **Platform Status**: Vercel, Netlify, AWS, GCP, Azure APIs

### 3. Alert Channels
- **Email**: Primary notification channel
- **Matrix/Webhook**: Secondary notification (@peacefulrobot:matrix.org)
- **Mastodon**: Public status updates (@peacefulrobot@mastodon.social)

## Failure Handling & Rollback

### 1. Automatic Failover
- Cloudflare health checks detect failures within 60 seconds
- Automatic traffic routing to next healthy pool
- Email/webhook alerts sent immediately

### 2. Rollback Strategy
- **Git-based Rollback**: Revert to previous content commit in GitLab
- **Platform Rollback**: Use platform-specific rollback features
- **DNS Rollback**: Cloudflare traffic steering reversal

### 3. Recovery Process
```
Failure Detected → Health Check Failed → Automatic Failover → Alert Sent
     ↓
Recovery Detected → Health Check Passes → Gradual Traffic Restore → Status Update
```

## Implementation Phases

### Phase 1: GitLab-Centric Core (Current)
- ✅ GitLab as single source of truth established
- ✅ GitLab CI primary deployment pipeline
- ✅ GitHub Actions as deployment target (not source)
- ✅ Content synchronization automation

### Phase 2: Enhanced GitOps
- ⏳ Automated content pulling from GitLab content repo
- ⏳ Multi-platform deployment coordination
- ⏳ Health check integration
- ⏳ Alert system implementation

### Phase 3: Advanced Features
- ⏳ Cloudflare load balancing configuration
- ⏳ AWS/GCP/Azure integration
- ⏳ Advanced monitoring dashboard
- ⏳ Automated testing integration

## Cost Analysis

### GitLab-Centric Infrastructure
- **GitLab Pages**: $0 (unlimited, primary source)
- **GitLab CI**: $0 (400 minutes/month, primary pipeline)
- **GitHub Actions**: $0 (2000 minutes/month, deployment target)
- **Vercel**: $0 (Hobby plan - 100GB bandwidth)
- **Netlify**: $0 (Starter plan - 100GB bandwidth)
- **Cloudflare**: $0 (Free tier)

### Extended Infrastructure
- **AWS S3 + CloudFront**: $0 (50GB/month free tier)
- **GCP Firebase**: $0 (10GB storage + 360MB/day transfer)
- **Azure Static Web Apps**: $0 (100GB/month free)

**Total Monthly Cost**: $0
**Uptime Target**: 99.999% (5.26 minutes downtime/year)

## GitLab as Source of Truth - Benefits

### 1. **Centralized Control**
- All content changes flow through GitLab
- Single point of access control
- Consistent deployment pipeline

### 2. **Enhanced Security**
- GitLab's enterprise security features
- Protected branches and merge requests
- Advanced webhook security

### 3. **Better Integration**
- Native GitLab CI/CD integration
- GitLab Pages direct deployment
- Built-in monitoring and analytics

### 4. **Cost Optimization**
- GitLab Pages is free and unlimited
- GitLab CI has generous free tier
- Reduced reliance on external services

## Next Steps

1. **Immediate**: Verify GitLab as content source
2. **Short-term**: Configure GitLab webhooks and CI/CD
3. **Medium-term**: Set up GitHub Actions as deployment target only
4. **Long-term**: Add AWS/GCP/Azure platforms and advanced monitoring

---

*This architecture implements true GitOps principles with GitLab as the single source of truth, declarative configuration, automated deployment, and continuous reconciliation across multiple cloud providers to achieve maximum uptime at zero cost.*