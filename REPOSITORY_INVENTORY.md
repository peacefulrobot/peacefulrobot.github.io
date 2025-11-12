# Repository Inventory - Peaceful Robot

## Current Repository (This One)
- **URL**: `git@gitlab.com:peaceful-robot/peacefulrobot.com.git`
- **Purpose**: Website content only
- **Status**: ✅ Active, content-only
- **Contains**: HTML, domain verification, static assets

## Related Repositories

### Infrastructure Repository
- **URL**: `git@gitlab.com:peaceful-robot/peacefulrobot-github-io.git`
- **Purpose**: Infrastructure, DNS management, CI/CD, strategy
- **Status**: ⏳ Needs infrastructure files added
- **Should Contain**: 
  - DNS scripts (`update_godaddy_dns.py`)
  - CI/CD pipelines (`.gitlab-ci.yml`)
  - Deployment configs (`vercel.json`, `netlify.toml`)
  - Strategy docs (`TODO.md`, `ACCOMPLISHED.md`)
  - Documentation (`.amazonq/rules/`)

### Potential Mirror/Backup Repositories
- **GitHub**: `peacefulrobot/peacefulrobot.github.io` (if exists)
- **Purpose**: GitHub Pages backup deployment
- **Status**: Unknown - needs verification

## Repository Relationships

```
peaceful-robot/peacefulrobot.com (GitLab)
    ↓ (content source)
peaceful-robot/peacefulrobot-github-io (GitLab)
    ↓ (deploys content to)
    ├── Vercel (peacefulrobot.com)
    ├── GitLab Pages (backup)
    └── Netlify (planned)
```

## Deployment URLs
- **Primary**: https://peacefulrobot.com (Vercel)
- **Backup**: https://peaceful-robot.gitlab.io/peacefulrobot-github-io/
- **Planned**: Netlify URL (TBD)

## Current State
- ✅ Content repo cleaned (this one)
- ⏳ Infrastructure repo needs setup
- ⏳ Deployment pipeline needs configuration
- ⏳ DNS management needs migration