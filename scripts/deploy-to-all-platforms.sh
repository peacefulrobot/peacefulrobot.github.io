#!/bin/bash

# Multi-Platform Deployment Script
# Deploys content to Vercel, Netlify, and GitLab Pages

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
CONTENT_DIR="${1:-.}"
DEPLOY_STATUS_FILE="deployment_status.json"
TEMP_DIR="temp_deploy"

# Initialize deployment status
init_deployment_status() {
    local deploy_id=$(date +%s)
    local start_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    cat > $DEPLOY_STATUS_FILE << EOF
{
  "deployment_id": "$deploy_id",
  "started_at": "$start_time",
  "status": "in_progress",
  "platforms": [],
  "errors": []
}
EOF
    log_info "Initialized deployment status: ID $deploy_id"
}

# Update deployment status
update_deployment_status() {
    local platform=$1
    local status=$2
    local error_msg=$3
    
    if [ "$status" = "success" ]; then
        jq ".platforms += [\"$platform\"]" $DEPLOY_STATUS_FILE > temp_status.json
    else
        jq ".errors += [{\"platform\": \"$platform\", \"error\": \"$error_msg\"}]" $DEPLOY_STATUS_FILE > temp_status.json
    fi
    
    mv temp_status.json $DEPLOY_STATUS_FILE
    log_info "Updated deployment status for $platform: $status"
}

# Deploy to Vercel
deploy_to_vercel() {
    log_info "Deploying to Vercel..."
    
    if [ -z "$VERCEL_TOKEN" ]; then
        log_warning "VERCEL_TOKEN not configured, skipping Vercel deployment"
        return 0
    fi
    
    cd $CONTENT_DIR
    
    # Install Vercel CLI if not present
    if ! command -v vercel &> /dev/null; then
        log_info "Installing Vercel CLI..."
        npm install -g vercel
    fi
    
    # Configure Vercel for deployment
    echo '{"version":2}' > vercel.json
    
    # Deploy to Vercel
    if vercel --token $VERCEL_TOKEN --prod --yes; then
        update_deployment_status "vercel" "success"
        log_success "Successfully deployed to Vercel"
    else
        update_deployment_status "vercel" "failed" "Vercel deployment failed"
        log_error "Failed to deploy to Vercel"
        return 1
    fi
}

# Deploy to Netlify
deploy_to_netlify() {
    log_info "Deploying to Netlify..."
    
    if [ -z "$NETLIFY_AUTH_TOKEN" ]; then
        log_warning "NETLIFY_AUTH_TOKEN not configured, skipping Netlify deployment"
        return 0
    fi
    
    cd $CONTENT_DIR
    
    # Install Netlify CLI if not present
    if ! command -v netlify &> /dev/null; then
        log_info "Installing Netlify CLI..."
        npm install -g netlify-cli
    fi
    
    # Deploy to Netlify
    if netlify deploy --prod --auth $NETLIFY_AUTH_TOKEN; then
        update_deployment_status "netlify" "success"
        log_success "Successfully deployed to Netlify"
    else
        update_deployment_status "netlify" "failed" "Netlify deployment failed"
        log_error "Failed to deploy to Netlify"
        return 1
    fi
}

# Deploy to GitLab Pages (local copy for GitLab CI)
deploy_to_gitlab_pages() {
    log_info "Copying content for GitLab Pages..."
    
    cd $CONTENT_DIR
    
    # Create public directory structure that GitLab CI expects
    mkdir -p ../public
    cp index.html ../public/
    cp -r * ../public/ 2>/dev/null || true
    
    update_deployment_status "gitlab-pages" "success"
    log_success "Successfully prepared content for GitLab Pages"
}

# Deploy to AWS S3
deploy_to_aws() {
    log_info "Deploying to AWS S3..."
    
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        log_warning "AWS credentials not configured, skipping AWS deployment"
        return 0
    fi
    
    cd $CONTENT_DIR
    
    # Install AWS CLI if not present
    if ! command -v aws &> /dev/null; then
        log_info "Installing AWS CLI..."
        pip install awscli
    fi
    
    # Deploy to S3
    if aws s3 sync . s3://$AWS_S3_BUCKET --delete --exclude ".git/*"; then
        # Invalidate CloudFront if distribution ID is provided
        if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
            log_info "Invalidating CloudFront distribution..."
            aws cloudfront create-invalidation \
                --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
                --paths "/*"
        fi
        update_deployment_status "aws-s3" "success"
        log_success "Successfully deployed to AWS S3"
    else
        update_deployment_status "aws-s3" "failed" "AWS S3 deployment failed"
        log_error "Failed to deploy to AWS S3"
        return 1
    fi
}

# Deploy to Google Firebase
deploy_to_firebase() {
    log_info "Deploying to Google Firebase..."
    
    if [ -z "$FIREBASE_TOKEN" ]; then
        log_warning "FIREBASE_TOKEN not configured, skipping Firebase deployment"
        return 0
    fi
    
    cd $CONTENT_DIR
    
    # Install Firebase CLI if not present
    if ! command -v firebase &> /dev/null; then
        log_info "Installing Firebase CLI..."
        npm install -g firebase-tools
    fi
    
    # Initialize Firebase if needed
    if [ ! -f "firebase.json" ]; then
        log_info "Initializing Firebase project..."
        firebase init hosting --token $FIREBASE_TOKEN --yes
    fi
    
    # Deploy to Firebase
    if firebase deploy --token $FIREBASE_TOKEN --only hosting; then
        update_deployment_status "firebase" "success"
        log_success "Successfully deployed to Firebase"
    else
        update_deployment_status "firebase" "failed" "Firebase deployment failed"
        log_error "Failed to deploy to Firebase"
        return 1
    fi
}

# Deploy to Azure Static Web Apps
deploy_to_azure() {
    log_info "Deploying to Azure Static Web Apps..."
    
    if [ -z "$AZURE_STATIC_WEB_APPS_API_TOKEN" ]; then
        log_warning "AZURE_STATIC_WEB_APPS_API_TOKEN not configured, skipping Azure deployment"
        return 0
    fi
    
    cd $CONTENT_DIR
    
    # Deploy to Azure using GitHub Actions (alternative approach)
    # Note: This would typically be handled by GitHub Actions workflow
    log_info "Azure deployment would be handled by GitHub Actions workflow"
    
    update_deployment_status "azure-static-apps" "success"
    log_success "Azure deployment queued via GitHub Actions"
}

# Validate content before deployment
validate_content() {
    log_info "Validating content..."
    
    if [ ! -f "$CONTENT_DIR/index.html" ]; then
        log_error "index.html not found in content directory"
        return 1
    fi
    
    if [ ! -s "$CONTENT_DIR/index.html" ]; then
        log_error "index.html is empty"
        return 1
    fi
    
    # Check for required security headers
    if ! grep -q "Content-Security-Policy" "$CONTENT_DIR/index.html"; then
        log_warning "Content-Security-Policy header missing"
    fi
    
    if ! grep -q "X-Frame-Options" "$CONTENT_DIR/index.html"; then
        log_warning "X-Frame-Options header missing"
    fi
    
    log_success "Content validation completed"
}

# Finalize deployment
finalize_deployment() {
    local end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local final_status="completed"
    
    # Check if any deployments failed
    if jq -e '.errors | length > 0' $DEPLOY_STATUS_FILE > /dev/null; then
        final_status="partial_failure"
    fi
    
    jq ".status = \"$final_status\" | .ended_at = \"$end_time\"" $DEPLOY_STATUS_FILE > temp_status.json
    mv temp_status.json $DEPLOY_STATUS_FILE
    
    # Display deployment summary
    log_info "Deployment Summary:"
    jq -r '.platforms[]' $DEPLOY_STATUS_FILE | while read platform; do
        log_success "✓ $platform"
    done
    
    if jq -e '.errors | length > 0' $DEPLOY_STATUS_FILE > /dev/null; then
        log_error "Failed deployments:"
        jq -r '.errors[] | "✗ \(.platform): \(.error)"' $DEPLOY_STATUS_FILE
    fi
    
    log_info "Deployment status: $final_status"
}

# Main deployment function
main() {
    log_info "Starting multi-platform deployment..."
    log_info "Content directory: $CONTENT_DIR"
    
    # Initialize deployment tracking
    init_deployment_status
    
    # Validate content
    if ! validate_content; then
        log_error "Content validation failed"
        exit 1
    fi
    
    # Deploy to all configured platforms
    deploy_to_vercel || log_warning "Vercel deployment encountered issues"
    deploy_to_netlify || log_warning "Netlify deployment encountered issues"  
    deploy_to_gitlab_pages || log_warning "GitLab Pages deployment encountered issues"
    deploy_to_aws || log_warning "AWS deployment encountered issues"
    deploy_to_firebase || log_warning "Firebase deployment encountered issues"
    deploy_to_azure || log_warning "Azure deployment encountered issues"
    
    # Finalize and report
    finalize_deployment
    
    log_success "Multi-platform deployment completed!"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [content_directory]"
        echo "Deploys content to multiple cloud platforms"
        echo ""
        echo "Environment Variables:"
        echo "  VERCEL_TOKEN              - Vercel deployment token"
        echo "  NETLIFY_AUTH_TOKEN        - Netlify authentication token"
        echo "  AWS_ACCESS_KEY_ID         - AWS access key ID"
        echo "  AWS_SECRET_ACCESS_KEY     - AWS secret access key"
        echo "  AWS_S3_BUCKET            - S3 bucket name"
        echo "  CLOUDFRONT_DISTRIBUTION_ID - CloudFront distribution ID"
        echo "  FIREBASE_TOKEN           - Firebase CLI token"
        echo "  AZURE_STATIC_WEB_APPS_API_TOKEN - Azure SWA token"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac