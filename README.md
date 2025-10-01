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
| **VPS/Production** | Hostname pattern, env vars | Tailscale, GitHub CLI, Doppler, AI assistant | None |
| **GitHub Codespaces** | CODESPACES env var | GitHub CLI, AI assistant, Doppler | Tailscale |
| **Local Development** | macOS + VS Code | All tools | None |
| **CI/CD Pipeline** | CI env vars | GitHub CLI | Others |
| **Container/Docker** | /.dockerenv file | GitHub CLI | Others |

## 🛠️ Tools Included

- **AI assistant** (Codex CLI or Claude Code) - choose the agent that matches your subscription
- **GitHub CLI** (`gh`) - GitHub from the command line
- **Tailscale** - Zero-config VPN for secure networking
- **Doppler** - SecretOps platform for environment variables

## 🚀 Quick Start

### For Z.ai Integration (feature branch)

```bash
# Clone the Z.ai integration branch
git clone -b feature/zai-integration https://github.com/ebowwa/node-starter.git
cd node-starter

# Quick setup (handles Doppler auth automatically)
./quick-setup.sh
```

### For Standard Setup

```bash
# Clone and run - it auto-detects your environment!
git clone https://github.com/ebowwa/node-starter.git
cd node-starter
./setup.sh
```

## 📋 Prerequisites

- **macOS**: Command Line Tools (auto-prompts if missing)
- **Linux**: `curl` and `sudo` access
- **All platforms**: Internet connection

## ⚙️ Configuration

### For Z.ai Integration
```bash
# The quick-setup.sh script handles everything automatically:
# 1. Installs Doppler CLI if needed
# 2. Prompts for Doppler authentication
# 3. Configures the project
# 4. Sets up Claude Code with Z.ai backend

./quick-setup.sh
```

### Using Claude Code with Z.ai
After setup, you have two options to use Claude Code:

**Option 1: Load environment per session**
```bash
# Load Z.ai configuration from Doppler
eval $(doppler secrets download --config dev --format env --no-file)

# Start Claude Code with Z.ai backend
claude
```

**Option 2: Use Doppler run wrapper**
```bash
# Start Claude with Doppler environment
doppler run --project node-starter --config dev -- claude
```

### Claude Settings Management
The project includes Claude settings templates for easy configuration:

```bash
# Install Z.ai-optimized Claude settings
./install-claude-settings.sh

# View settings files
ls .claude/
# .claude/settings.template.json  # Settings template
# .claude/settings.local.json     # Local project settings
```

The setup script automatically installs Claude settings based on your AI assistant preference:
- `--use-zai` installs Z.ai configuration (GLM-4.5 models)
- `--use-claude` installs standard Anthropic configuration
- The `install-claude-settings.sh` script is now dynamic and generates appropriate settings

### Basic Setup (Standard)
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

### Choose Your AI Assistant

Pick the agent that matches your subscription:

- `claude` (default): Claude Code with Anthropic’s API
- `zai`: Claude Code routed through the Z.ai Model API (GLM-4.5)
- `codex`: OpenAI Codex CLI

```bash
# Use Codex CLI instead of Claude Code
./setup.sh --assistant codex

# Route Claude Code through Z.ai’s endpoint
./setup.sh --assistant zai

# Shortcut flags
./setup.sh --use-codex
./setup.sh --use-claude
./setup.sh --use-zai

# Persist the preference via environment variable
echo "AI_ASSISTANT=zai" >> .env
```
The script defaults to Claude Code when no preference is set. At any time you can skip installing the selected assistant with `--skip-assistant` (aliases: `--skip-claude`, `--skip-zai`).

### Skip Specific Tools
```bash
./setup.sh --skip-assistant   # Aliases: --skip-claude, --skip-zai
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

# AI assistant preference (codex, claude, or zai)
AI_ASSISTANT=zai

# Z.ai API Key (required when AI_ASSISTANT=zai)
ZAI_API_KEY=zai-xxxxxxxxxxxx

# Anthropic API Key (optional when using Anthropic directly)
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
- ✅ Preferred AI assistant (Codex, Claude, or Z.ai) for AI help

### GitHub Codespaces
Automatically detected and configured:
- ✅ Preferred AI assistant (Codex, Claude, or Z.ai) for AI assistance
- ✅ GitHub CLI (essential)
- ✅ Doppler for dev secrets
- ❌ Tailscale (not needed)

### Local Development
Full setup for your workstation:
- ✅ All tools installed
- ✅ Complete configuration

## 🔧 Post-Installation

### Claude Code (if selected)
```bash
# Anthropic users
claude auth login

# Z.ai users
claude /status  # Confirms the GLM-4.5 endpoint is active
```

When `AI_ASSISTANT=zai`, the setup script writes your credentials to `~/.claude/settings.json` (creating the file if needed) so future shells automatically target `https://api.z.ai/api/anthropic`.

### Codex CLI (if selected)
```bash
codex login
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
- `quick-setup.sh` - Streamlined Z.ai setup
- `situations.yaml` - Environment and tool configurations
- `.env.example` - Template for API keys
- `.env` - Your API keys (git-ignored)
- `.claude/settings.template.json` - Claude settings template for Z.ai
- `.claude/settings.local.json` - Local Claude settings
- `install-claude-settings.sh` - Claude settings installation script

## 🔒 Security

- Never commit `.env` files
- Use environment-specific tokens
- Rotate credentials regularly
- Review `situations.yaml` before running

## 📄 License

MIT - Use freely for your own setups!

## 🤝 Contributing

PRs welcome! Please test on target platforms.
