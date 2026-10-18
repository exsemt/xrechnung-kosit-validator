# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-10-18

### Changed
- Updated KoSIT Validator from 1.5.2 to 1.6.3
  - Fixed security advisory GHSA-hg2c-p2m3-q29m (unrestricted URI resolution in STRICT_LOCAL mode)
  - Dropped Java 8 support, migrated from `javax` to `jakarta xml bind`
  - Added `Result.getCustomFailedAsserts()` API for custom error levels
- Updated XRechnung Configuration from 2025-07-10 to 2026-08-31
  - Compatible with XRechnung 3.0.2 and KoSIT Validator 1.6.3
  - Includes CEN Schematron Rules 1.3.16
  - Added custom severity rules for CII-SR-465, CII-SR-466, CII-SR-475, CII-SR-476
  - Handled new distribution zip naming convention (`xrechnung-3.0.2-validator-configuration-YYYY-MM-DD.zip`)
- Updated `test.sh` to support configurable `TEST_PORT` (default: 8085) to avoid local port conflicts

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
