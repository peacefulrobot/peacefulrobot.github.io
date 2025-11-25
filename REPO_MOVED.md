# Repository Moved

The website repository has been moved to a cleaner location:

**Old location:** `~/Development/UpdatePRWithChat/gitlab-test/`  
**New location:** `~/Development/peacefulrobot.com/`

## Repository Structure

```
~/Development/
├── peacefulrobot.com/           # Website repo (GitLab)
│   ├── main branch              # Production (auto-deploys)
│   └── UpdatePRWithChat branch  # Working branch with AI context
│
└── UpdatePRWithChat/            # AI assistant context repo
    ├── .amazonq/                # Amazon Q rules and memory
    ├── TODO.md                  # Project roadmap
    └── ACCOMPLISHED.md          # Session history
```

## Git Remotes

**peacefulrobot.com repo:**
- GitLab: `git@gitlab.com:peaceful-robot/peacefulrobot.com.git`

## Workflow

1. Work in `~/Development/peacefulrobot.com/` on UpdatePRWithChat branch
2. Make changes, commit, push to GitLab
3. GitLab CI/CD auto-deploys to GitLab Pages
4. Merge to main when ready for production

## Current Branch

You are on: `UpdatePRWithChat` branch

Switch to site repo:
```bash
cd ~/Development/peacefulrobot.com
```
