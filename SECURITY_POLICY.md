# Security Policy

## Commitment

**Privacy, safety, and security are ALWAYS prioritized in every action.**

This project follows strict security practices to protect sensitive information and maintain the integrity of the codebase.

## Security Checklist (Every Session)

Before any commit, the following checks are performed:

- [ ] No credentials in code (API keys, passwords, tokens)
- [ ] No sensitive files tracked (.env, .pem, .key, .log)
- [ ] No personal info in public docs (emails, names)
- [ ] .gitignore properly configured
- [ ] CI/CD variables used for all secrets
- [ ] Both GitHub and GitLab repos audited

## What We Always Do

### 1. Before Any Commit
- Scan for credentials (API keys, passwords, tokens)
- Check for email addresses and personal information
- Verify .gitignore excludes sensitive files
- Confirm no .env, .pem, .key, .log files are tracked
- Run security audit on both repositories

### 2. When Writing Code
- Use environment variables for all secrets
- Never hardcode credentials
- Use masked CI/CD variables (GitLab/GitHub Secrets)
- Document security requirements clearly
- Follow principle of least privilege

### 3. When Creating Documentation
- Use placeholders: `<your-email>`, `<api-key>`, `<token>`
- Never include real email addresses or names
- Mark sensitive sections clearly
- Provide private setup instructions separately
- Keep public docs generic and safe

### 4. When Pushing Changes
- Double-check what's being committed
- Verify both GitHub and GitLab are clean
- Run comprehensive security audit
- Alert if anything suspicious is found
- Stop and ask before committing anything questionable

## Security Practices

### Credential Management
- **Never commit**: API keys, passwords, tokens, secrets
- **Always use**: Environment variables, CI/CD variables
- **Store securely**: GitLab CI/CD Variables (masked), GitHub Secrets
- **Example files**: Use `.env.example` with placeholders only

### File Protection
```bash
# Always in .gitignore
.env
*.log
*.pem
*.key
*.crt
__pycache__/
.venv/
```

### Code Review
Every change undergoes security review:
1. Scan for hardcoded secrets
2. Check for sensitive file patterns
3. Verify personal information is removed
4. Confirm .gitignore coverage
5. Validate environment variable usage

## Incident Response

If sensitive information is accidentally committed:

1. **Immediate Action**:
   - Remove from all files
   - Commit removal immediately
   - Push to both GitHub and GitLab

2. **Credential Rotation**:
   - Revoke exposed credentials immediately
   - Generate new credentials
   - Update in secure locations only (CI/CD variables)

3. **Verification**:
   - Run full security audit
   - Check git history for exposure
   - Verify both repositories are clean

## Security Audit Commands

```bash
# Check for credentials
git grep -iE "(password|api[_-]?key|secret|token)" | grep -v ".md" | grep -v "example"

# Check for sensitive files
git ls-files | grep -E "(\.env$|\.pem$|\.key$|\.log$)"

# Check for email addresses
git grep -E "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" | grep -v "example.com"

# Check .gitignore coverage
cat .gitignore | grep -E "(\.env|\.log|\.pem|\.key)"
```

## Reporting Security Issues

If you discover a security vulnerability:

1. **Do NOT** open a public issue
2. **Do NOT** commit the vulnerability details
3. Contact the maintainers privately
4. Provide details of the vulnerability
5. Allow time for remediation before disclosure

## Compliance

This project follows:
- **Zero Trust Security**: Never trust, always verify
- **Principle of Least Privilege**: Minimal access required
- **Defense in Depth**: Multiple layers of security
- **Secure by Default**: Security built-in, not bolted-on

## Security Tools

- `.gitignore` - Prevent sensitive files from being tracked
- GitLab CI/CD Variables - Secure credential storage (masked)
- GitHub Secrets - Secure credential storage (encrypted)
- Security audit scripts - Automated vulnerability scanning

## Updates

This security policy is reviewed and updated regularly to reflect best practices and lessons learned.

**Last Updated**: 2025-01-10

---

**Remember**: If in doubt, ask before committing. Privacy, safety, and security are non-negotiable.
