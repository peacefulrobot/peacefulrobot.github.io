# Peaceful Robot Infrastructure Tools

Tools and documentation for managing Peaceful Robot's infrastructure.

## Tools

### DNS Management
- `update_godaddy_dns.py`: Script to update GoDaddy DNS records for GitHub Pages hosting

## Documentation
- `INFRASTRUCTURE_ISSUES.md`: Tracking of infrastructure-related issues and their solutions

## Setup
1. Clone this repository
2. Set environment variables:
   ```bash
   export GODADDY_API_KEY="your_key"
   export GODADDY_API_SECRET="your_secret"
   ```
3. Run the DNS update script:
   ```bash
   python update_godaddy_dns.py
   ```