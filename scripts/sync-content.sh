#!/bin/bash

# Content Synchronization Script
# Syncs content from content repository to infrastructure repository

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
CONTENT_REPO_URL="${CONTENT_REPO_URL:-https://gitlab.com/peaceful-robot/peacefulrobot.com.git}"
CONTENT_REPO_TOKEN="${CONTENT_REPO_TOKEN}"
TEMP_DIR="temp_content_sync"
SYNC_LOG="sync.log"
BACKUP_DIR="content_backup"

# Initialize sync logging
init_sync_log() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    cat > $SYNC_LOG << EOF
Content Synchronization Log
==========================
Started: $timestamp
Content Repository: $CONTENT_REPO_URL
EOF
}

log_sync_step() {
    echo "$1" | tee -a $SYNC_LOG
}

# Clone content repository
clone_content_repo() {
    log_info "Cloning content repository..."
    
    if [ -z "$CONTENT_REPO_TOKEN" ]; then
        log_error "CONTENT_REPO_TOKEN not configured"
        return 1
    fi
    
    # Remove existing temp directory
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    
    # Clone repository using token
    git clone "https://oauth2:$CONTENT_REPO_TOKEN@$CONTENT_REPO_URL" "$TEMP_DIR"
    
    if [ ! -d "$TEMP_DIR" ]; then
        log_error "Failed to clone content repository"
        return 1
    fi
    
    log_success "Successfully cloned content repository"
    log_sync_step "Content repository cloned successfully"
}

# Validate cloned content
validate_content() {
    log_info "Validating cloned content..."
    
    cd "$TEMP_DIR"
    
    # Check if index.html exists
    if [ ! -f "index.html" ]; then
        log_error "index.html not found in content repository"
        log_sync_step "ERROR: index.html not found in content repository"
        return 1
    fi
    
    # Check if index.html has content
    if [ ! -s "index.html" ]; then
        log_error "index.html is empty in content repository"
        log_sync_step "ERROR: index.html is empty in content repository"
        return 1
    fi
    
    # Get repository information
    local commit_hash=$(git rev-parse HEAD)
    local branch=$(git rev-parse --abbrev-ref HEAD)
    local commit_message=$(git log -1 --pretty=%B)
    
    log_info "Repository information:"
    log_info "  Branch: $branch"
    log_info "  Commit: $commit_hash"
    log_info "  Message: $commit_message"
    
    log_sync_step "Content validated successfully"
    log_sync_step "Branch: $branch, Commit: $commit_hash"
    
    # Check for security headers
    log_info "Checking for security headers..."
    if grep -q "Content-Security-Policy" index.html; then
        log_success "✓ Content-Security-Policy header found"
    else
        log_warning "⚠ Content-Security-Policy header missing"
    fi
    
    if grep -q "X-Frame-Options" index.html; then
        log_success "✓ X-Frame-Options header found"
    else
        log_warning "⚠ X-Frame-Options header missing"
    fi
    
    return 0
}

# Backup current content
backup_current_content() {
    log_info "Creating backup of current content..."
    
    local backup_timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/content_backup_$backup_timestamp"
    
    mkdir -p "$backup_path"
    
    if [ -f "index.html" ]; then
        cp index.html "$backup_path/"
        log_success "Current index.html backed up to $backup_path"
    fi
    
    log_sync_step "Backup created: $backup_path"
}

# Sync content files
sync_content_files() {
    log_info "Synchronizing content files..."
    
    cd "$TEMP_DIR"
    
    # List of files to sync (update as needed)
    local files_to_sync=("index.html" "README.md" "CNAME")
    
    for file in "${files_to_sync[@]}"; do
        if [ -f "$file" ]; then
            log_info "Syncing $file..."
            cp "$file" "../"
            log_sync_step "Synced: $file"
        else
            log_info "$file not found in content repository, skipping"
            log_sync_step "Skipped: $file (not found)"
        fi
    done
    
    # Sync all files except .git and CI/CD configs
    log_info "Syncing additional files..."
    rsync -av --exclude='.git/' --exclude='.gitlab-ci.yml' --exclude='.github/' --exclude='*.md' . "../" 2>/dev/null || true
    
    log_success "Content files synchronized"
    log_sync_step "All content files synchronized"
}

# Update repository and commit changes
commit_sync_changes() {
    log_info "Committing synchronization changes..."
    
    cd ..
    
    # Check if there are changes to commit
    if git diff --quiet; then
        log_info "No changes to commit"
        log_sync_step "No changes to commit"
        return 0
    fi
    
    # Add all changes
    git add .
    
    # Create commit message
    local commit_message="Sync content from peaceful-robot/peacefulrobot.com

Automated content synchronization via GitLab CI/CD
$(date -u +"%Y-%m-%d %H:%M:%S UTC")

Changes synced from content repository"
    
    # Commit changes
    git commit -m "$commit_message"
    
    log_success "Changes committed to repository"
    log_sync_step "Changes committed: $(git log -1 --pretty=%H)"
}

# Push changes if not in CI environment
push_changes() {
    # Only push if not in GitLab CI environment or if explicitly configured
    if [ -z "$CI" ] || [ "$AUTO_PUSH" = "true" ]; then
        log_info "Pushing changes to remote repository..."
        
        if git push origin main; then
            log_success "Changes pushed to remote repository"
            log_sync_step "Changes pushed to remote repository"
        else
            log_warning "Failed to push changes (this is normal in CI environment)"
            log_sync_step "Failed to push changes"
        fi
    else
        log_info "In CI environment, not pushing changes"
        log_sync_step "CI environment detected, skipping push"
    fi
}

# Generate sync status report
generate_sync_report() {
    log_info "Generating synchronization report..."
    
    local end_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local report_file="sync_report.json"
    
    # Generate JSON report
    cat > "$report_file" << EOF
{
  "sync_id": "$(date +%s)",
  "started_at": "$(grep "^Started:" $SYNC_LOG | cut -d: -f2- | xargs)",
  "completed_at": "$end_timestamp",
  "status": "completed",
  "content_repository": "$CONTENT_REPO_URL",
  "content_commit": "$(cd $TEMP_DIR && git rev-parse HEAD 2>/dev/null || echo "unknown")",
  "files_synced": $(grep "^Synced:" $SYNC_LOG | wc -l),
  "files_skipped": $(grep "^Skipped:" $SYNC_LOG | wc -l),
  "backup_created": "$(ls -t $BACKUP_DIR/ | head -1 2>/dev/null || echo "none")"
}
EOF
    
    log_success "Sync report generated: $report_file"
    
    # Display summary
    log_info "Sync Summary:"
    log_info "  Status: completed"
    log_info "  Files synced: $(grep "^Synced:" $SYNC_LOG | wc -l)"
    log_info "  Files skipped: $(grep "^Skipped:" $SYNC_LOG | wc -l)"
    log_info "  Backup: $(ls -t $BACKUP_DIR/ | head -1 2>/dev/null || echo "none")"
    
    # Return the report file path for CI pipeline
    echo "$report_file"
}

# Cleanup temporary files
cleanup() {
    log_info "Cleaning up temporary files..."
    
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_info "Removed temporary directory: $TEMP_DIR"
    fi
    
    # Keep logs for CI artifacts
    if [ -n "$CI" ]; then
        log_info "Keeping logs and reports in CI environment"
    else
        rm -f "$SYNC_LOG"
        rm -f "$report_file" 2>/dev/null || true
    fi
}

# Main synchronization function
main() {
    log_info "Starting content synchronization..."
    log_info "Content repository: $CONTENT_REPO_URL"
    
    # Initialize logging
    init_sync_log
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Step 1: Clone content repository
    if ! clone_content_repo; then
        log_error "Failed to clone content repository"
        exit 1
    fi
    
    # Step 2: Validate content
    if ! validate_content; then
        log_error "Content validation failed"
        exit 1
    fi
    
    # Step 3: Backup current content
    backup_current_content
    
    # Step 4: Sync content files
    sync_content_files
    
    # Step 5: Commit changes
    commit_sync_changes
    
    # Step 6: Push changes (if not in CI)
    push_changes
    
    # Step 7: Generate report
    local report_file=$(generate_sync_report)
    
    # Step 8: Cleanup
    cleanup
    
    log_success "Content synchronization completed successfully!"
    log_info "Sync report: $report_file"
    log_info "Sync log: $SYNC_LOG"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo "Synchronizes content from content repository to infrastructure repository"
        echo ""
        echo "Environment Variables:"
        echo "  CONTENT_REPO_URL     - Content repository URL"
        echo "  CONTENT_REPO_TOKEN   - Access token for content repository"
        echo "  AUTO_PUSH           - Set to 'true' to auto-push in CI"
        echo ""
        echo "Examples:"
        echo "  $0                    # Run with default settings"
        echo "  CONTENT_REPO_URL=https://gitlab.com/group/repo.git $0"
        exit 0
        ;;
    --validate-only)
        clone_content_repo
        validate_content
        cleanup
        ;;
    *)
        main "$@"
        ;;
esac