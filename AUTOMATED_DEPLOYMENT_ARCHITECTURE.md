# Automated Deployment System Architecture

## Overview

This document outlines the automated deployment system for Peaceful Robot's multi-cloud GitOps infrastructure that achieves 99.999% uptime through coordinated deployment workflows across multiple repositories and cloud providers.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTENT SOURCE                               │
│          peaceful-robot/peacefulrobot.com                       │
│                      (Single Source of Truth)                   │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      │ Webhook Trigger
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                INFRASTRUCTURE COORDINATOR                       │
│              peacefulrobot-infra (This Repository)              │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   GitLab CI     │  │  GitHub Actions │  │  Webhook Server │  │
│  │   (Primary)     │  │  (Cross-Repo)   │  │  (Triggers)     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────┬───────────────────────────────────────────┘
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   VERCEL        │ │   NETLIFY       │ │  GITLAB PAGES   │
│   (Primary)     │ │   (Backup)      │ │  (Fallback)     │
└─────────────────┘ └─────────────────┘ └─────────────────┘
          │                   │                   │
          ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│     AWS S3      │ │     GCP         │ │    AZURE        │
│   (Territory)   │ │   FIREBASE      │ │  STATIC APPS    │
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

## Components

### 1. Content Repository (Source)
- **Repository**: `peaceful-robot/peacefulrobot.com`
- **Purpose**: Single source of truth for all website content
- **Triggers**: Pushes to main branch trigger infrastructure sync

### 2. Infrastructure Repository (Coordinator)
- **Repository**: `peacefulrobot-infra` (this repository)
- **Purpose**: Manages deployment configuration and orchestration
- **Components**:
  - GitLab CI pipeline for cross-repository content sync
  - GitHub Actions for multi-cloud deployments
  - Webhook endpoints for real-time synchronization

### 3. Deployment Platforms

#### Primary Platforms (Immediate Deployment)
- **Vercel**: Primary hosting with 100GB/month free tier
- **Netlify**: Backup hosting with 100GB/month free tier  
- **GitLab Pages**: Fallback hosting (unlimited free)

#### Extended Platforms (GitOps Phase 2)
- **AWS S3 + CloudFront**: Territory-specific deployment (50GB/month free)
- **GCP Firebase**: Google Cloud deployment (10GB storage, 360MB/day transfer)
- **Azure Static Web Apps**: Microsoft deployment (100GB/month free)

### 4. Load Balancing & Failover
- **Cloudflare**: DNS management and load balancing
- **Health Checks**: 60-second intervals with automatic failover
- **Uptime Target**: 99.999% (5.26 minutes downtime/year)

## Workflow Design

### 1. Content Synchronization Workflow

```
Content Push → Webhook Trigger → Infrastructure Sync → Multi-Platform Deploy
```

**Step-by-Step Process**:
1. Content pushed to `peaceful-robot/peacefulrobot.com`
2. Webhook triggers infrastructure repository
3. GitLab CI pulls latest content from content repository
4. Content validated and prepared for deployment
5. Deployment triggered to all configured platforms
6. Health checks verify deployment success
7. Load balancer updated with new endpoints

### 2. Cross-Repository Synchronization

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

deploy_all:
  stage: deploy
  script:
    - ./scripts/deploy-to-all-platforms.sh
  needs: ["sync_content"]
```

#### GitHub Actions (Cross-Repository)
```yaml
# Enhanced .github/workflows/multi-cloud-deploy.yml
triggered_by:
  repository_dispatch:
    types: [content-updated]

jobs:
  sync-and-deploy:
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

#### Content Repository Webhooks
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

### 1. Repository Access
- **Personal Access Tokens**: For cross-repository operations
- **Deploy Keys**: SSH-based access for secure cloning
- **GitHub Secrets**: Encrypted storage of credentials

### 2. Platform Authentication
```yaml
# Environment Variables
VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

## Monitoring & Alerting

### 1. Uptime Monitoring
- **UptimeRobot**: 50 free monitors for health checks
- **Check Interval**: 5 minutes per endpoint
- **Alert Threshold**: 2 consecutive failures

### 2. Deployment Monitoring
- **GitLab CI**: Pipeline status tracking
- **GitHub Actions**: Workflow monitoring
- **Platform Status**: Vercel, Netlify, GitLab Pages APIs

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
- **Git-based Rollback**: Revert to previous content commit
- **Platform Rollback**: Use platform-specific rollback features
- **DNS Rollback**: Cloudflare traffic steering reversal

### 3. Recovery Process
```
Failure Detected → Health Check Failed → Automatic Failover → Alert Sent
     ↓
Recovery Detected → Health Check Passes → Gradual Traffic Restore → Status Update
```

## Implementation Phases

### Phase 1: Core Infrastructure (Current)
- ✅ GitLab CI basic deployment
- ✅ GitHub Actions for multi-cloud
- ⏳ Content synchronization automation
- ⏳ Cross-repository webhooks

### Phase 2: Enhanced GitOps
- ⏳ Automated content pulling from content repo
- ⏳ Multi-platform deployment coordination
- ⏳ Health check integration
- ⏳ Alert system implementation

### Phase 3: Advanced Features
- ⏳ Cloudflare load balancing configuration
- ⏳ AWS/GCP/Azure integration
- ⏳ Advanced monitoring dashboard
- ⏳ Automated testing integration

## Cost Analysis

### Current Infrastructure
- **GitLab Pages**: $0 (unlimited)
- **GitHub Actions**: $0 (2000 minutes/month)
- **Vercel**: $0 (Hobby plan - 100GB bandwidth)
- **Netlify**: $0 (Starter plan - 100GB bandwidth)
- **Cloudflare**: $0 (Free tier)

### Extended Infrastructure
- **AWS S3 + CloudFront**: $0 (50GB/month free tier)
- **GCP Firebase**: $0 (10GB storage + 360MB/day transfer)
- **Azure Static Web Apps**: $0 (100GB/month free)

**Total Monthly Cost**: $0
**Uptime Target**: 99.999% (5.26 minutes downtime/year)

## Next Steps

1. **Immediate**: Implement content synchronization between repositories
2. **Short-term**: Set up webhook triggers and cross-repository coordination
3. **Medium-term**: Configure Cloudflare load balancing and health checks
4. **Long-term**: Add AWS/GCP/Azure platforms and advanced monitoring

---

*This architecture implements true GitOps principles with declarative configuration, automated deployment, and continuous reconciliation across multiple cloud providers to achieve maximum uptime at zero cost.*