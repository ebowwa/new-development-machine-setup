# Dynamic Development Environment Setup 🚀

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
║       Dynamic Environment Auto-Configuration              ║
╚═══════════════════════════════════════════════════════════╝
```

Environment-aware setup system that automatically detects your context (VPS, Codespaces, local dev) and installs only the tools you need.

## 🎯 Smart Environment Detection

The setup script automatically detects your environment and configures it appropriately:

| Environment | Auto-Detection | Tools Installed | Tools Skipped |
|------------|---------------|-----------------|---------------|
| **VPS/Production** | Hostname pattern, env vars | Tailscale, GitHub CLI, Doppler | Claude Code |
| **GitHub Codespaces** | CODESPACES env var | GitHub CLI, Claude Code, Doppler | Tailscale |
| **Local Development** | macOS + VS Code | All tools | None |
| **CI/CD Pipeline** | CI env vars | GitHub CLI | Others |
| **Container/Docker** | /.dockerenv file | GitHub CLI | Others |

## 🛠️ Tools Included

- **Claude Code CLI** - Anthropic's AI coding assistant
- **GitHub CLI** (`gh`) - GitHub from the command line
- **Tailscale** - Zero-config VPN for secure networking
- **Doppler** - SecretOps platform for environment variables

## 🚀 Quick Start

```bash
# Clone and run - it auto-detects your environment!
git clone https://github.com/yourusername/new-development-machine-setup.git
cd new-development-machine-setup
./setup.sh
```

## 📋 Prerequisites

- **macOS**: Command Line Tools (auto-prompts if missing)
- **Linux**: `curl` and `sudo` access
- **All platforms**: Internet connection

## ⚙️ Configuration

### Basic Setup
```bash
# Optional: Add your API keys for automated config
cp .env.example .env
nano .env  # Add your tokens

# Run setup - auto-detects environment
./setup.sh
```

### Force Specific Environment
```bash
# VPS/Production nodes
./setup.sh --env vps

# GitHub Codespaces
./setup.sh --env codespaces

# Local development
./setup.sh --env local_dev

# List all environments
./setup.sh --list-envs
```

### Skip Specific Tools
```bash
./setup.sh --skip-claude
./setup.sh --skip-github
./setup.sh --skip-tailscale
./setup.sh --skip-doppler

# Combine options
./setup.sh --env vps --skip-doppler
```

## 🔑 Environment Variables

Create a `.env` file with your tokens for automated configuration:

```bash
# GitHub Personal Access Token
GITHUB_TOKEN=ghp_xxxxxxxxxxxx

# Anthropic API Key (optional for Claude Pro/Team users)
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxx

# Tailscale Auth Key (for headless setup)
TAILSCALE_AUTH_KEY=tskey-auth-xxxxxxxxxxxx

# Doppler Service Token
DOPPLER_TOKEN=dp.st.xxxxxxxxxxxx
```

## 🎨 Customization

### Add Custom Environment

Edit `situations.yaml`:

```yaml
environments:
  my_custom_env:
    description: "My special environment"
    detect:
      - env: "MY_ENV=true"
      - hostname_pattern: "custom-*"
    tools:
      - github-cli
      - doppler
    skip:
      - claude-code
      - tailscale
```

### Add New Tools

Edit `situations.yaml`:

```yaml
tools:
  my_tool:
    name: "My Tool"
    check_command: "mytool"
    install_methods:
      macos: "brew install mytool"
      debian: "apt-get install mytool"
    config_env: "MY_TOOL_TOKEN"
```

## 📚 Use Cases

### VPS/Production Nodes
```bash
MACHINE_TYPE=vps ./setup.sh
```
- ✅ Tailscale for secure networking
- ✅ GitHub CLI for deployments
- ✅ Doppler for secrets management
- ❌ Claude Code (not needed on servers)

### GitHub Codespaces
Automatically detected and configured:
- ✅ Claude Code for AI assistance
- ✅ GitHub CLI (essential)
- ✅ Doppler for dev secrets
- ❌ Tailscale (not needed)

### Local Development
Full setup for your workstation:
- ✅ All tools installed
- ✅ Complete configuration

## 🔧 Post-Installation

### Claude Code
```bash
claude auth login  # Browser auth for Pro/Team users
```

### GitHub CLI
```bash
gh auth login
```

### Tailscale
```bash
sudo tailscale up  # Linux/VPS
tailscale up       # macOS
```

### Doppler
```bash
doppler login
# Or with service token:
doppler configure set token $DOPPLER_TOKEN --scope /
```

## 🐛 Troubleshooting

- **Environment not detected?** Use `--env` flag to force
- **Tool already installed?** Script checks and skips
- **Permission errors?** Ensure sudo access on Linux
- **API keys not working?** Check `.env` file formatting

## 📝 Files

- `setup.sh` - Main installation script
- `situations.yaml` - Environment and tool configurations
- `.env.example` - Template for API keys
- `.env` - Your API keys (git-ignored)

## 🔒 Security

- Never commit `.env` files
- Use environment-specific tokens
- Rotate credentials regularly
- Review `situations.yaml` before running

## 📄 License

MIT - Use freely for your own setups!

## 🤝 Contributing

PRs welcome! Please test on target platforms.