# New Development Machine Setup 🚀

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║     ███╗   ██╗███████╗██╗    ██╗    ██████╗ ███████╗██╗   ██╗
║     ████╗  ██║██╔════╝██║    ██║    ██╔══██╗██╔════╝██║   ██║
║     ██╔██╗ ██║█████╗  ██║ █╗ ██║    ██║  ██║█████╗  ██║   ██║
║     ██║╚██╗██║██╔══╝  ██║███╗██║    ██║  ██║██╔══╝  ╚██╗ ██╔╝
║     ██║ ╚████║███████╗╚███╔███╔╝    ██████╔╝███████╗ ╚████╔╝ 
║     ╚═╝  ╚═══╝╚══════╝ ╚══╝╚══╝     ╚═════╝ ╚══════╝  ╚═══╝  
║                                                           ║
║   ███████╗███████╗████████╗██╗   ██╗██████╗              ║
║   ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗             ║
║   ███████╗█████╗     ██║   ██║   ██║██████╔╝             ║
║   ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝              ║
║   ███████║███████╗   ██║   ╚██████╔╝██║                  ║
║   ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝                  ║
║                                                           ║
║       Development Environment Auto-Configuration          ║
╚═══════════════════════════════════════════════════════════╝
```

Automated setup script for essential development tools across multiple platforms.

## What it installs

- **Claude Code CLI** - Anthropic's official CLI for Claude
- **GitHub CLI** - Command-line interface for GitHub
- **Tailscale** - Zero-config VPN for secure networking

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/new-development-machine-setup.git
cd new-development-machine-setup

# Copy environment template and add your keys
cp .env.example .env
# Edit .env with your favorite editor

# Run the setup script
./setup.sh
```

## Prerequisites

- **macOS**: Command Line Tools (will prompt to install if missing)
- **Linux**: `curl` and `sudo` access
- **All platforms**: Internet connection

## Configuration

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Add your API keys and tokens:
   - **ANTHROPIC_API_KEY**: Get from [Anthropic Console](https://console.anthropic.com/settings/keys)
   - **GITHUB_TOKEN**: Generate at [GitHub Settings](https://github.com/settings/tokens)
   - **TAILSCALE_AUTH_KEY**: (Optional) Get from [Tailscale Admin](https://login.tailscale.com/admin/settings/keys)

## Usage

### Basic Installation
```bash
./setup.sh
```

### Skip Specific Tools
```bash
# Skip Claude installation
./setup.sh --skip-claude

# Skip multiple tools
./setup.sh --skip-github --skip-tailscale
```

### Environment Variables
You can also control installation via environment variables in your `.env` file:
```bash
SKIP_CLAUDE=true
SKIP_GITHUB=true
SKIP_TAILSCALE=true
```

## Platform Support

| Platform | Claude Code | GitHub CLI | Tailscale |
|----------|------------|------------|-----------|
| macOS    | ✅         | ✅         | ✅        |
| Ubuntu   | ✅         | ✅         | ✅        |
| Debian   | ✅         | ✅         | ✅        |
| RHEL/CentOS | ⚠️      | ✅         | ✅        |
| Other Linux | ⚠️      | ⚠️         | ⚠️        |

✅ = Fully automated
⚠️ = May require manual steps

## Post-Installation

After running the setup script:

1. **Claude Code**:
   ```bash
   claude auth login
   ```

2. **GitHub CLI**:
   ```bash
   gh auth login
   ```

3. **Tailscale**:
   ```bash
   tailscale up
   ```

## Troubleshooting

### macOS
- If Homebrew installation fails, install Xcode Command Line Tools:
  ```bash
  xcode-select --install
  ```

### Linux
- Ensure you have `sudo` privileges
- For Claude Code on non-Debian systems, Node.js will be installed automatically

### All Platforms
- Check the `.env` file exists and contains valid keys
- Ensure you have a stable internet connection
- Run with `bash -x setup.sh` for verbose output

## Security Notes

- Never commit your `.env` file (it's in `.gitignore`)
- Keep your API keys and tokens secure
- Rotate tokens regularly
- Use Tailscale auth keys with appropriate expiration

## License

MIT

## Contributing

Pull requests welcome! Please test on your target platform before submitting.