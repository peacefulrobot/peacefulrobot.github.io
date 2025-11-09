# Development Guidelines

## Code Quality Standards

### Python Code Formatting
- **Indentation**: 4 spaces (no tabs)
- **Line Length**: No strict limit, but keep lines readable (typically under 100 characters)
- **Blank Lines**: Single blank line between functions, two blank lines between top-level definitions
- **String Quotes**: Single quotes for strings, f-strings for interpolation
- **Import Organization**: Standard library imports first, third-party imports second, local imports last

### Naming Conventions
- **Variables**: snake_case (e.g., `api_key`, `last_calls`, `missing_vars`)
- **Functions**: snake_case with descriptive verbs (e.g., `update_dns_records`, `check_environment_variables`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_KEY`, `GITHUB_IPS`, `DOMAIN`)
- **Private Functions**: No leading underscore convention used in this codebase
- **Decorators**: snake_case (e.g., `rate_limit`, `wraps`)

### Documentation Standards
- **Inline Comments**: Used sparingly, only for complex logic or non-obvious operations
- **Docstrings**: Not used in this codebase - function names are self-documenting
- **User-Facing Messages**: Clear, actionable print statements with context
- **Error Messages**: Include specific details about what failed and how to fix it

Example:
```python
print(f"Failed to update DNS records. Status code: {response.status_code}")
print(f"Response: {response.text}")
```

### File Organization
- **Imports**: All imports at the top of file
- **Configuration**: Constants defined after imports, before functions
- **Helper Functions**: Defined before main business logic
- **Main Logic**: Primary functions in middle of file
- **Entry Point**: `if __name__ == "__main__":` block at bottom

## Structural Conventions

### Error Handling Pattern
The codebase follows a consistent error handling approach:

1. **Early Validation**: Check prerequisites at module load time
```python
if not API_KEY or not API_SECRET:
    raise ValueError('API credentials not properly configured')
```

2. **Try-Except with User Feedback**: Catch exceptions and provide actionable messages
```python
try:
    response = requests.put(API_URL, headers=headers, json=all_records)
    if response.status_code == 200:
        print("Successfully updated DNS records!")
        return True
    else:
        print(f"Failed to update DNS records. Status code: {response.status_code}")
        return False
except Exception as e:
    print(f"Error updating DNS records: {str(e)}")
    return False
```

3. **Boolean Return Values**: Functions return True/False for success/failure
4. **Exit Codes**: Use `sys.exit(1)` for fatal errors in main execution

### Logging Pattern
Structured logging is used for audit trails and debugging:

```python
logging.basicConfig(
    filename='dns_updates.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
```

- **INFO**: Successful operations and progress updates
- **WARNING**: Non-fatal issues (e.g., missing env vars in development)
- **ERROR**: Fatal issues that prevent operation

### Validation Pattern
Input validation functions follow a consistent structure:

```python
def validate_domain(domain):
    if not re.match(r'^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\\.[a-zA-Z]{2,}$', domain):
        raise ValueError(f'Invalid domain format: {domain}')
```

- Use regex for format validation
- Raise ValueError with descriptive message
- Include the invalid value in error message

## Recurring Implementation Patterns

### Environment Variable Access
Always provide default empty string and validate:

```python
API_KEY = os.getenv('GODADDY_API_KEY', '')
API_SECRET = os.getenv('GODADDY_API_SECRET', '')

if not API_KEY or not API_SECRET:
    raise ValueError('API credentials not properly configured')
```

### API Request Headers
Consistent header structure for GoDaddy API:

```python
headers = {
    'Authorization': f'sso-key {API_KEY}:{API_SECRET}',
    'Content-Type': 'application/json'  # for PUT/POST
    # or
    'Accept': 'application/json'  # for GET
}
```

### List Comprehensions for Data Transformation
Prefer list comprehensions for building data structures:

```python
a_records = [
    {
        'data': ip,
        'name': '@',
        'ttl': 600,
        'type': 'A'
    } for ip in GITHUB_IPS
]
```

### Dictionary-Based Configuration
Use dictionaries to organize related checks or operations:

```python
checks = {
    "Environment Variables": check_environment_variables,
    "File Permissions": check_file_permissions,
    "Gitignore Configuration": check_gitignore,
    "Security Policy": check_security_policy
}

for check_name, check_func in checks.items():
    logging.info(f"Running check: {check_name}")
    if not check_func():
        success = False
```

## Architectural Approaches

### Decorator Pattern for Cross-Cutting Concerns
Rate limiting implemented as decorator:

```python
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
```

Note: Decorator is defined but not currently applied to any functions.

### Separation of Concerns
Scripts follow single responsibility principle:
- `update_godaddy_dns.py`: DNS operations only
- `security_check.py`: Security validation only
- Each function has one clear purpose

### Configuration as Code
DNS records defined as data structures:

```python
GITHUB_IPS = [
    '185.199.108.153',
    '185.199.109.153',
    '185.199.110.153',
    '185.199.111.153'
]
```

Easy to update without changing logic.

## Security Best Practices

### Credential Management
1. **Never hardcode credentials** - always use environment variables
2. **Provide .env.example** - document required variables without exposing secrets
3. **Validate at startup** - fail fast if credentials missing
4. **Use .gitignore** - ensure sensitive files never committed

Required .gitignore entries:
```
.env
*.log
__pycache__/
.venv/
.vscode/
*.pem
*.key
```

### File Permissions
Check sensitive file permissions programmatically:

```python
mode = path.stat().st_mode
if mode & 0o077:  # Check if group or others have any permissions
    logging.error(f"Insecure permissions on {file}. Please run: chmod 600 {file}")
```

### API Security
- Use HTTPS endpoints only
- Include API version in URL (`/v1/`)
- Use proper authentication headers
- Validate response status codes

## Common Code Idioms

### Pathlib for File Operations
Use pathlib.Path instead of os.path:

```python
from pathlib import Path

gitignore_path = Path('.gitignore')
if not gitignore_path.exists():
    logging.error(".gitignore file not found")
```

### F-Strings for Formatting
Always use f-strings for string interpolation:

```python
print(f"Failed to update DNS records. Status code: {response.status_code}")
logging.info(f"Running check: {check_name}")
```

### List Filtering with Comprehensions
Filter lists using comprehensions:

```python
missing_vars = [var for var in required_vars if not os.getenv(var)]
last_calls = [call for call in last_calls if call > now - 60]
```

### Shebang for Executable Scripts
Security check script includes shebang:

```python
#!/usr/bin/env python3
```

This allows direct execution: `./security_check.py`

## Testing and Validation

### Pre-Deployment Checks
Always run security checks before DNS updates:

```bash
python security_check.py && python update_godaddy_dns.py
```

### Verification After Changes
DNS update script includes built-in verification:

```python
if update_dns_records():
    print("\nVerifying current DNS records...")
    verify_dns_records()
```

### User Guidance
Provide next steps after operations:

```python
print("\nNext steps:")
print("1. Wait for DNS propagation (may take up to 48 hours)")
print("2. Go to GitHub repository settings")
print("3. Verify custom domain is set to www.peacefulrobot.com")
print("4. Enable HTTPS in GitHub Pages settings")
```

## Development Workflow

### Script Execution Pattern
1. Validate environment configuration
2. Perform operation
3. Verify results
4. Provide user guidance

### Logging Strategy
- Log to file for audit trail (`dns_updates.log`)
- Print to console for user feedback
- Use appropriate log levels (INFO, WARNING, ERROR)

### Configuration Management
1. Create `.env.example` with placeholder values
2. Document required variables in README.md
3. Validate environment at script startup
4. Fail gracefully with helpful error messages

## Code Duplication Policy

This project intentionally duplicates code in two locations:
- `peacefulrobot.github.io/UpdatePRWithChat/`
- `tools/`

When making changes:
1. Update both locations identically
2. Test both versions independently
3. Maintain consistency across duplicates
4. Document reasons for any divergence

## Dependency Philosophy

**Zero External Dependencies**: This codebase uses only Python standard library modules:
- `os` - Environment variables
- `sys` - Exit codes
- `json` - API response parsing
- `re` - Validation patterns
- `logging` - Audit trails
- `time` - Rate limiting
- `pathlib` - File operations
- `functools` - Decorators
- `requests` - HTTP client (only external dependency)

When adding new features:
1. Prefer standard library solutions
2. Minimize external dependencies
3. Document any new dependencies in README.md
4. Consider portability and installation complexity
