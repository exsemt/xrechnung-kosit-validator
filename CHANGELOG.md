# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-01

### Added
- Initial release of XRechnung KoSIT Validator Docker container
- KoSIT Validator 1.5.2 with built-in HTTP daemon mode
- XRechnung Configuration 3.0.2 (release 2025-07-10)
- Docker and Docker Compose support
- Health check endpoint at `/server/health`
- Validation endpoint for XRechnung (XML) invoices
- Comprehensive README with API documentation
- Integration examples for Ruby, Python, JavaScript, and cURL
- Example valid XRechnung CII invoice
- MIT License
- Contributing guidelines
- .gitignore and .dockerignore files

### Features
- EN16931 compliant validation
- Support for XRechnung CII and UBL formats
- Lightweight container based on Eclipse Temurin JRE 17
- Configurable Java memory settings via environment variables
- Production-ready with health checks and restart policies

## [Unreleased]

### Planned
- Support for ZUGFeRD PDF extraction
- Additional example invoices (UBL format)
- Performance benchmarks
- CI/CD pipeline with GitHub Actions
- Pre-built Docker images on Docker Hub
- Multi-architecture support (amd64, arm64)
