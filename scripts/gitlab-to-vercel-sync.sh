#!/bin/bash

# GitLab to Vercel Sync Script
# Synchronizes content from GitLab content repository to Vercel

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
CONTENT_REPO_URL="https://gitlab.com/peaceful-robot/peacefulrobot.com.git"
TEMP_DIR="temp_gitlab_vercel_sync"
VERCEL_TOKEN="${VERCEL_TOKEN}"

# Validate Vercel token
if [ -z "$VERCEL_TOKEN" ]; then
    log_error "VERCEL_TOKEN not configured"
    exit 1
fi

# Clone GitLab content repository
log_info "Cloning GitLab content repository..."
rm -rf "$TEMP_DIR"
git clone "https://oauth2:$CONTENT_REPO_TOKEN@$CONTENT_REPO_URL" "$TEMP_DIR"

if [ ! -f "$TEMP_DIR/index.html" ]; then
    log_error "index.html not found in GitLab repository"
    exit 1
fi

# Validate content
log_info "Validating GitLab content..."
cd "$TEMP_DIR"

# Check version
if grep -q "Version 50069cc" index.html; then
    log_success "GitLab content validated - Version 50069cc confirmed"
else
    log_warning "Expected Version 50069cc, checking actual version..."
    grep "Version.*50069cc" index.html || echo "Version check:"
fi

# Copy to parent directory for Vercel deployment
log_info "Preparing content for Vercel deployment..."
cp index.html ../vercel-deploy.html
cp -r . ../ 2>/dev/null || true

# Deploy to Vercel
log_info "Deploying to Vercel..."
cd ..
cp index.html vercel-deploy.html

# Create Vercel configuration if not exists
if [ ! -f "vercel.json" ]; then
    log_info "Creating Vercel configuration..."
    cat > vercel.json << 'EOF'
{
  "version": 2,
  "builds": [
    {
      "src": "index.html",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
EOF
fi

# Deploy to Vercel
log_info "Triggering Vercel deployment..."
vercel --token $VERCEL_TOKEN --prod --yes

# Verify deployment
log_info "Verifying Vercel deployment..."
sleep 5
curl -s https://peacefulrobot-github-io.vercel.app/ | grep -q "Version 50069cc"

if [ $? -eq 0 ]; then
    log_success "Vercel deployment successful - Version 50069cc confirmed"
else
    log_error "Vercel deployment may have failed - Version 50069cc not found"
    exit 1
fi

# Cleanup
log_info "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"
rm -f vercel-deploy.html

log_success "GitLab to Vercel sync completed successfully!"