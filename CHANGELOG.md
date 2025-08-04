# Changelog

All notable changes to the New Development Machine Setup project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-04

### Added
- Initial release of New Development Machine Setup script
- Automated installation for Claude Code CLI
- Automated installation for GitHub CLI
- Automated installation for Tailscale
- Cross-platform support (macOS, Ubuntu/Debian, Linux)
- Environment variable configuration via `.env` file
- `.env.example` template for easy setup
- Command-line flags to skip specific tool installations
- Colored output with status indicators
- ASCII art banner for enhanced user experience
- Automatic OS detection
- Homebrew installation for macOS
- API key configuration for automated setup
- Comprehensive error handling
- Installation verification
- Detailed README documentation
- Security-focused `.gitignore` file

### Features
- **Multi-platform Support**: Works on macOS, Ubuntu, Debian, and other Linux distributions
- **Smart Detection**: Checks for existing installations and updates them
- **Flexible Installation**: Skip specific tools via flags or environment variables
- **Secure Configuration**: Uses `.env` file for sensitive data (excluded from git)
- **User-friendly**: Color-coded output, clear instructions, and helpful error messages

### Security
- API keys and tokens stored in `.env` file (gitignored)
- Secure token handling for GitHub and Tailscale authentication
- No hardcoded credentials in scripts

### Documentation
- Comprehensive README with installation instructions
- Platform compatibility matrix
- Troubleshooting guide
- Security best practices

## [Unreleased]

### Planned
- Windows support via WSL
- Docker container option
- Additional tool integrations
- Automated updates mechanism
- Configuration profiles for different use cases