#!/bin/bash

# ============================================================================
# Dynamic Development Environment Setup Script
# ============================================================================
# Purpose: Intelligently configures development tools based on detected environment
# Author: Your automated setup assistant
# Version: 2.0
# 
# This script automatically detects your environment (VPS, Codespaces, local dev)
# and installs only the tools appropriate for that context, avoiding unnecessary
# bloat while ensuring you have everything needed for your specific use case.
#
# Supported Environments:
#   - VPS/Production nodes
#   - GitHub Codespaces
#   - Local development machines
#   - CI/CD pipelines
#   - Docker containers
#
# Supported Operating Systems:
#   - macOS (via Homebrew)
#   - Ubuntu/Debian Linux
#   - RedHat/CentOS Linux
# ============================================================================

set -e  # Exit on error

# ============================================================================
# Configuration and Setup
# ============================================================================

# Script directory and config file paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/situations.yaml"

# Default AI assistant selection (can be overridden via env or CLI)
DEFAULT_AI_ASSISTANT="claude"

# Determine if an AI assistant value is supported
is_valid_ai_assistant() {
    case "$1" in
        codex|claude|zai)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Map the selected assistant to the internal tool identifier
get_ai_assistant_tool_id() {
    case "${AI_ASSISTANT:-$DEFAULT_AI_ASSISTANT}" in
        codex)
            echo "codex-cli"
            ;;
        zai)
            echo "claude-code"
            ;;
        *)
            echo "claude-code"
            ;;
    esac
}

# Human-friendly name for the selected assistant
get_ai_assistant_display_name() {
    case "${AI_ASSISTANT:-$DEFAULT_AI_ASSISTANT}" in
        codex)
            echo "Codex CLI"
            ;;
        zai)
            echo "Claude Code CLI (Z.ai)"
            ;;
        *)
            echo "Claude Code CLI"
            ;;
    esac
}

# Command binary used for the selected assistant
get_ai_assistant_command() {
    case "${AI_ASSISTANT:-$DEFAULT_AI_ASSISTANT}" in
        codex)
            echo "codex"
            ;;
        zai)
            echo "claude"
            ;;
        *)
            echo "claude"
            ;;
    esac
}

# Post-install instruction for the selected assistant
get_ai_assistant_next_step() {
    case "${AI_ASSISTANT:-$DEFAULT_AI_ASSISTANT}" in
        codex)
            echo "Run 'codex login' to authenticate"
            ;;
        zai)
            echo "Open a new shell and run 'claude /status' to confirm the Z.ai connection"
            ;;
        *)
            echo "Run 'claude auth login'"
            ;;
    esac
}

# ============================================================================
# Color Definitions for Terminal Output
# ============================================================================
RED='\033[0;31m'    # Error messages
GREEN='\033[0;32m'  # Success messages
YELLOW='\033[1;33m' # Warnings and prompts
BLUE='\033[0;34m'   # Information and headers
NC='\033[0m'        # No Color (reset)

# ============================================================================
# Utility Functions for Formatted Output
# ============================================================================
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# ============================================================================
# Display Functions
# ============================================================================

# Display the welcome banner with ASCII art
# Shows a stylized "NEW DEV SETUP" logo to make the script feel professional
print_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
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
EOF
    echo -e "${NC}"
}

# ============================================================================
# Environment Configuration
# ============================================================================

# Load environment variables from .env file
# This allows users to pre-configure their API keys and tokens for automated setup
# Reads from .env if it exists, otherwise shows a warning about .env.example
load_env() {
    if [ -f .env ]; then
        print_info "Loading environment variables from .env"
        # Export all non-comment lines from .env file
        export $(cat .env | grep -v '^#' | xargs)
    elif [ -f .env.example ]; then
        print_warning "No .env file found. Copy .env.example to .env and add your keys."
        print_info "Continuing with limited functionality..."
    fi
}

# ============================================================================
# YAML Configuration Parser
# ============================================================================

# Basic YAML parser for reading situations.yaml configuration
# Converts YAML key-value pairs into shell variables with proper prefixing
# Note: This is a simple parser that handles basic YAML structure
parse_yaml() {
    local file="$1"
    local prefix="$2"
    local s='[[:space:]]*'
    local w='[a-zA-Z0-9_]*'
    local fs=$(echo @|tr @ '\034')
    
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$file" |
    awk -F$fs '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=%s\n", "'"$prefix"'",vn, $2, $3);
        }
    }'
}

# ============================================================================
# Environment Detection Logic
# ============================================================================

# Intelligently detect the current environment based on various indicators
# Priority order: Codespaces > VPS > CI/CD > Container > Local Dev
# This ensures we pick the most specific environment when multiple conditions match
detect_environment() {
    print_info "Detecting environment..."
    
    # Priority 1: Check for GitHub Codespaces
    # Codespaces sets specific environment variables we can detect
    if [ -n "$CODESPACES" ] || [ -n "$GITHUB_CODESPACE_TOKEN" ]; then
        DETECTED_ENV="codespaces"
        print_success "Detected environment: GitHub Codespaces"
        return
    fi
    
    # Priority 2: Check for VPS/Production Node environment
    # Can be explicitly set via MACHINE_TYPE or IS_VPS environment variables
    if [ "$MACHINE_TYPE" = "vps" ] || [ "$IS_VPS" = "true" ]; then
        DETECTED_ENV="vps"
        print_success "Detected environment: VPS/Production Node"
        return
    fi
    
    # Priority 3: Check hostname patterns for VPS
    # Many VPS providers use specific hostname patterns
    HOSTNAME=$(hostname)
    if [[ "$HOSTNAME" =~ ^(node-|vps-) ]]; then
        DETECTED_ENV="vps"
        print_success "Detected environment: VPS (by hostname)"
        return
    fi
    
    # Priority 4: Check for CI/CD environment
    # Most CI systems set the CI environment variable
    if [ "$CI" = "true" ] || [ -n "$GITHUB_ACTIONS" ] || [ -n "$JENKINS_HOME" ]; then
        DETECTED_ENV="ci_cd"
        print_success "Detected environment: CI/CD Pipeline"
        return
    fi
    
    # Priority 5: Check for container/Docker environment
    # Docker creates /.dockerenv file in containers
    if [ -f "/.dockerenv" ] || [ "$CONTAINER" = "true" ]; then
        DETECTED_ENV="container"
        print_success "Detected environment: Container"
        return
    fi
    
    # Priority 6: Check for local development machine
    # macOS with VS Code installed is likely a dev machine
    if [[ "$OSTYPE" == "darwin"* ]] && command_exists code; then
        DETECTED_ENV="local_dev"
        print_success "Detected environment: Local Development Machine"
        return
    fi
    
    # Fallback: Use default configuration if no specific environment detected
    DETECTED_ENV="default"
    print_info "Using default configuration"
}

# ============================================================================
# Tool Selection Based on Environment
# ============================================================================

# Determine which tools to install based on the detected environment
# Each environment has a specific set of tools that make sense for its use case
# This prevents installing unnecessary tools (e.g., Claude Code on CI/CD systems)
get_environment_tools() {
    local env="$1"
    local assistant_tool
    assistant_tool=$(get_ai_assistant_tool_id)
    
    # Start with default tool set (all tools)
    TOOLS_TO_INSTALL=("tailscale" "github-cli" "${assistant_tool}" "doppler")
    
    # Override tool selection based on specific environment needs
    case "$env" in
        vps)
            # VPS needs all tools including Claude for remote development
            TOOLS_TO_INSTALL=("tailscale" "github-cli" "doppler" "${assistant_tool}")
            SKIP_TOOLS=()
            ;;
        codespaces)
            # Codespaces doesn't need Tailscale (GitHub handles networking)
            TOOLS_TO_INSTALL=("github-cli" "${assistant_tool}" "doppler")
            SKIP_TOOLS=("tailscale")
            ;;
        ci_cd)
            # CI/CD only needs GitHub CLI for releases/deployments
            TOOLS_TO_INSTALL=("github-cli")
            SKIP_TOOLS=("tailscale" "${assistant_tool}")
            ;;
        container)
            # Containers typically only need GitHub CLI
            TOOLS_TO_INSTALL=("github-cli")
            SKIP_TOOLS=("tailscale" "${assistant_tool}")
            ;;
        local_dev|default)
            # Local dev and default get everything
            TOOLS_TO_INSTALL=("tailscale" "github-cli" "${assistant_tool}" "doppler")
            SKIP_TOOLS=()
            ;;
    esac
    
    print_info "Tools to install: ${TOOLS_TO_INSTALL[*]}"
    if [ ${#SKIP_TOOLS[@]} -gt 0 ]; then
        print_info "Skipping tools: ${SKIP_TOOLS[*]}"
    fi
}

# ============================================================================
# Operating System Detection
# ============================================================================

# Detect the operating system to determine package manager and installation methods
# Supports macOS (Homebrew), Debian/Ubuntu (apt), and RedHat/CentOS (yum/dnf)
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_info "Detected OS: macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check for specific Linux distributions
        if [ -f /etc/debian_version ]; then
            OS="debian"
            print_info "Detected OS: Debian/Ubuntu"
        elif [ -f /etc/redhat-release ]; then
            OS="redhat"
            print_info "Detected OS: RedHat/CentOS"
        else
            OS="linux"
            print_info "Detected OS: Linux (generic)"
        fi
    else
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# ============================================================================
# Utility Functions
# ============================================================================

# Check if a command/program is installed and available in PATH
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# Package Manager Installation
# ============================================================================

# Install Homebrew package manager on macOS
# Homebrew is required for installing most tools on macOS
# Also handles PATH setup for Apple Silicon Macs (/opt/homebrew)
install_homebrew() {
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs (M1/M2/M3)
        # Intel Macs use /usr/local, Apple Silicon uses /opt/homebrew
        if [[ -d "/opt/homebrew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        print_success "Homebrew installed"
    else
        print_info "Homebrew already installed"
    fi
}

# ============================================================================
# Tool Installation Control
# ============================================================================

# Determine if a specific tool should be installed based on environment
# Returns 0 (true) if tool should be installed, 1 (false) if it should be skipped
should_install_tool() {
    local tool="$1"
    
    # First check if tool is explicitly in skip list
    for skip in "${SKIP_TOOLS[@]}"; do
        if [ "$skip" = "$tool" ]; then
            return 1  # Don't install
        fi
    done
    
    # Then check if tool is in install list
    for install in "${TOOLS_TO_INSTALL[@]}"; do
        if [ "$install" = "$tool" ]; then
            return 0  # Do install
        fi
    done
    
    return 1  # Default to not installing if not in list
}

# ============================================================================
# Tool Installation Functions
# ============================================================================

# Configure Claude Code to use the Z.ai Model API
# Creates or updates ~/.claude/settings.json with the required environment
# variables from either ZAI_API_KEY (legacy) or Doppler secrets.
configure_claude_for_zai() {
    local settings_dir="$HOME/.claude"
    local settings_file="$settings_dir/settings.json"
    local base_url="${ANTHROPIC_BASE_URL:-https://api.z.ai/api/anthropic}"
    local primary_model="${ANTHROPIC_MODEL:-glm-4.5}"
    local fast_model="${ANTHROPIC_SMALL_FAST_MODEL:-glm-4.5-air}"
    local auth_token="${ANTHROPIC_AUTH_TOKEN:-$ZAI_API_KEY}"

    mkdir -p "$settings_dir"

    if [ -z "$auth_token" ]; then
        # Check if Doppler is available and try to fetch from there
        if command_exists doppler; then
            print_info "No Z.ai API key found, trying to fetch from Doppler..."
            
            # Check if user is logged in to Doppler
            if ! doppler whoami >/dev/null 2>&1; then
                print_warning "Not logged in to Doppler. Please authenticate:"
                echo "  doppler login"
                echo ""
                print_info "After logging in, run: ./setup.sh --use-zai"
                return 1
            fi
            
            # Configure Doppler project if specified in .env
            if [ -n "$DOPPLER_PROJECT" ]; then
                print_info "Configuring Doppler project: $DOPPLER_PROJECT"
                doppler configure set project "$DOPPLER_PROJECT" --scope . >/dev/null 2>&1 || true
            fi
            
            # Try to load secrets from Doppler
            local config_name="${DOPPLER_CONFIG:-dev}"
            if eval $(doppler secrets download --config "$config_name" --format env --no-file 2>/dev/null); then
                auth_token="$ANTHROPIC_AUTH_TOKEN"
                base_url="$ANTHROPIC_BASE_URL"
                primary_model="$ANTHROPIC_MODEL"
                fast_model="$ANTHROPIC_SMALL_FAST_MODEL"
                print_success "Successfully loaded Z.ai configuration from Doppler"
            else
                print_warning "Failed to load secrets from Doppler"
                print_info "Make sure you have access to the $DOPPLER_PROJECT project"
            fi
        fi
        
        if [ -z "$auth_token" ]; then
            print_warning "No Z.ai API key found and Doppler access failed."
            print_info "Either:"
            print_info "1. Add ZAI_API_KEY to your .env file, or"
            print_info "2. Run 'doppler login' and configure project, or"
            print_info "3. Configure Claude Code manually after setup"
            return 1
        fi
    fi

    if command_exists python3; then
        CLAUDE_SETTINGS_FILE="$settings_file" \
        ZAI_BASE_URL="$base_url" \
        ZAI_PRIMARY_MODEL="$primary_model" \
        ZAI_FAST_MODEL="$fast_model" \
        python3 <<'PY'
import json
import os

settings_file = os.environ["CLAUDE_SETTINGS_FILE"]
base_url = os.environ["ZAI_BASE_URL"]
api_key = os.environ["ZAI_API_KEY"]
primary_model = os.environ["ZAI_PRIMARY_MODEL"]
fast_model = os.environ["ZAI_FAST_MODEL"]

data = {}
if os.path.exists(settings_file):
    try:
        with open(settings_file, "r", encoding="utf-8") as handle:
            loaded = json.load(handle)
            if isinstance(loaded, dict):
                data = loaded
    except Exception:
        data = {}

env = data.get("env")
if not isinstance(env, dict):
    env = {}
    data["env"] = env

env["ANTHROPIC_BASE_URL"] = base_url
env["ANTHROPIC_AUTH_TOKEN"] = auth_token
env.setdefault("ANTHROPIC_MODEL", primary_model)
env.setdefault("ANTHROPIC_SMALL_FAST_MODEL", fast_model)

with open(settings_file, "w", encoding="utf-8") as handle:
    json.dump(data, handle, indent=2)
    handle.write("\n")
PY
        if [ $? -ne 0 ]; then
            print_warning "Failed to update $settings_file via python3. Writing default configuration instead."
            cat > "$settings_file" <<EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "$base_url",
    "ANTHROPIC_AUTH_TOKEN": "$auth_token",
    "ANTHROPIC_MODEL": "$primary_model",
    "ANTHROPIC_SMALL_FAST_MODEL": "$fast_model"
  }
}
EOF
        fi
    else
        cat > "$settings_file" <<EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "$base_url",
    "ANTHROPIC_AUTH_TOKEN": "$auth_token",
    "ANTHROPIC_MODEL": "$primary_model",
    "ANTHROPIC_SMALL_FAST_MODEL": "$fast_model"
  }
}
EOF
    fi

    chmod 600 "$settings_file" 2>/dev/null || true
    print_success "Configured Claude Code to use the Z.ai Model API"
    print_info "Settings saved to $settings_file"
    return 0
}

# Install Claude Code CLI - Anthropic's AI coding assistant (supports Anthropic & Z.ai endpoints)
# Provides AI-powered code generation, refactoring, and assistance
# Installation method varies by OS: Homebrew on macOS, npm on Linux
install_claude() {
    # Skip if not needed for this environment
    if ! should_install_tool "claude-code"; then
        print_info "Skipping Claude Code installation (not needed for $DETECTED_ENV)"
        return
    fi
    
    print_info "Installing Claude Code CLI..."
    
    if command_exists claude; then
        print_info "Claude Code already installed, checking for updates..."
        if [[ "$OS" == "macos" ]]; then
            brew upgrade claude-code 2>/dev/null || true
        elif command_exists npm; then
            npm update -g @anthropic-ai/claude-code 2>/dev/null || true
        fi
    else
        case "$OS" in
            macos)
                brew install claude-code
                ;;
            debian|linux)
                # Claude Code requires Node.js 18+ 
                # Check and upgrade Node.js if needed before installing
                if command_exists node; then
                    NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
                    if [ "$NODE_VERSION" -lt 18 ]; then
                        print_warning "Node.js version is too old (v$NODE_VERSION). Claude Code requires Node.js 18+"
                        print_info "Installing Node.js 20 LTS..."
                        
                        # Install Node.js 20 LTS from NodeSource repository
                        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                        sudo apt-get install -y nodejs
                    fi
                elif ! command_exists npm; then
                    print_info "Installing Node.js 20 LTS and npm..."
                    # Install Node.js 20 LTS for better compatibility
                    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                fi
                
                # Install Claude Code globally via npm
                print_info "Installing Claude Code via npm..."
                npm install -g @anthropic-ai/claude-code
                ;;
            *)
                print_warning "Claude Code installation not automated for this OS"
                print_info "Please visit: https://github.com/anthropics/claude-code"
                return
                ;;
        esac
    fi
    
    # Configure Claude based on selected assistant
    case "${AI_ASSISTANT:-$DEFAULT_AI_ASSISTANT}" in
        zai)
            configure_claude_for_zai || {
                print_warning "Claude Code not fully configured for Z.ai."
                print_info "Set ZAI_API_KEY and rerun setup or add the environment variables manually."
            }
            ;;
        *)
            if [ -n "$ANTHROPIC_API_KEY" ]; then
                print_info "Configuring Claude with API key..."
                claude auth login --key "$ANTHROPIC_API_KEY" 2>/dev/null || {
                    print_warning "Claude already configured or auth failed"
                }
                print_success "Claude Code configured"
            else
                print_warning "No ANTHROPIC_API_KEY found. You'll need to configure Claude manually."
                print_info "Run: claude auth login"
            fi
            ;;
    esac

    print_success "Claude Code installation complete"
}

# Install Codex CLI - OpenAI's AI coding assistant
# Uses Homebrew on macOS and the official install script elsewhere
install_codex() {
    if ! should_install_tool "codex-cli"; then
        print_info "Skipping Codex CLI installation (not needed for $DETECTED_ENV)"
        return
    fi

    print_info "Installing Codex CLI..."

    if command_exists codex; then
        print_info "Codex CLI already installed, checking for updates..."
        if [[ "$OS" == "macos" ]]; then
            brew upgrade codex 2>/dev/null || true
        else
            if command_exists curl; then
                # Official installer handles updates when re-run
                curl -sSf https://cli.codex.build/install.sh | sh
            else
                print_warning "curl not found. Unable to auto-update Codex CLI."
                print_info "Manual update: https://github.com/openai/codex"
                return
            fi
        fi
    else
        case "$OS" in
            macos)
                brew install codex
                ;;
            debian|linux|redhat)
                if command_exists curl; then
                    curl -sSf https://cli.codex.build/install.sh | sh
                else
                    print_warning "curl not found. Install curl to bootstrap Codex CLI."
                    print_info "Manual install: https://github.com/openai/codex"
                    return
                fi
                ;;
            *)
                print_warning "Codex installation not automated for this OS"
                print_info "Please visit: https://github.com/openai/codex"
                return
                ;;
        esac
    fi

    if command_exists codex; then
        print_success "Codex CLI installation complete"
        print_info "Reminder: run 'codex login' to authenticate if you haven't already"
    else
        print_warning "Codex CLI not detected after installation attempt"
    fi
}

# Install GitHub CLI - Command line interface for GitHub
# Essential for CI/CD, releases, PR management, and GitHub operations
# Supports authentication, repo management, and workflow automation
install_github_cli() {
    # Skip if not needed for this environment
    if ! should_install_tool "github-cli"; then
        print_info "Skipping GitHub CLI installation (not needed for $DETECTED_ENV)"
        return
    fi
    
    print_info "Installing GitHub CLI..."
    
    if command_exists gh; then
        print_info "GitHub CLI already installed, checking for updates..."
        case "$OS" in
            macos)
                brew upgrade gh 2>/dev/null || true
                ;;
            debian)
                # Only update gh package, not all system packages
                sudo apt-get update > /dev/null 2>&1
                sudo apt-get install --only-upgrade gh -y 2>/dev/null || true
                ;;
        esac
    else
        case "$OS" in
            macos)
                brew install gh
                ;;
            debian)
                # Add GitHub CLI repository
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt-get update
                sudo apt-get install gh -y
                ;;
            redhat)
                sudo dnf install -y 'dnf-command(config-manager)'
                sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                sudo dnf install -y gh
                ;;
            *)
                print_warning "GitHub CLI installation not automated for this OS"
                print_info "Please visit: https://cli.github.com/manual/installation"
                return
                ;;
        esac
    fi
    
    # Configure GitHub CLI if token is available
    if [ -n "$GITHUB_TOKEN" ]; then
        print_info "Configuring GitHub CLI with token..."
        echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null || {
            print_warning "GitHub CLI already configured or token auth failed"
        }
        print_success "GitHub CLI configured"
    else
        print_warning "No GITHUB_TOKEN found. You'll need to authenticate manually."
        print_info "Run: gh auth login"
    fi
    
    print_success "GitHub CLI installation complete"
}

# Install Doppler CLI - SecretOps platform for managing environment variables
# Provides centralized secret management, environment syncing, and team collaboration
# Eliminates the need for .env files in production by pulling secrets at runtime
install_doppler() {
    # Skip if not needed for this environment
    if ! should_install_tool "doppler"; then
        print_info "Skipping Doppler installation (not needed for $DETECTED_ENV)"
        return
    fi
    
    print_info "Installing Doppler CLI..."
    
    if command_exists doppler; then
        print_info "Doppler already installed, checking for updates..."
        case "$OS" in
            macos)
                brew upgrade dopplerhq/tap/doppler 2>/dev/null || true
                ;;
            debian)
                sudo apt-get update && sudo apt-get upgrade doppler -y 2>/dev/null || true
                ;;
        esac
    else
        case "$OS" in
            macos)
                brew install dopplerhq/tap/doppler
                ;;
            debian)
                # Install prerequisites
                sudo apt-get update
                sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
                
                # Add Doppler's GPG key and repository (overwrite if exists)
                curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg
                echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list
                
                # Install Doppler
                sudo apt-get update
                sudo apt-get install -y doppler
                ;;
            redhat)
                # Add Doppler's YUM repository
                sudo rpm --import 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key'
                curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/config.rpm.txt' | sudo tee /etc/yum.repos.d/doppler-cli.repo
                
                # Install Doppler
                sudo yum install -y doppler
                ;;
            *)
                print_warning "Doppler installation not automated for this OS"
                print_info "Please visit: https://docs.doppler.com/docs/install-cli"
                return
                ;;
        esac
    fi
    
    # Configure Doppler if token is available
    if [ -n "$DOPPLER_TOKEN" ]; then
        print_info "Configuring Doppler with token..."
        doppler configure set token "$DOPPLER_TOKEN" --scope / 2>/dev/null || {
            print_warning "Doppler already configured or auth failed"
        }
        print_success "Doppler configured"
    else
        print_warning "No DOPPLER_TOKEN found. You'll need to authenticate manually."
        print_info "Run: doppler login"
    fi
    
    print_success "Doppler installation complete"
}

# Install Tailscale - Zero-config VPN for secure networking
# Creates encrypted point-to-point connections between devices
# Perfect for accessing development servers, databases, and internal services securely
install_tailscale() {
    # Skip if not needed for this environment
    if ! should_install_tool "tailscale"; then
        print_info "Skipping Tailscale installation (not needed for $DETECTED_ENV)"
        return
    fi
    
    print_info "Installing Tailscale..."
    
    if command_exists tailscale; then
        print_info "Tailscale already installed"
    else
        case "$OS" in
            macos)
                brew install tailscale
                print_info "Starting Tailscale..."
                brew services start tailscale
                ;;
            debian)
                curl -fsSL https://tailscale.com/install.sh | sh
                ;;
            redhat)
                curl -fsSL https://tailscale.com/install.sh | sh
                ;;
            *)
                print_warning "Tailscale installation not automated for this OS"
                print_info "Please visit: https://tailscale.com/download"
                return
                ;;
        esac
    fi
    
    # Configure Tailscale if auth key is available
    if [ -n "$TAILSCALE_AUTH_KEY" ]; then
        print_info "Configuring Tailscale with auth key..."
        sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY"
        print_success "Tailscale configured"
    else
        print_info "No TAILSCALE_AUTH_KEY found."
        print_info "Run 'tailscale up' to authenticate interactively"
    fi
    
    print_success "Tailscale installation complete"
}

# ============================================================================
# Installation Verification
# ============================================================================

# Verify that all tools were installed successfully
# Checks each tool's availability and version, reporting any failures
verify_installations() {
    print_info "Verifying installations..."
    echo ""
    
    local all_good=true
    
    # Check AI assistant
    local assistant_tool
    assistant_tool=$(get_ai_assistant_tool_id)
    if should_install_tool "$assistant_tool"; then
        local assistant_cmd
        assistant_cmd=$(get_ai_assistant_command)
        local assistant_name
        assistant_name=$(get_ai_assistant_display_name)

        if command_exists "$assistant_cmd"; then
            local version_output
            if [ "$assistant_cmd" = "codex" ]; then
                version_output=$($assistant_cmd --version 2>/dev/null | tail -n1)
                if [ -z "$version_output" ]; then
                    version_output="installed"
                fi
            else
                version_output=$($assistant_cmd --version 2>/dev/null || echo "installed")
            fi
            print_success "${assistant_name}: ${version_output}"
        else
            print_error "${assistant_name}: not found"
            all_good=false
        fi
    fi
    
    # Check GitHub CLI
    if should_install_tool "github-cli"; then
        if command_exists gh; then
            print_success "GitHub CLI: $(gh --version | head -n1)"
        else
            print_error "GitHub CLI: not found"
            all_good=false
        fi
    fi
    
    # Check Doppler
    if should_install_tool "doppler"; then
        if command_exists doppler; then
            print_success "Doppler: $(doppler --version 2>/dev/null || echo 'installed')"
        else
            print_error "Doppler: not found"
            all_good=false
        fi
    fi
    
    # Check Tailscale
    if should_install_tool "tailscale"; then
        if command_exists tailscale; then
            print_success "Tailscale: $(tailscale --version | head -n1)"
        else
            print_error "Tailscale: not found"
            all_good=false
        fi
    fi
    
    echo ""
    if [ "$all_good" = true ]; then
        print_success "All tools installed successfully!"
    else
        print_warning "Some tools failed to install. Please check the errors above."
    fi
}

# ============================================================================
# Environment-Specific Configuration
# ============================================================================

# Run additional setup tasks specific to each environment
# This allows for custom configuration beyond just tool installation
run_additional_setup() {
    local env="$1"
    
    case "$env" in
        vps)
            print_info "Running VPS-specific setup..."
            # VPS might need specific firewall rules, systemd services, etc.
            # Add VPS-specific setup here
            ;;
        codespaces)
            print_info "Running Codespaces-specific setup..."
            # Configure useful git aliases for Codespaces environment
            git config --global alias.co checkout 2>/dev/null || true
            git config --global alias.br branch 2>/dev/null || true
            git config --global alias.ci commit 2>/dev/null || true
            git config --global alias.st status 2>/dev/null || true
            ;;
        local_dev)
            print_info "Running local development setup..."
            # Local dev might need IDE configs, desktop shortcuts, etc.
            # Add local dev specific setup here
            ;;
    esac
}

# ============================================================================
# Main Installation Flow
# ============================================================================

# Main entry point for the script
# Handles argument parsing, environment detection, and orchestrates the installation
main() {
    print_banner
    
    # ========================================
    # Parse Command Line Arguments
    # ========================================
    SKIP_ASSISTANT=false
    USER_SKIP_TOOLS=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --env ENV         Force specific environment (vps, codespaces, local_dev, ci_cd, container)"
                echo "  --assistant NAME  Choose AI assistant (codex, claude, or zai)"
                echo "  --use-codex       Shortcut for --assistant codex"
                echo "  --use-claude      Shortcut for --assistant claude"
                echo "  --use-zai         Shortcut for --assistant zai"
                echo "  --skip-assistant  Skip installing the selected AI assistant"
                echo "  --skip-github     Skip GitHub CLI installation"
                echo "  --skip-tailscale  Skip Tailscale installation"
                echo "  --skip-doppler    Skip Doppler installation"
                echo "  --list-envs       List available environments"
                echo "  --help, -h        Show this help message"
                exit 0
                ;;
            --assistant)
                FORCED_ASSISTANT="$2"
                shift 2
                ;;
            --assistant=*)
                FORCED_ASSISTANT="${1#*=}"
                shift
                ;;
            --use-codex)
                FORCED_ASSISTANT="codex"
                shift
                ;;
            --use-claude)
                FORCED_ASSISTANT="claude"
                shift
                ;;
            --use-zai)
                FORCED_ASSISTANT="zai"
                shift
                ;;
            --env)
                FORCE_ENV="$2"
                shift 2
                ;;
            --list-envs)
                echo "Available environments:"
                echo "  vps         - VPS/Production nodes"
                echo "  codespaces  - GitHub Codespaces"
                echo "  local_dev   - Local development machine"
                echo "  ci_cd       - CI/CD pipeline"
                echo "  container   - Docker/container environment"
                exit 0
                ;;
            --skip-assistant|--skip-claude|--skip-zai)
                SKIP_ASSISTANT=true
                shift
                ;;
            --skip-github)
                USER_SKIP_TOOLS+=("github-cli")
                shift
                ;;
            --skip-tailscale)
                USER_SKIP_TOOLS+=("tailscale")
                shift
                ;;
            --skip-doppler)
                USER_SKIP_TOOLS+=("doppler")
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # ========================================
    # Initial Setup and Detection
    # ========================================
    
    print_info "Starting Dynamic Development Environment Setup..."
    echo ""
    
    # Check if configuration file exists (optional - we have defaults)
    if [ ! -f "$CONFIG_FILE" ]; then
        print_warning "Configuration file not found: $CONFIG_FILE"
        print_info "Using default configuration"
    fi
    
    # Load environment variables from .env file if present
    load_env

    # Resolve AI assistant preference (CLI overrides env/config)
    if [ -n "$FORCED_ASSISTANT" ]; then
        AI_ASSISTANT="$FORCED_ASSISTANT"
    fi

    if [ -n "$AI_ASSISTANT" ]; then
        AI_ASSISTANT=$(echo "$AI_ASSISTANT" | tr '[:upper:]' '[:lower:]')
    fi

    if [ -z "$AI_ASSISTANT" ]; then
        AI_ASSISTANT="$DEFAULT_AI_ASSISTANT"
    fi

    if ! is_valid_ai_assistant "$AI_ASSISTANT"; then
        print_error "Unsupported AI assistant: $AI_ASSISTANT"
        echo "Valid options: codex, claude, zai"
        exit 1
    fi

    # Detect the operating system (macOS, Linux, etc.)
    detect_os

    # Detect or use forced environment
    if [ -n "$FORCE_ENV" ]; then
        DETECTED_ENV="$FORCE_ENV"
        print_info "Using forced environment: $DETECTED_ENV"
    else
        # Auto-detect environment based on system characteristics
        detect_environment
    fi
    
    # Get the appropriate tool list for detected environment
    get_environment_tools "$DETECTED_ENV"

    local assistant_tool
    assistant_tool=$(get_ai_assistant_tool_id)

    if [ "$SKIP_ASSISTANT" = true ]; then
        USER_SKIP_TOOLS+=("$assistant_tool")
    fi

    if [ ${#USER_SKIP_TOOLS[@]} -gt 0 ]; then
        for skip_tool in "${USER_SKIP_TOOLS[@]}"; do
            local already_listed=false
            for existing_skip in "${SKIP_TOOLS[@]}"; do
                if [ "$existing_skip" = "$skip_tool" ]; then
                    already_listed=true
                    break
                fi
            done
            if [ "$already_listed" = false ]; then
                SKIP_TOOLS+=("$skip_tool")
            fi
        done

        local updated_tools=()
        for tool in "${TOOLS_TO_INSTALL[@]}"; do
            local skip=false
            for skip_tool in "${USER_SKIP_TOOLS[@]}"; do
                if [ "$tool" = "$skip_tool" ]; then
                    skip=true
                    break
                fi
            done
            if [ "$skip" = false ]; then
                updated_tools+=("$tool")
            fi
        done
        TOOLS_TO_INSTALL=("${updated_tools[@]}")
    fi

    echo ""
    print_info "Environment: $DETECTED_ENV"
    print_info "OS: $OS"
    print_info "AI assistant: $(get_ai_assistant_display_name)"
    echo ""
    
    # ========================================
    # Display Installation Plan
    # ========================================
    # Show user what will be installed before making any changes
    # This provides transparency and allows cancellation if needed
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Installation Sequence:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    local step=1
    
    # Show Homebrew if macOS
    if [[ "$OS" == "macos" ]]; then
        echo -e "  ${YELLOW}$step.${NC} Homebrew Package Manager"
        if command_exists brew; then
            echo -e "     ${GREEN}✓${NC} Already installed"
        else
            echo -e "     ${BLUE}→${NC} Will install"
        fi
        ((step++))
        echo ""
    fi
    
    # Show each tool that will be installed
    for tool in "${TOOLS_TO_INSTALL[@]}"; do
        case "$tool" in
                claude-code)
                    echo -e "  ${YELLOW}$step.${NC} $(get_ai_assistant_display_name)"
                if command_exists claude; then
                    echo -e "     ${GREEN}✓${NC} Already installed (will check for updates)"
                else
                    echo -e "     ${BLUE}→${NC} Will install via $([ "$OS" = "macos" ] && echo "Homebrew" || echo "npm")"
                fi
                if [ -n "$ANTHROPIC_API_KEY" ]; then
                    echo -e "     ${BLUE}→${NC} Will auto-configure with API key"
                fi
                ;;
            codex-cli)
                echo -e "  ${YELLOW}$step.${NC} Codex CLI"
                if command_exists codex; then
                    echo -e "     ${GREEN}✓${NC} Already installed (will check for updates)"
                else
                    if [ "$OS" = "macos" ]; then
                        echo -e "     ${BLUE}→${NC} Will install via Homebrew"
                    else
                        echo -e "     ${BLUE}→${NC} Will install via official install script"
                    fi
                fi
                echo -e "     ${BLUE}→${NC} Post-install: run 'codex login' to authenticate"
                ;;
            github-cli)
                echo -e "  ${YELLOW}$step.${NC} GitHub CLI"
                if command_exists gh; then
                    echo -e "     ${GREEN}✓${NC} Already installed (will check for updates)"
                else
                    echo -e "     ${BLUE}→${NC} Will install"
                fi
                if [ -n "$GITHUB_TOKEN" ]; then
                    echo -e "     ${BLUE}→${NC} Will auto-configure with token"
                fi
                ;;
            doppler)
                echo -e "  ${YELLOW}$step.${NC} Doppler SecretOps"
                if command_exists doppler; then
                    echo -e "     ${GREEN}✓${NC} Already installed (will check for updates)"
                else
                    echo -e "     ${BLUE}→${NC} Will install"
                fi
                if [ -n "$DOPPLER_TOKEN" ]; then
                    echo -e "     ${BLUE}→${NC} Will auto-configure with token"
                fi
                ;;
            tailscale)
                echo -e "  ${YELLOW}$step.${NC} Tailscale VPN"
                if command_exists tailscale; then
                    echo -e "     ${GREEN}✓${NC} Already installed"
                else
                    echo -e "     ${BLUE}→${NC} Will install"
                fi
                if [ -n "$TAILSCALE_AUTH_KEY" ]; then
                    echo -e "     ${BLUE}→${NC} Will auto-configure with auth key"
                fi
                ;;
        esac
        ((step++))
        echo ""
    done
    
    # Show skipped tools if any
    if [ ${#SKIP_TOOLS[@]} -gt 0 ]; then
        echo -e "${YELLOW}Skipping:${NC}"
        for skip in "${SKIP_TOOLS[@]}"; do
            case "$skip" in
                claude-code) echo -e "  ${RED}✗${NC} $(get_ai_assistant_display_name)" ;;
                codex-cli) echo -e "  ${RED}✗${NC} Codex CLI" ;;
                github-cli) echo -e "  ${RED}✗${NC} GitHub CLI" ;;
                doppler) echo -e "  ${RED}✗${NC} Doppler SecretOps" ;;
                tailscale) echo -e "  ${RED}✗${NC} Tailscale VPN" ;;
            esac
        done
        echo ""
    fi
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # ========================================
    # User Confirmation
    # ========================================
    # Ask for user confirmation before making system changes
    read -p "$(echo -e ${YELLOW}"Proceed with installation? [Y/n]: "${NC})" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [ -n "$REPLY" ]; then
        print_info "Installation cancelled"
        exit 0
    fi
    echo ""
    
    # ========================================
    # Package Manager Setup (macOS only)
    # ========================================
    # Install Homebrew on macOS
    if [[ "$OS" == "macos" ]]; then
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}Step 1/${#TOOLS_TO_INSTALL[@]}: Package Manager${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        install_homebrew
        echo ""
    fi
    
    # ========================================
    # Tool Installation Loop
    # ========================================
    # Install each tool with progress tracking and visual feedback
    local current_step=1
    local total_steps=${#TOOLS_TO_INSTALL[@]}
    
    for tool in "${TOOLS_TO_INSTALL[@]}"; do
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        case "$tool" in
            claude-code)
                echo -e "${BLUE}Step $current_step/$total_steps: $(get_ai_assistant_display_name)${NC}"
                ;;
            codex-cli)
                echo -e "${BLUE}Step $current_step/$total_steps: Codex CLI${NC}"
                ;;
            github-cli)
                echo -e "${BLUE}Step $current_step/$total_steps: GitHub CLI${NC}"
                ;;
            doppler)
                echo -e "${BLUE}Step $current_step/$total_steps: Doppler SecretOps${NC}"
                ;;
            tailscale)
                echo -e "${BLUE}Step $current_step/$total_steps: Tailscale VPN${NC}"
                ;;
        esac
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        case "$tool" in
            claude-code) install_claude ;;
            codex-cli) install_codex ;;
            github-cli) install_github_cli ;;
            doppler) install_doppler ;;
            tailscale) install_tailscale ;;
        esac
        
        ((current_step++))
        echo ""
    done
    
    # ========================================
    # Post-Installation Configuration
    # ========================================
    
    # Run environment-specific additional setup
    run_additional_setup "$DETECTED_ENV"
    echo ""
    
    # Verify all tools were installed successfully
    verify_installations
    
    # ========================================
    # Setup Complete - Show Next Steps
    # ========================================
    
    print_info "Setup complete! 🚀"
    echo ""
    print_info "Environment configured: $DETECTED_ENV"
    echo ""
    print_info "Next steps:"
    
    local assistant_next_step
    assistant_next_step=$(get_ai_assistant_next_step)

    # Environment-specific next steps
    case "$DETECTED_ENV" in
        vps)
            echo "  1. Configure Tailscale: sudo tailscale up"
            echo "  2. ${assistant_next_step}"
            echo "  3. Setup GitHub deploy keys if needed"
            ;;
        codespaces)
            echo "  1. Run 'gh auth login' if not already configured"
            echo "  2. ${assistant_next_step}"
            ;;
        local_dev)
            echo "  1. Copy .env.example to .env and add your API keys"
            echo "  2. ${assistant_next_step}"
            echo "  3. Run 'gh auth login' if not already configured"
            echo "  4. Run 'tailscale up' to connect to your tailnet"
            ;;
        *)
            echo "  1. Copy .env.example to .env and add your API keys"
            echo "  2. Configure the installed tools as needed"
            ;;
    esac
    
    echo ""
    print_success "Your $DETECTED_ENV environment is ready!"
}

# ============================================================================
# Script Entry Point
# ============================================================================
# Execute the main function with all command line arguments
main "$@"
