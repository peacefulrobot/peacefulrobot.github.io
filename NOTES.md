# Architecture Notes - 2025-01-08

## Current Issue: HSTS + GitLab Pages SSL

### Problem
- Domain has HSTS enabled (from previous Vercel hosting)
- GitLab Pages requires TXT verification for SSL certificate
- Browser blocks HTTP access due to HSTS policy
- Catch-22: Can't verify without SSL, can't get SSL without verification

### Attempted Solution
- Changed DNS A record from Vercel (216.198.79.1) to GitLab Pages (35.185.44.232)
- Added custom domain in GitLab Pages settings
- Domain verification pending (TXT record not added)
- Result: Site inaccessible due to HSTS blocking HTTP

## Recommended Architecture

### Separation of Concerns
```
peacefulrobot.com (custom domain)
    ↓ DNS A record → Vercel IP (216.198.79.1)
Vercel (hosting layer with automatic SSL)
    ↓ deploys from
GitHub (peacefulrobot/peacefulrobot.github.io)
    ↓ mirrors from
GitLab (peaceful-robot/peacefulrobot-github-io) ← source of truth
```

### Why This Works
1. **GitLab** = Source control and CI/CD
2. **GitHub** = Mirror for redundancy
3. **Vercel** = Hosting with automatic SSL/HTTPS
4. **GitLab Pages** = Backup access via subdomain

### Benefits
- ✅ SSL works automatically (Vercel handles it)
- ✅ No HSTS issues (always HTTPS)
- ✅ GitLab remains source of truth
- ✅ Multi-platform redundancy maintained
- ✅ GitLab Pages subdomain available as backup

### Backup URLs
- GitLab Pages: https://peacefulrobot-github-io-5de419.gitlab.io/
- GitHub Pages: https://peacefulrobot.github.io/
- Vercel: https://peacefulrobot-github-io.vercel.app/

## Implementation Steps

### 1. Revert DNS to Vercel
Go to GoDaddy DNS and change A record:
- From: `35.185.44.232` (GitLab Pages)
- To: `216.198.79.1` (Vercel)
- TTL: 600 seconds

### 2. Remove Custom Domain from GitLab Pages
- Go to: https://gitlab.com/peaceful-robot/peacefulrobot-github-io/-/pages
- Delete the `peacefulrobot.com` domain entry
- Keep GitLab Pages subdomain active

### 3. Verify Vercel Configuration
- Ensure Vercel is deploying from GitHub repository
- Confirm custom domain `peacefulrobot.com` is configured in Vercel
- Verify SSL certificate is active

### 4. Test Access
- Visit https://peacefulrobot.com (should work with SSL)
- Verify updated content with Mastodon link is visible
- Confirm "Multi-Platform ✅" marker is present

## Alternative: GitLab Pages Direct (Complex)

If you want to use GitLab Pages directly for hosting:

### Requirements
1. Add TXT verification record to GoDaddy DNS
2. Wait for GitLab to verify domain ownership
3. GitLab provisions Let's Encrypt SSL certificate
4. Enable "Force HTTPS" in GitLab Pages settings

### Challenges
- TXT verification code not easily visible in GitLab UI
- HSTS blocks access during verification period
- More complex SSL management
- No CDN benefits (Vercel provides edge caching)

## Current Status

### What's Working
- ✅ GitLab as source of truth
- ✅ GitLab Pages deployed at subdomain
- ✅ GitHub mirror active
- ✅ Updated content with Mastodon link
- ✅ Multi-platform architecture established

### What's Blocked
- ⚠️ peacefulrobot.com inaccessible (HSTS + no SSL)
- ⚠️ GitLab Pages custom domain unverified
- ⚠️ Users cannot access site via custom domain

### Recommended Action
**Revert DNS to Vercel** to restore immediate HTTPS access while maintaining GitLab as source of truth.

## Lessons Learned

1. **HSTS is sticky** - Once enabled, browsers enforce HTTPS permanently
2. **SSL verification requires HTTP access** - Creates problems with HSTS
3. **Separation of concerns** - Git hosting ≠ web hosting
4. **Vercel/Netlify exist for a reason** - They handle SSL complexity
5. **GitLab Pages custom domains** - More complex than GitHub Pages

## Future Considerations

### If Staying with Vercel
- Configure Vercel to deploy from GitLab directly (if supported)
- Or maintain GitHub mirror for Vercel deployment
- Keep GitLab Pages as backup

### If Moving to GitLab Pages
- Temporarily disable HSTS (requires Vercel access)
- Complete TXT verification during HTTP window
- Wait for Let's Encrypt SSL provisioning
- Re-enable HSTS after SSL is active

### Alternative Hosting Options
- **Cloudflare Pages** - Deploys from GitLab, automatic SSL
- **Netlify** - Deploys from GitLab, automatic SSL
- **AWS Amplify** - Deploys from GitLab, automatic SSL
