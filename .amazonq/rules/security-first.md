# SECURITY FIRST - MANDATORY FOR ALL AI ASSISTANTS

## 🔒 CRITICAL: READ THIS FIRST

**Privacy, safety, and security are ALWAYS prioritized in EVERY action.**

This rule applies to ALL AI assistants working on this project, in every session, without exception.

## Pre-Commit Security Checklist (MANDATORY)

Before ANY commit, you MUST verify:

- [ ] No credentials in code (API keys, passwords, tokens, secrets)
- [ ] No sensitive files tracked (.env, .pem, .key, .log, id_rsa)
- [ ] No personal info in public docs (email addresses, names, phone numbers)
- [ ] .gitignore properly configured and covers all sensitive patterns
- [ ] CI/CD variables used for ALL secrets (never hardcoded)
- [ ] Both GitHub AND GitLab repos audited for security

## Security Rules (NON-NEGOTIABLE)

### 1. Credentials
- ❌ NEVER hardcode: API keys, passwords, tokens, secrets
- ✅ ALWAYS use: Environment variables, CI/CD variables
- ✅ Store in: GitLab CI/CD Variables (masked), GitHub Secrets (encrypted)
- ✅ Examples: Use `.env.example` with `<placeholder>` values only

### 2. Personal Information
- ❌ NEVER commit: Email addresses, names, phone numbers, addresses
- ✅ ALWAYS use: Placeholders like `<your-email>`, `<name>`, `<contact>`
- ✅ Keep private: Personal identifiers in CI/CD variables only

### 3. Sensitive Files
```bash
# MUST be in .gitignore
.env
*.log
*.pem
*.key
*.crt
*.p12
*.pfx
id_rsa*
__pycache__/
.venv/
```

### 4. Before Every Commit
Run these checks:
```bash
# Check for credentials
git grep -iE "(password|api[_-]?key|secret|token)" | grep -v ".md" | grep -v "example"

# Check for sensitive files
git ls-files | grep -E "(\.env$|\.pem$|\.key$|\.log$)"

# Check for email addresses
git grep -E "[a-zA-Z0-9._%+-]+@" | grep -v "example.com" | grep -v "@v[0-9]"

# Verify .gitignore
cat .gitignore | grep -E "(\.env|\.log|\.pem|\.key)"
```

## What To Do

### When Writing Code
1. Use `os.getenv('VAR_NAME')` for secrets
2. Never use `password = "actual_password"`
3. Document required environment variables
4. Provide `.env.example` with placeholders

### When Creating Docs
1. Use `<your-api-key>` not actual keys
2. Use `<your-email>` not real emails
3. Use `<your-name>` not real names
4. Mark sensitive sections clearly

### When Pushing
1. Run security audit FIRST
2. Verify BOTH repos (GitHub + GitLab)
3. Stop if ANYTHING suspicious found
4. Ask user before committing questionable content

## Incident Response

If sensitive info is accidentally committed:

1. **STOP IMMEDIATELY**
2. Remove from all files
3. Commit removal with clear message
4. Push to both GitHub and GitLab
5. Alert user to rotate credentials
6. Verify git history is clean

## Enforcement

- This rule is **MANDATORY** for all AI assistants
- Violations require immediate correction
- Security takes precedence over all other tasks
- When in doubt, ASK before committing

## Reference

Full security policy: `SECURITY_POLICY.md`

---

**REMEMBER**: Privacy, safety, and security are NON-NEGOTIABLE. Always verify before committing.
