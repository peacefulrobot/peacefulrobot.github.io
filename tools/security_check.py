#!/usr/bin/env python3

import os
import sys
import re
from pathlib import Path
import logging

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

def check_environment_variables():
    required_vars = ['GODADDY_API_KEY', 'GODADDY_API_SECRET']
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    if missing_vars:
        logging.warning(f"Missing environment variables: {', '.join(missing_vars)}")
        logging.info("This is expected in development. Please ensure variables are set in production.")
        return True  # Allow commit in development
    return True

def check_file_permissions():
    sensitive_files = ['.env', 'dns_updates.log']
    for file in sensitive_files:
        path = Path(file)
        if path.exists():
            mode = path.stat().st_mode
            if mode & 0o077:  # Check if group or others have any permissions
                logging.error(f"Insecure permissions on {file}. Please run: chmod 600 {file}")
                return False
    return True

def check_gitignore():
    required_ignores = [
        '.env',
        '*.log',
        '__pycache__/',
        '.venv/',
        '.vscode/',
        '*.pem',
        '*.key'
    ]
    
    gitignore_path = Path('.gitignore')
    if not gitignore_path.exists():
        logging.error(".gitignore file not found")
        return False
        
    with open(gitignore_path) as f:
        ignores = f.read().splitlines()
    
    missing = [item for item in required_ignores if item not in ignores]
    if missing:
        logging.error(f"Missing required .gitignore entries: {', '.join(missing)}")
        return False
    return True

def check_security_policy():
    if not Path('SECURITY.md').exists():
        logging.error("SECURITY.md file not found")
        return False
    return True

def main():
    setup_logging()
    logging.info("Starting security configuration check...")
    
    checks = {
        "Environment Variables": check_environment_variables,
        "File Permissions": check_file_permissions,
        "Gitignore Configuration": check_gitignore,
        "Security Policy": check_security_policy
    }
    
    success = True
    for check_name, check_func in checks.items():
        logging.info(f"Running check: {check_name}")
        if not check_func():
            success = False
            logging.error(f"Check failed: {check_name}")
        else:
            logging.info(f"Check passed: {check_name}")
    
    if not success:
        logging.error("Security configuration check failed")
        sys.exit(1)
    
    logging.info("All security checks passed")

if __name__ == "__main__":
    main()