# TODO: Multi-Platform GitOps Setup

## Current Issue
- peacefulrobot.com shows old content (missing Mastodon link, Multi-Platform marker)
- Vercel app URL (peacefulrobot-github-io.vercel.app) has NEW content ✓
- DNS cache or pointing to wrong Vercel instance

## Current Architecture (Has Single Point of Failure)
- GitLab = source of truth (open source)
- GitHub = mirror (SPOF - if GitHub down, Vercel can't deploy)
- Vercel = serves peacefulrobot.com (depends on GitHub)
- GitLab Pages = not being used

## Next Step: Eliminate Single Point of Failure
**Point peacefulrobot.com directly to GitLab Pages**

1. Make GitLab project public (currently private)
2. Verify GitLab Pages is live at: https://jrw2.gitlab.io/peacefulrobot-github-io/
3. Update GoDaddy DNS A record from Vercel IP to GitLab Pages IP
4. Result: GitLab = source + hosting (no GitHub dependency)
5. Keep GitHub + Vercel as backups

## Alternative: Fix Current Vercel Setup
- Check GoDaddy DNS A record points to correct Vercel IP (76.76.21.98 or 216.198.79.1)
- Clear DNS cache
- Wait for propagation

## Future Enhancements

### Notification Channel for Changes
**Goal**: Create automated notifications for website/infrastructure changes in a digested format

**Options**:
1. **Matrix Bot** - Post to #peacefulrobot:matrix.org room
   - GitLab CI/CD webhook → Matrix API
   - Daily/weekly digest of commits, deployments, issues
   
2. **Mastodon Bot** - Post to @peacefulrobot@mastodon.social
   - GitLab CI/CD webhook → Mastodon API
   - Automated toots for major changes (releases, infrastructure updates)
   - Use content warnings for technical details

**Implementation Ideas**:
- Python script in `.gitlab-ci.yml` to post notifications
- Digest format: "Weekly Update: 5 commits, 2 deployments, 1 DNS change"
- Link to detailed changelog/commit history
- Store bot credentials in GitLab CI/CD variables

## Files Modified
- `/home/jrw_a/Development/UpdatePRWithChat/peacefulrobot.github.io/index.html` - added "Multi-Platform ✅" and Mastodon link
- Commit: c823630 "Test: Multi-platform deploy"
