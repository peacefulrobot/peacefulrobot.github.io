# Technology Stack

## Programming Languages

### Python 3.x
- Primary language for infrastructure automation scripts
- Used for DNS management and security validation
- No specific version constraint specified (recommend 3.8+)

### HTML/CSS/JavaScript
- Static website content in peacefulrobot.github.io
- No build process or framework dependencies
- Plain HTML served directly by hosting platforms

## Core Dependencies

### Python Standard Library
The scripts use only Python standard library modules:
- `os` - Environment variable access
- `sys` - System operations and exit codes
- `json` - JSON parsing for API responses
- `http.client` - HTTP requests to GoDaddy API
- `base64` - Credential encoding for API authentication

**No external Python packages required** - scripts are dependency-free for maximum portability.

## External APIs

### GoDaddy API v1
- **Endpoint**: `api.godaddy.com`
- **Authentication**: API Key + Secret via Authorization header
- **Operations**: GET/PUT DNS records
- **Documentation**: https://developer.godaddy.com/doc/endpoint/domains

**Required Credentials**:
```bash
GODADDY_API_KEY="your_production_key"
GODADDY_API_SECRET="your_production_secret"
```

## Hosting Platforms

### GitLab
- **Purpose**: Source of truth repository
- **Features**: GitLab CI/CD, GitLab Pages
- **Configuration**: `.gitlab-ci.yml`
- **Pages URL**: https://jrw2.gitlab.io/peacefulrobot-github-io/

### GitHub
- **Purpose**: Mirror repository for redundancy
- **Features**: GitHub Pages (backup hosting)
- **Configuration**: CNAME file
- **Pages URL**: https://peacefulrobot.github.io

### Vercel
- **Purpose**: Primary hosting platform (current)
- **Configuration**: `vercel.json`
- **Custom Domain**: peacefulrobot.com
- **IP Addresses**: 76.76.21.98, 216.198.79.1

### Netlify
- **Purpose**: Alternative hosting option
- **Configuration**: `netlify.toml`
- **Status**: Configured but not actively used

## Development Tools

### Version Control
- **Git**: Distributed version control
- **Git Submodules**: peacefulrobot.github.io linked as submodule
- **Configuration**: `.gitmodules`, `.gitignore`

### CI/CD
- **GitLab CI**: Automated deployments from GitLab
- **GitHub Actions**: Potential (not currently configured)
- **Vercel Webhooks**: Automatic deploys on GitHub push

## Environment Configuration

### Required Environment Variables
```bash
# GoDaddy API Credentials
GODADDY_API_KEY="production_key_here"
GODADDY_API_SECRET="production_secret_here"
```

### Configuration Files
- `.env.example` - Template for environment variables (safe to commit)
- `.env` - Actual credentials (never committed, in .gitignore)

## Development Commands

### DNS Management
```bash
# Update GoDaddy DNS records
cd peacefulrobot.github.io/UpdatePRWithChat
export GODADDY_API_KEY="your_key"
export GODADDY_API_SECRET="your_secret"
python update_godaddy_dns.py
```

### Security Validation
```bash
# Run security checks
cd peacefulrobot.github.io/UpdatePRWithChat
python security_check.py
```

### Git Submodule Operations
```bash
# Initialize submodules after clone
git submodule init
git submodule update

# Update submodule to latest
cd peacefulrobot.github.io
git pull origin main
cd ..
git add peacefulrobot.github.io
git commit -m "Update submodule"
```

### Local Website Testing
```bash
# Serve static site locally
cd peacefulrobot.github.io
python -m http.server 8000
# Visit http://localhost:8000
```

## Build System

**No build system required** - This is a zero-build project:
- Python scripts run directly without compilation
- HTML/CSS/JS served as static files
- No package managers (npm, pip) needed
- No bundlers or transpilers

## Deployment Process

### Manual Deployment
1. Update DNS: `python update_godaddy_dns.py`
2. Push to GitLab: `git push gitlab main`
3. GitLab mirrors to GitHub automatically
4. Vercel/GitLab Pages deploy automatically

### Automated Deployment
- GitLab CI/CD pipeline defined in `.gitlab-ci.yml`
- Vercel webhook triggers on GitHub push
- GitLab Pages builds on GitLab push

## Security Considerations

### Credential Management
- Never commit API keys or secrets
- Use environment variables exclusively
- Validate .env.example is up to date
- Run security_check.py before deployments

### API Security
- GoDaddy API uses HTTPS only
- Authorization header with base64-encoded credentials
- Production keys should have minimal permissions (DNS only)

## Platform Requirements

### Operating System
- Linux/macOS: Native support
- Windows: Compatible (use WSL for best experience)

### Python Version
- Minimum: Python 3.6 (for f-strings)
- Recommended: Python 3.8+
- No maximum version constraint

### Network Requirements
- Outbound HTTPS to api.godaddy.com (port 443)
- DNS resolution for API endpoints
- No inbound ports required
