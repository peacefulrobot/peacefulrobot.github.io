# Community Notifications TODO

## Goal
Public notifications for peacefulrobot.com updates that the community can follow.

## Private Notifications (Carlos)
- **Method**: DeltaChat SMTP (already configured in private GitLab CI/CD variables)
- **Recipient**: y2077ada7@nine.testrun.org
- **Status**: Configured privately, not in public repo
- **Security**: SMTP credentials stored as masked GitLab CI/CD variables

## Public Community Notifications (TODO)

### Option 1: Mastodon Bot ⭐ Recommended
**Why**: Open source, federated, no corporate control

**Implementation**:
```yaml
# .gitlab-ci.yml
notify_mastodon:
  script:
    - |
      curl -X POST "https://mastodon.social/api/v1/statuses" \
        -H "Authorization: Bearer ${MASTODON_TOKEN}" \
        -d "status=🚀 peacefulrobot.com deployed! Commit: ${CI_COMMIT_SHORT_SHA}
        
        ${CI_COMMIT_MESSAGE}
        
        View: ${CI_PROJECT_URL}/-/commit/${CI_COMMIT_SHA}"
```

**Setup**:
1. Create Mastodon app at https://mastodon.social/settings/applications
2. Get access token
3. Add `MASTODON_TOKEN` to GitLab CI/CD variables
4. Users follow @peacefulrobot@mastodon.social

**Benefits**:
- ✅ Public, anyone can follow
- ✅ RSS feed available
- ✅ No API limits on free tier
- ✅ Decentralized, no vendor lock-in

### Option 2: Matrix Bot
**Why**: Open protocol, self-hostable, bridges to other platforms

**Implementation**:
```yaml
notify_matrix:
  script:
    - |
      curl -X POST "https://matrix.org/_matrix/client/r0/rooms/${MATRIX_ROOM_ID}/send/m.room.message" \
        -H "Authorization: Bearer ${MATRIX_TOKEN}" \
        -d '{
          "msgtype": "m.text",
          "body": "🚀 Deployment: '"${CI_COMMIT_SHORT_SHA}"'\n\n'"${CI_COMMIT_MESSAGE}"'\n\nView: '"${CI_PROJECT_URL}"'/-/commit/'"${CI_COMMIT_SHA}"'"
        }'
```

**Setup**:
1. Create Matrix account
2. Create public room: #peacefulrobot:matrix.org
3. Get access token
4. Add `MATRIX_TOKEN` and `MATRIX_ROOM_ID` to GitLab CI/CD variables

**Benefits**:
- ✅ Public room, anyone can join
- ✅ Bridges to Discord, Slack, Telegram
- ✅ End-to-end encryption available
- ✅ Self-hostable

### Option 3: RSS Feed
**Why**: Universal, no API needed, works everywhere

**Implementation**:
```yaml
notify_rss:
  script:
    - |
      # Generate RSS feed from git log
      git log --pretty=format:'<item><title>%s</title><description>%b</description><pubDate>%aD</pubDate></item>' -10 > /tmp/items.xml
      
      cat > public/feed.xml <<EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Peaceful Robot Updates</title>
          <link>https://peacefulrobot.com</link>
          <description>Deployment notifications</description>
          $(cat /tmp/items.xml)
        </channel>
      </rss>
      EOF
```

**Benefits**:
- ✅ No API, no tokens, no signup
- ✅ Works with any RSS reader
- ✅ Can be consumed by email, Slack, Discord
- ✅ Static file, no server needed

### Option 4: GitHub Releases
**Why**: Built-in, no setup, email notifications available

**Implementation**:
- Tag releases: `git tag v1.0.0 && git push --tags`
- Users watch repo → Custom → Releases only
- Automatic email notifications from GitHub

**Benefits**:
- ✅ Zero setup
- ✅ Built-in email notifications
- ✅ Changelog generation
- ✅ Download artifacts

## Recommended Approach

**Multi-Channel Strategy**:
1. **Private**: DeltaChat to Carlos (already configured)
2. **Public**: Mastodon bot for community (@peacefulrobot@mastodon.social)
3. **Universal**: RSS feed for maximum compatibility
4. **Developers**: GitHub releases for version tracking

## Implementation Priority

1. ✅ Private DeltaChat notifications (done, configured in GitLab CI/CD variables)
2. ⏳ RSS feed (easiest, no API needed)
3. ⏳ Mastodon bot (best for community engagement)
4. ⏳ Matrix bot (optional, for bridging to other platforms)
5. ⏳ GitHub releases (for version milestones)

## Security Notes

- ✅ Private notifications use masked GitLab CI/CD variables
- ✅ No credentials in public repo
- ✅ Public notifications use public channels (Mastodon, RSS)
- ✅ Tokens stored securely in GitLab CI/CD settings
- ✅ SMTP credentials never exposed in logs or code

## Next Steps

1. Decide which public notification channels to implement
2. Create Mastodon app and get token
3. Generate RSS feed from git log
4. Test notifications on next deployment
5. Announce notification channels on website
