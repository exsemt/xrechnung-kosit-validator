# GitHub Copilot Instructions

## Project Overview

**XRechnung KoSIT Validator Docker** is a containerized version of the official KoSIT Validator for validating German e-invoices (XRechnung) and European e-invoices (EN16931) using the built-in HTTP daemon mode.

### Purpose
- Provide a production-ready Docker container for XRechnung and ZUGFeRD validation
- Enable easy integration of EN16931-compliant invoice validation into web applications
- Offer a simple HTTP API for invoice validation without complex Java setup

### Technology Stack
- **Base Image**: Eclipse Temurin 17 JRE (official OpenJDK)
- **Validator**: KoSIT Validator 1.5.2 (standalone JAR)
- **Configuration**: XRechnung Configuration 3.0.2
- **Orchestration**: Docker Compose
- **Standards**: EN16931, XRechnung 3.0

## Architecture

### Container Components
1. **Java Runtime**: Eclipse Temurin 17 JRE for minimal footprint
2. **KoSIT Validator**: Standalone JAR with built-in HTTP daemon mode
3. **XRechnung Configuration**: Scenarios and validation rules (CII & UBL)
4. **Health Check**: Built-in endpoint at `/server/health`

### HTTP Daemon Mode
The KoSIT Validator includes a built-in HTTP server (daemon mode) that:
- Listens on port 8080 by default
- Accepts POST requests with XML invoice data
- Returns detailed validation reports in XML format
- Provides HTTP status codes: 200 (valid), 406 (invalid), 422 (error)

### Validation Flow
```
Client → POST XML → Validator Daemon → KoSIT Engine → Scenarios → Rules → XML Report
```

## Key Design Decisions

### Why Daemon Mode?
- **No custom wrapper needed**: KoSIT has built-in HTTP server
- **Official support**: Maintained by KoSIT team
- **Production-ready**: Stable and well-tested
- **Simple integration**: Standard HTTP API

### Why Standalone JAR?
- **Single artifact**: No Maven/Gradle build required
- **Version pinning**: Explicit version control
- **Fast startup**: No dependency resolution at runtime
- **Minimal image size**: Only runtime dependencies

### Directory Structure
```
/validator/
├── validator.jar          # KoSIT Validator standalone
└── config/
    ├── scenarios.xml      # XRechnung scenarios
    └── ...               # XRechnung configuration files
```

## Coding Guidelines

### Dockerfile Best Practices

1. **Use multi-stage builds** (if needed for future enhancements)
2. **Minimize layers**: Combine RUN commands where logical
3. **Clean up in same layer**: Remove temp files in same RUN command
4. **Pin versions**: Always use ARG for version numbers
5. **Health checks**: Always include HEALTHCHECK directive

### Example Patterns

**Good** - Clean up in same layer:
```dockerfile
RUN wget https://example.com/file.zip && \
    unzip file.zip && \
    rm file.zip
```

**Bad** - Separate layers create bloat:
```dockerfile
RUN wget https://example.com/file.zip
RUN unzip file.zip
RUN rm file.zip
```

### Environment Variables

Always use environment variables for:
- Java memory settings (`JAVA_OPTS`)
- Configurable parameters
- Never for static paths (use ARG instead)

### Version Management

- **ARG for build-time**: `VALIDATOR_VERSION`, `CONFIG_VERSION`
- **ENV for runtime**: `JAVA_OPTS`
- Update versions in both Dockerfile and README

## Testing Requirements

### Before Committing
1. Build image successfully
2. Health check responds
3. Example invoice validates
4. Run `./test.sh` script

### Test Script Pattern
```bash
#!/bin/bash
set -e  # Exit on error
# Test steps with clear output
# Always cleanup containers
```

## Documentation Standards

### README Structure
- Quick Start first
- API documentation with examples
- Multiple language examples (Ruby, Python, JS)
- Production deployment guides
- Troubleshooting section

### Code Examples
- Always include complete, runnable examples
- Show both success and error cases
- Include HTTP status code checks
- Demonstrate response parsing

### Comments
- Explain WHY, not WHAT
- Use inline comments for complex commands
- Keep LABEL fields informative

## Integration Patterns

### HTTP Client Best Practices

When creating client examples:

1. **Handle all status codes**:
   - 200: Valid invoice
   - 406: Invalid invoice (validation errors)
   - 422: Processing error
   - 5xx: Server error

2. **Parse XML responses**:
   - Use proper XML parsers (Nokogiri, ElementTree, etc.)
   - Remove namespaces for easier querying
   - Extract errors/warnings from `<error>` and `<warning>` elements

3. **Content-Type header**:
   - Always send `Content-Type: application/xml`
   - Use binary mode for file uploads

### Example Response Parsing

```ruby
# Ruby pattern
doc = Nokogiri::XML(response.body)
doc.remove_namespaces!
errors = doc.xpath('//error/message').map(&:text)
```

```python
# Python pattern
from xml.etree import ElementTree as ET
root = ET.fromstring(response.text)
errors = [el.text for el in root.findall('.//error/message')]
```

## Common Tasks

### Updating Validator Version

1. Change `VALIDATOR_VERSION` in Dockerfile
2. Update README.md version references
3. Update CHANGELOG.md
4. Test build and validation
5. Tag release

### Adding New Examples

1. Create XML file in `examples/`
2. Add description to `examples/README.md`
3. Include expected validation result
4. Test with `curl` command

### Troubleshooting Tips

Common issues and solutions:

1. **OutOfMemoryError**: Increase `JAVA_OPTS` memory settings
2. **Port conflict**: Check if 8080 is already in use
3. **Slow validation**: Check invoice size, increase resources
4. **Connection refused**: Wait for health check to pass

## File Naming Conventions

- **Dockerfiles**: `Dockerfile` (no suffix needed)
- **Examples**: `{format}-{type}-{variant}.xml` (e.g., `valid-xrechnung-cii.xml`)
- **Scripts**: `{action}.sh` (e.g., `test.sh`, `deploy.sh`)
- **Documentation**: `{TOPIC}.md` (uppercase for root-level)

## Git Workflow

### Commit Messages

Follow conventional commits:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation only
- `chore:` - Maintenance (version bumps, etc.)
- `refactor:` - Code refactoring
- `test:` - Test additions/changes

### Examples
```
feat: add support for XRechnung 3.1
fix: correct health check endpoint path
docs: update integration examples for Python 3.11
chore: bump KoSIT validator to 1.5.3
```

## Security Considerations

1. **No sensitive data**: Never include real invoice data or credentials
2. **Base image updates**: Regularly update Eclipse Temurin base image
3. **Dependency scanning**: Monitor for CVEs in Java dependencies
4. **Network isolation**: Run in private networks when possible
5. **Resource limits**: Always set memory/CPU limits in production

## Performance Guidelines

### Container Resources

**Recommended minimums**:
- Memory: 512 MB (can handle most invoices)
- CPU: 0.25 cores
- Disk: 500 MB

**For high-volume**:
- Memory: 1-2 GB
- CPU: 1-2 cores
- Use container orchestration for scaling

### Optimization Tips

1. **Keep images small**: Remove build tools after use
2. **Use .dockerignore**: Exclude unnecessary files from build context
3. **Layer caching**: Order commands from least to most frequently changed
4. **Multi-architecture**: Consider arm64 for cost savings

## Related Resources

- [KoSIT Validator](https://github.com/itplr-kosit/validator) - Official repository
- [XRechnung Standard](https://xrechnung.de/) - German e-invoice standard
- [EN16931 Spec](https://ec.europa.eu/cefdigital/wiki/display/CEFDIGITAL/EN16931) - European standard
- [KoSIT Daemon Docs](https://github.com/itplr-kosit/validator/blob/master/docs/daemon.md) - HTTP daemon mode

## Project Maintenance

### Regular Updates

Monthly:
- Check for new KoSIT validator versions
- Check for XRechnung configuration updates
- Update base image if security patches available

Quarterly:
- Review and update documentation
- Update integration examples for new language versions
- Review and close stale issues

### Version Policy

- **Major version**: Breaking changes to API or container interface
- **Minor version**: New features, validator updates
- **Patch version**: Bug fixes, documentation updates

---

**Last Updated**: 2026-01-01
**Maintainer**: XSatz Team
