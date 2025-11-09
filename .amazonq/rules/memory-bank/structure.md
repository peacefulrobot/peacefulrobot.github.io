# Project Structure

## Directory Organization

```
UpdatePRWithChat/
├── .amazonq/rules/memory-bank/     # Amazon Q documentation and rules
├── peacefulrobot.github.io/        # Main website repository (submodule)
│   ├── UpdatePRWithChat/           # Infrastructure tools (nested)
│   │   ├── update_godaddy_dns.py   # DNS management script
│   │   ├── security_check.py       # Security validation script
│   │   ├── README.md               # Tool documentation
│   │   ├── INFRASTRUCTURE_ISSUES.md # Issue tracking
│   │   ├── SECURITY.md             # Security guidelines
│   │   ├── .env.example            # Environment template
│   │   └── .gitignore              # Git exclusions
│   ├── index.html                  # Website homepage
│   ├── .gitlab-ci.yml              # GitLab CI/CD configuration
│   ├── netlify.toml                # Netlify deployment config
│   ├── vercel.json                 # Vercel deployment config
│   └── CNAME                       # Custom domain configuration
├── tools/                          # Standalone tools directory (duplicate)
│   ├── update_godaddy_dns.py       # DNS management script
│   ├── security_check.py           # Security validation script
│   ├── README.md                   # Tool documentation
│   ├── INFRASTRUCTURE_ISSUES.md    # Issue tracking
│   ├── SECURITY.md                 # Security guidelines
│   ├── .env.example                # Environment template
│   └── .gitignore                  # Git exclusions
├── TODO.md                         # Project roadmap and current tasks
├── .gitignore                      # Root-level Git exclusions
└── .gitmodules                     # Git submodule configuration
```

## Core Components

### 1. DNS Management Module (update_godaddy_dns.py)
**Purpose**: Automates GoDaddy DNS record updates for domain hosting changes

**Key Responsibilities**:
- Connects to GoDaddy API using credentials from environment variables
- Retrieves current DNS A records for peacefulrobot.com
- Updates A records to point to new hosting provider IPs
- Validates changes and reports success/failure

**Integration Points**:
- Environment variables: GODADDY_API_KEY, GODADDY_API_SECRET
- GoDaddy REST API v1
- Can be integrated into CI/CD pipelines

### 2. Security Validation Module (security_check.py)
**Purpose**: Pre-deployment security checks for infrastructure configurations

**Key Responsibilities**:
- Validates environment variable configuration
- Checks credential format and presence
- Verifies configuration file integrity
- Reports security issues before deployment

**Integration Points**:
- .env files for configuration
- CI/CD security gates
- Pre-commit hooks (potential)

### 3. Website Repository (peacefulrobot.github.io)
**Purpose**: Static website content and deployment configurations

**Key Responsibilities**:
- Hosts HTML/CSS/JS for peacefulrobot.com
- Contains multi-platform deployment configs (GitLab CI, Vercel, Netlify)
- Manages custom domain CNAME records
- Serves as Git submodule for infrastructure tools

## Architectural Patterns

### Multi-Platform GitOps Architecture
```
GitLab (Source of Truth)
    ↓ (mirror)
GitHub (Redundancy)
    ↓ (webhook)
Vercel (Hosting Option 1)

GitLab (Source of Truth)
    ↓ (CI/CD)
GitLab Pages (Hosting Option 2)
    ↑ (DNS A record)
peacefulrobot.com
```

**Design Goals**:
- Eliminate single points of failure
- Enable rapid provider switching via DNS
- Maintain open source transparency on GitLab
- Provide multiple deployment targets

### Tool Duplication Pattern
The project maintains tools in two locations:
1. `peacefulrobot.github.io/UpdatePRWithChat/` - Nested within website repo
2. `tools/` - Standalone directory at root level

**Rationale**:
- Allows tools to be used independently of website repository
- Enables submodule isolation for website deployments
- Provides flexibility for different deployment scenarios

### Environment-Based Configuration
- Credentials stored in environment variables (never committed)
- `.env.example` files document required variables
- Scripts fail safely if credentials missing
- Supports multiple environments (dev, staging, prod)

## Component Relationships

1. **DNS Script → GoDaddy API**: Direct REST API integration for DNS updates
2. **Security Script → Environment**: Validates configuration before DNS changes
3. **Website Repo → Hosting Platforms**: Deployed to Vercel, GitLab Pages, GitHub Pages
4. **CI/CD Pipeline → Tools**: Can invoke scripts for automated infrastructure changes
5. **TODO.md → All Components**: Tracks current infrastructure migration tasks

## Data Flow

1. Developer updates TODO.md with infrastructure change plan
2. Security check validates environment configuration
3. DNS update script modifies GoDaddy A records
4. Website deploys to new hosting platform via CI/CD
5. INFRASTRUCTURE_ISSUES.md documents outcome and lessons learned
