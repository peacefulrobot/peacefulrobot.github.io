import os
import requests
import json

# GoDaddy API configuration
API_KEY = os.getenv('GODADDY_API_KEY', '')
API_SECRET = os.getenv('GODADDY_API_SECRET', '')  # You'll need to set this
DOMAIN = 'peacefulrobot.com'
API_URL = f'https://api.godaddy.com/v1/domains/{DOMAIN}/records'

# GitHub Pages IPs
GITHUB_IPS = [
    '185.199.108.153',
    '185.199.109.153',
    '185.199.110.153',
    '185.199.111.153'
]

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
        } for ip in GITHUB_IPS
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
        
    print("Updating DNS records...")
    if update_dns_records():
        print("\nVerifying current DNS records...")
        verify_dns_records()
        print("\nNext steps:")
        print("1. Wait for DNS propagation (may take up to 48 hours)")
        print("2. Go to GitHub repository settings")
        print("3. Verify custom domain is set to www.peacefulrobot.com")
        print("4. Enable HTTPS in GitHub Pages settings")
    else:
        print("\nFailed to update DNS records. Please check the error messages above.")