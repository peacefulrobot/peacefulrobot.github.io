# Security Policy

## Supported Versions

Only the latest version of this project is currently being supported with security updates.

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please send an email to security@peacefulrobot.com. All security vulnerabilities will be promptly addressed.

Please do not create public GitHub issues for security vulnerabilities.

## Security Controls

This project implements several security measures:

1. Environment Variables
   - Sensitive credentials are stored in environment variables
   - Example templates are provided in `.env.example`
   - Real credentials are never committed to the repository

2. Input Validation
   - Domain names are validated against RFC standards
   - IP addresses are validated for correct format
   - Record types are validated against allowed values

3. Rate Limiting
   - API calls are rate-limited to prevent abuse
   - Default limit: 30 calls per minute
   - Configurable through environment variables

4. Logging
   - All DNS operations are logged
   - Logs include timestamp, operation type, and affected records
   - Logs are excluded from version control

5. Error Handling
   - All errors are properly caught and logged
   - Sensitive information is never exposed in error messages

## Best Practices

1. Always use environment variables for credentials
2. Regularly rotate API keys
3. Monitor logs for suspicious activity
4. Keep dependencies updated
5. Use the latest stable version

## Security Checklist for Deployment

- [ ] Set up proper environment variables
- [ ] Configure logging
- [ ] Test input validation
- [ ] Verify rate limiting
- [ ] Review access controls
- [ ] Check for latest dependencies
- [ ] Validate SSL/TLS configuration