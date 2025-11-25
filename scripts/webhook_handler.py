#!/usr/bin/env python3
"""
Webhook Handler for Cross-Repository Deployment Coordination

This script handles webhooks from the content repository and triggers
automated deployment workflows in the infrastructure repository.
"""

import os
import json
import logging
import hmac
import hashlib
from datetime import datetime
from flask import Flask, request, jsonify
import requests

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('webhook.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Configuration
GITLAB_WEBHOOK_SECRET = os.getenv('GITLAB_WEBHOOK_SECRET', '')
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN', '')
INFRA_REPO_OWNER = os.getenv('INFRA_REPO_OWNER', 'peacefulrobot')
INFRA_REPO_NAME = os.getenv('INFRA_REPO_NAME', 'peacefulrobot-infra')
GITLAB_TOKEN = os.getenv('GITLAB_TOKEN', '')
GITLAB_PROJECT_ID = os.getenv('GITLAB_PROJECT_ID', '')

class WebhookHandler:
    def __init__(self):
        self.webhook_events = []
        
    def verify_gitlab_signature(self, payload, signature):
        """Verify GitLab webhook signature"""
        if not GITLAB_WEBHOOK_SECRET:
            logger.warning("No webhook secret configured")
            return True  # Allow in development
            
        expected_signature = hmac.new(
            GITLAB_WEBHOOK_SECRET.encode(),
            payload,
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(f'sha256={expected_signature}', signature)
    
    def handle_gitlab_webhook(self, data):
        """Handle GitLab webhook events"""
        event_type = data.get('object_kind', '')
        logger.info(f"Received GitLab webhook: {event_type}")
        
        if event_type == 'push':
            return self.handle_gitlab_push(data)
        elif event_type == 'pipeline':
            return self.handle_gitlab_pipeline(data)
        else:
            logger.info(f"Unhandled GitLab event type: {event_type}")
            return {'status': 'ignored', 'message': f'Event type {event_type} not handled'}
    
    def handle_gitlab_push(self, data):
        """Handle GitLab push events (content updates)"""
        ref = data.get('ref', '')
        commits = data.get('commits', [])
        
        logger.info(f"Push to {ref} with {len(commits)} commits")
        
        # Only trigger on main branch
        if ref != 'refs/heads/main':
            logger.info(f"Ignoring push to branch {ref}")
            return {'status': 'ignored', 'message': f'Not main branch: {ref}'}
        
        # Get latest commit info
        if commits:
            latest_commit = commits[-1]
            commit_id = latest_commit.get('id', '')
            commit_message = latest_commit.get('message', '')
            author = latest_commit.get('author', {}).get('name', 'Unknown')
        else:
            commit_id = data.get('after', '')
            commit_message = 'No commit message'
            author = 'Unknown'
        
        # Trigger GitHub Actions workflow
        success = self.trigger_github_deployment({
            'event_type': 'content_updated',
            'source': 'gitlab_push',
            'commit_id': commit_id,
            'commit_message': commit_message,
            'author': author,
            'branch': ref,
            'timestamp': datetime.utcnow().isoformat()
        })
        
        if success:
            logger.info(f"Successfully triggered deployment for commit {commit_id}")
            return {
                'status': 'triggered',
                'message': 'Deployment triggered successfully',
                'commit_id': commit_id
            }
        else:
            logger.error(f"Failed to trigger deployment for commit {commit_id}")
            return {
                'status': 'error',
                'message': 'Failed to trigger deployment',
                'commit_id': commit_id
            }
    
    def handle_gitlab_pipeline(self, data):
        """Handle GitLab pipeline events"""
        object_attributes = data.get('object_attributes', {})
        status = object_attributes.get('status', '')
        ref = object_attributes.get('ref', '')
        
        logger.info(f"Pipeline {status} on {ref}")
        
        if status == 'success' and ref == 'main':
            # Notify GitHub that GitLab deployment completed
            return self.notify_github_completion({
                'source': 'gitlab_pipeline',
                'status': 'success',
                'ref': ref,
                'timestamp': datetime.utcnow().isoformat()
            })
        elif status == 'failed':
            # Notify GitHub about deployment failure
            return self.notify_github_completion({
                'source': 'gitlab_pipeline',
                'status': 'failed',
                'ref': ref,
                'timestamp': datetime.utcnow().isoformat()
            })
        
        return {'status': 'ignored', 'message': f'Pipeline status {status} not handled'}
    
    def trigger_github_deployment(self, payload):
        """Trigger GitHub Actions workflow"""
        try:
            url = f"https://api.github.com/repos/{INFRA_REPO_OWNER}/{INFRA_REPO_NAME}/dispatches"
            headers = {
                'Authorization': f'token {GITHUB_TOKEN}',
                'Accept': 'application/vnd.github.v3+json'
            }
            
            data = {
                'event_type': payload['event_type'],
                'client_payload': payload
            }
            
            response = requests.post(url, headers=headers, json=data)
            
            if response.status_code == 204:
                logger.info("Successfully triggered GitHub Actions workflow")
                return True
            else:
                logger.error(f"Failed to trigger GitHub workflow: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            logger.error(f"Error triggering GitHub deployment: {str(e)}")
            return False
    
    def notify_github_completion(self, payload):
        """Notify GitHub about deployment completion"""
        try:
            url = f"https://api.github.com/repos/{INFRA_REPO_OWNER}/{INFRA_REPO_NAME}/dispatches"
            headers = {
                'Authorization': f'token {GITHUB_TOKEN}',
                'Accept': 'application/vnd.github.v3+json'
            }
            
            data = {
                'event_type': 'deployment_completed',
                'client_payload': payload
            }
            
            response = requests.post(url, headers=headers, json=data)
            
            if response.status_code == 204:
                logger.info("Successfully notified GitHub about deployment completion")
                return {'status': 'success', 'message': 'GitHub notified'}
            else:
                logger.error(f"Failed to notify GitHub: {response.status_code} - {response.text}")
                return {'status': 'error', 'message': 'Failed to notify GitHub'}
                
        except Exception as e:
            logger.error(f"Error notifying GitHub: {str(e)}")
            return {'status': 'error', 'message': 'Error notifying GitHub'}
    
    def trigger_gitlab_deployment(self, payload):
        """Trigger GitLab CI pipeline from GitHub Actions"""
        try:
            url = f"https://gitlab.com/api/v4/projects/{GITLAB_PROJECT_ID}/trigger/pipeline"
            headers = {
                'PRIVATE-TOKEN': GITLAB_TOKEN,
                'Content-Type': 'application/json'
            }
            
            data = {
                'ref': 'main',
                'variables': {
                    'WEBHOOK_EVENT': payload.get('event_type', 'github_trigger'),
                    'DEPLOYMENT_SOURCE': 'github_actions',
                    'SYNC_COMMIT': payload.get('commit_id', ''),
                    'TIMESTAMP': payload.get('timestamp', datetime.utcnow().isoformat())
                }
            }
            
            response = requests.post(url, headers=headers, json=data)
            
            if response.status_code == 201:
                pipeline_id = response.json().get('id')
                logger.info(f"Successfully triggered GitLab pipeline {pipeline_id}")
                return True
            else:
                logger.error(f"Failed to trigger GitLab pipeline: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            logger.error(f"Error triggering GitLab deployment: {str(e)}")
            return False

# Initialize webhook handler
webhook_handler = WebhookHandler()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'service': 'webhook-handler'
    })

@app.route('/webhook/gitlab', methods=['POST'])
def gitlab_webhook():
    """GitLab webhook endpoint"""
    try:
        # Verify signature if configured
        signature = request.headers.get('X-Gitlab-Token', '')
        if not webhook_handler.verify_gitlab_signature(request.get_data(), signature):
            logger.warning("Invalid webhook signature")
            return jsonify({'error': 'Invalid signature'}), 401
        
        # Process webhook
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No JSON data received'}), 400
        
        result = webhook_handler.handle_gitlab_webhook(data)
        return jsonify(result)
        
    except Exception as e:
        logger.error(f"Error processing GitLab webhook: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/trigger/deployment', methods=['POST'])
def trigger_deployment():
    """Manual deployment trigger endpoint"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No JSON data received'}), 400
        
        event_type = data.get('event_type', 'manual_trigger')
        
        # Trigger deployment based on source
        if data.get('source') == 'github_actions':
            # Trigger GitLab deployment
            success = webhook_handler.trigger_gitlab_deployment(data)
        else:
            # Trigger GitHub deployment
            success = webhook_handler.trigger_github_deployment(data)
        
        if success:
            return jsonify({
                'status': 'triggered',
                'message': f'Deployment triggered: {event_type}'
            })
        else:
            return jsonify({
                'status': 'error',
                'message': f'Failed to trigger deployment: {event_type}'
            }), 500
            
    except Exception as e:
        logger.error(f"Error triggering deployment: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/status', methods=['GET'])
def status():
    """Status endpoint with recent events"""
    try:
        # Read recent webhook log entries
        events = []
        if os.path.exists('webhook.log'):
            with open('webhook.log', 'r') as f:
                lines = f.readlines()
                # Get last 20 lines
                for line in lines[-20:]:
                    if 'INFO' in line:
                        events.append(line.strip())
        
        return jsonify({
            'status': 'running',
            'timestamp': datetime.utcnow().isoformat(),
            'recent_events': events[-10:],  # Last 10 events
            'configuration': {
                'gitlab_token_configured': bool(GITLAB_TOKEN),
                'github_token_configured': bool(GITHUB_TOKEN),
                'webhook_secret_configured': bool(GITLAB_WEBHOOK_SECRET)
            }
        })
        
    except Exception as e:
        logger.error(f"Error getting status: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('DEBUG', 'false').lower() == 'true'
    
    logger.info(f"Starting webhook handler on port {port}")
    logger.info(f"Debug mode: {debug}")
    
    app.run(host='0.0.0.0', port=port, debug=debug)