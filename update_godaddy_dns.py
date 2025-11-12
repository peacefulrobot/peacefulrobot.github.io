import os
import requests
import json
import logging
import time
import re
from functools import wraps

logging.basicConfig(
    filename='dns_updates.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

last_calls = []

def rate_limit(calls_per_minute=30):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            global last_calls
            now = time.time()
            last_calls = [call for call in last_calls if call > now - 60]
            if len(last_calls) >= calls_per_minute:
                raise Exception(f'Rate limit exceeded: {calls_per_minute} calls per minute')
            last_calls.append(now)
            return func(*args, **kwargs)
        return wrapper
    return decorator

def validate_domain(domain):
    if not re.match(r'^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$', domain):
        raise ValueError(f'Invalid domain format: {domain}')

def validate_record_type(record_type):
    valid_types = ['A', 'AAAA', 'CNAME', 'MX', 'NS', 'SOA', 'SRV', 'TXT']
    if record_type not in valid_types:
        raise ValueError(f'Invalid record type: {record_type}')

def validate_ip(ip):
    if not re.match(r'^\d{1,3}(\.\d{1,3}){3}$', ip):
        raise ValueError(f'Invalid IP format: {ip}')
    for octet in ip.split('.'):
        if not 0 <= int(octet) <= 255:
            raise ValueError(f'Invalid IP octet value in: {ip}')

API_KEY = os.getenv('GODADDY_API_KEY', '')
API_SECRET = os.getenv('GODADDY_API_SECRET', '')

if not API_KEY or not API_SECRET:
    raise ValueError('API credentials not properly configured')
DOMAIN = 'peacefulrobot.com'
API_URL = f'https://api.godaddy.com/v1/domains/{DOMAIN}/records'

# GitLab Pages IP
GITLAB_PAGES_IP = '35.185.44.232'

# GitHub Pages IPs (backup)
GITHUB_IPS = [
    '185.199.108.153',
    '185.199.109.153',
    '185.199.110.153',
    '185.199.111.153'
]

# Current target: GitLab Pages
TARGET_IPS = [GITLAB_PAGES_IP]

def update_dns_records():
    headers = {
        'Authorization': f'sso-key {API_KEY}:{API_SECRET}',
        'Content-Type': 'application/json'
    }

    # Prepare A records for apex domain
    a_records = [
        {
            'data': ip,
            'name': '@',
            'ttl': 600,
            'type': 'A'
        } for ip in TARGET_IPS
    ]

    # Prepare CNAME record for www subdomain
    cname_record = [{
        'data': 'peacefulrobot.github.io',
        'name': 'www',
        'ttl': 600,
        'type': 'CNAME'
    }]

    # Combine all records
    all_records = a_records + cname_record

    try:
        # Update all records
        response = requests.put(
            API_URL,
            headers=headers,
            json=all_records
        )
        
        if response.status_code == 200:
            print("Successfully updated DNS records!")
            return True
        else:
            print(f"Failed to update DNS records. Status code: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"Error updating DNS records: {str(e)}")
        return False

def verify_dns_records():
    headers = {
        'Authorization': f'sso-key {API_KEY}:{API_SECRET}',
        'Accept': 'application/json'
    }

    try:
        response = requests.get(API_URL, headers=headers)
        if response.status_code == 200:
            records = response.json()
            print("\nCurrent DNS Records:")
            for record in records:
                print(f"Type: {record['type']}, Name: {record['name']}, Data: {record['data']}")
        else:
            print(f"Failed to fetch DNS records. Status code: {response.status_code}")
            
    except Exception as e:
        print(f"Error fetching DNS records: {str(e)}")

if __name__ == "__main__":
    if not API_SECRET:
        print("Please set the GODADDY_API_SECRET environment variable")
        exit(1)
    
    import sys
    auto_confirm = '--auto-confirm' in sys.argv or os.getenv('CI') == 'true'
    
    print("Fetching current DNS records...")
    verify_dns_records()
    
    if not auto_confirm:
        print("\n" + "="*50)
        response = input("\nDo you want to update DNS records? (yes/no): ")
        if response.lower() not in ['yes', 'y']:
            print("\nDNS update cancelled.")
            exit(0)
    
    print("\nUpdating DNS records...")
    if update_dns_records():
        print("\nVerifying updated DNS records...")
        verify_dns_records()
        print("\nNext steps:")
        print("1. Wait for DNS propagation (may take up to 48 hours)")
        print("2. Configure custom domain in GitLab Pages settings")
        print("3. Enable HTTPS/SSL")
    else:
        print("\nFailed to update DNS records. Please check the error messages above.")
        exit(1)