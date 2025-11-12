# GitOps Implementation TODO

## Immediate (Fix Version Mismatch)
1. **Configure GitLab CI/CD** to pull content from `peaceful-robot/peacefulrobot.com`
2. **Update Vercel** to deploy from infrastructure repo, not content repo
3. **Sync deployments** so both show same version

## GitOps Implementation (CNCF Principles)

### 1. Single Source of Truth
- ✅ Content repo established
- ⏳ Infrastructure repo pulls from content repo
- ⏳ All deployment configs in infrastructure repo

### 2. Declarative Configuration  
- ⏳ Create `.gitlab-ci.yml` that pulls content + deploys
- ⏳ Add deployment manifests for each platform
- ⏳ Version control all deployment states

### 3. Automated Deployment
- ⏳ CI/CD pipeline: content pull → build → deploy to all platforms
- ⏳ Automated rollback on failure
- ⏳ Health checks and validation

### 4. Continuous Reconciliation
- ⏳ Monitor drift between desired state (Git) and actual state (deployments)
- ⏳ Automatic correction of configuration drift

## Implementation Steps

### Phase 1: Fix Current Issues
1. Update `.gitlab-ci.yml` to pull from content repo
2. Configure Vercel webhook to deploy from infrastructure repo
3. Test synchronized deployments

### Phase 2: Full GitOps
1. Add deployment validation and testing
2. Implement rollback mechanisms  
3. Add monitoring and alerting
4. Document the GitOps workflow

## Files to Create/Update
- `.gitlab-ci.yml` - Main deployment pipeline
- `deploy/` - Platform-specific deployment configs
- `scripts/sync-content.sh` - Content pulling script
- `DEPLOYMENT.md` - GitOps workflow documentation