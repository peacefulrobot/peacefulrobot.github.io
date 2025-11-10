# Email Notification Setup

## Overview
Automated email notifications sent to `y2077ada7@nine.testrun.org` on every deployment.

## Configuration

### GitLab CI/CD
**File**: `.gitlab-ci.yml` (notify stage)

**Required Secret**:
1. Go to GitLab project: Settings → CI/CD → Variables
2. Add variable:
   - Key: `MAILGUN_API_KEY`
   - Value: Your Mailgun API key
   - Type: Variable
   - Protected: Yes
   - Masked: Yes

### GitHub Actions
**File**: `.github/workflows/notify.yml`

**Required Secret**:
1. Go to GitHub repo: Settings → Secrets and variables → Actions
2. Add secret:
   - Name: `MAILGUN_API_KEY`
   - Value: Your Mailgun API key

## Mailgun Setup

### Option 1: Free Mailgun Account
1. Sign up at https://www.mailgun.com/
2. Verify email address
3. Get API key from Settings → API Keys
4. Use sandbox domain: `sandboxXXX.mailgun.org`
5. Add `y2077ada7@nine.testrun.org` as authorized recipient

### Option 2: Use testrun.org Domain
If you control testrun.org:
1. Add DNS records for Mailgun
2. Verify domain
3. Get API key
4. No recipient restrictions

## Notification Content

Each deployment triggers an email with:
- Commit hash (short)
- Commit author
- Commit message
- Deployment URLs (GitLab Pages, Vercel, GitHub Pages)
- Link to commit

## Testing

### Test GitLab Notification
```bash
# Push to GitLab
cd peacefulrobot.github.io
git commit --allow-empty -m "Test notification"
git push gitlab master
```

### Test GitHub Notification
```bash
# Push to GitHub
git push origin master
```

## Alternative: Simple curl Notification

If Mailgun is not available, use a simple HTTP POST:

```yaml
# GitLab CI
notify:
  script:
    - |
      curl -X POST "https://ntfy.sh/peacefulrobot" \
        -H "Title: Deployment ${CI_COMMIT_SHORT_SHA}" \
        -d "Deployed to peacefulrobot.com"
```

Then subscribe to https://ntfy.sh/peacefulrobot in your email client.

## Troubleshooting

### Email not received
1. Check GitLab CI/CD logs for errors
2. Verify MAILGUN_API_KEY is set correctly
3. Check Mailgun dashboard for delivery logs
4. Verify recipient email is authorized (sandbox mode)

### API key errors
- Ensure key starts with `key-` or is in format `api:key-xxx`
- Check key has sending permissions
- Verify domain is verified in Mailgun

## Cost
- Mailgun free tier: 5,000 emails/month
- ntfy.sh: Free, unlimited
- Both options: $0/month
