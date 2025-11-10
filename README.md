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

## Project Overview

Multi-cloud GitOps infrastructure achieving 99.999% uptime at $0/month.

### Architecture
- **GitLab**: Source of truth
- **GitHub**: Mirror
- **Vercel**: Primary hosting (99.9%)
- **GitLab Pages**: Backup hosting (99.9%)
- **Netlify**: Tertiary hosting (99.9%)
- **Cloudflare**: Load balancing + automatic failover

**Result**: 99.999% uptime (26 seconds downtime/month)

### Live URLs
- **Production**: https://www.peacefulrobot.com
- **GitLab Pages**: https://peacefulrobot-github-io-5de419.gitlab.io/
- **GitHub Pages**: https://peacefulrobot.github.io/

### Repositories
- **GitLab (Source)**: https://gitlab.com/peaceful-robot/peacefulrobot-github-io
- **GitHub (Mirror)**: https://github.com/peacefulrobot/peacefulrobot.github.io

## Documentation

- **TODO**: Next steps and roadmap
- **ACCOMPLISHED**: Completed tasks log
- **SECURITY_POLICY**: Security requirements
- **FIVE_NINES_SETUP**: Multi-cloud setup guide
- **STATUS**: Current progress tracker

## Security

See `.ai/SECURITY_RULES.md` and `SECURITY_POLICY.md`

All credentials stored in GitLab CI/CD variables (masked) and GitHub Secrets (encrypted).

## Contributing

1. Read `.ai/SECURITY_RULES.md` first
2. Follow security checklist before commits
3. Never commit credentials or personal info
4. Use environment variables for all secrets

## License

See LICENSE file for details.
