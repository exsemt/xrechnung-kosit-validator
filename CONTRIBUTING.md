# Contributing to XRechnung KoSIT Validator Docker

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:
- Clear description of the problem
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details (OS, Docker version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:
- Check if the feature has already been suggested
- Provide a clear use case
- Explain why this enhancement would be useful

### Pull Requests

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/xrechnung-kosit-validator.git
   cd xrechnung-kosit-validator
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style
   - Update documentation if needed
   - Add examples if applicable

4. **Test your changes**
   ```bash
   # Build the image
   docker build -t xrechnung-validator-test .

   # Run the container
   docker run -d -p 8080:8080 xrechnung-validator-test

   # Test endpoints
   curl http://localhost:8080/server/health
   curl -X POST --data-binary @examples/valid-xrechnung-cii.xml http://localhost:8080/
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

   Use conventional commit messages:
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `chore:` - Maintenance tasks
   - `refactor:` - Code refactoring

6. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   Then create a Pull Request on GitHub.

## Development Guidelines

### Dockerfile Changes

- Keep the image size minimal
- Use official base images
- Add comments for complex commands
- Test build on multiple platforms (amd64, arm64)

### Documentation

- Update README.md for user-facing changes
- Add inline comments for complex code
- Include examples for new features
- Keep documentation clear and concise

### Testing

Before submitting a PR, ensure:
- Image builds successfully
- Health check works
- Validation endpoint responds correctly
- Examples in `examples/` directory validate properly

## Code of Conduct

- Be respectful and constructive
- Focus on the issue, not the person
- Help others learn and grow
- Assume good intentions

## Questions?

If you have questions, feel free to:
- Open an issue for discussion
- Check existing issues and PRs
- Review the README.md

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
