#!/bin/bash

# New Development Machine Setup - Dynamic Environment Configuration
# Reads situations.yaml to determine what tools to install based on environment
# Supports: macOS, Ubuntu/Debian, and other Linux distributions

set -e  # Exit on error

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/situations.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# ASCII Art Banner
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

# Load environment variables
load_env() {
    if [ -f .env ]; then
        print_info "Loading environment variables from .env"
        export $(cat .env | grep -v '^#' | xargs)
    elif [ -f .env.example ]; then
        print_warning "No .env file found. Copy .env.example to .env and add your keys."
        print_info "Continuing with limited functionality..."
    fi
}

# Parse YAML configuration (basic parser)
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

# Detect current environment based on conditions in situations.yaml
detect_environment() {
    print_info "Detecting environment..."
    
    # Check for GitHub Codespaces
    if [ -n "$CODESPACES" ] || [ -n "$GITHUB_CODESPACE_TOKEN" ]; then
        DETECTED_ENV="codespaces"
        print_success "Detected environment: GitHub Codespaces"
        return
    fi
    
    # Check for VPS/Node environment
    if [ "$MACHINE_TYPE" = "vps" ] || [ "$IS_VPS" = "true" ]; then
        DETECTED_ENV="vps"
        print_success "Detected environment: VPS/Production Node"
        return
    fi
    
    # Check hostname patterns for VPS
    HOSTNAME=$(hostname)
    if [[ "$HOSTNAME" =~ ^(node-|vps-) ]]; then
        DETECTED_ENV="vps"
        print_success "Detected environment: VPS (by hostname)"
        return
    fi
    
    # Check for CI/CD environment
    if [ "$CI" = "true" ] || [ -n "$GITHUB_ACTIONS" ] || [ -n "$JENKINS_HOME" ]; then
        DETECTED_ENV="ci_cd"
        print_success "Detected environment: CI/CD Pipeline"
        return
    fi
    
    # Check for container environment
    if [ -f "/.dockerenv" ] || [ "$CONTAINER" = "true" ]; then
        DETECTED_ENV="container"
        print_success "Detected environment: Container"
        return
    fi
    
    # Check for local dev (macOS with VS Code)
    if [[ "$OSTYPE" == "darwin"* ]] && command_exists code; then
        DETECTED_ENV="local_dev"
        print_success "Detected environment: Local Development Machine"
        return
    fi
    
    # Default to using all default tools
    DETECTED_ENV="default"
    print_info "Using default configuration"
}

# Get tools list for detected environment
get_environment_tools() {
    local env="$1"
    
    # Start with default tools
    TOOLS_TO_INSTALL=("tailscale" "github-cli" "claude-code" "doppler")
    
    # Override based on environment if specified in YAML
    case "$env" in
        vps)
            TOOLS_TO_INSTALL=("tailscale" "github-cli" "doppler")
            SKIP_TOOLS=("claude-code")
            ;;
        codespaces)
            TOOLS_TO_INSTALL=("github-cli" "claude-code" "doppler")
            SKIP_TOOLS=("tailscale")
            ;;
        ci_cd)
            TOOLS_TO_INSTALL=("github-cli")
            SKIP_TOOLS=("tailscale" "claude-code")
            ;;
        container)
            TOOLS_TO_INSTALL=("github-cli")
            SKIP_TOOLS=("tailscale" "claude-code")
            ;;
        local_dev|default)
            TOOLS_TO_INSTALL=("tailscale" "github-cli" "claude-code")
            SKIP_TOOLS=()
            ;;
    esac
    
    print_info "Tools to install: ${TOOLS_TO_INSTALL[*]}"
    if [ ${#SKIP_TOOLS[@]} -gt 0 ]; then
        print_info "Skipping tools: ${SKIP_TOOLS[*]}"
    fi
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        print_info "Detected OS: macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew (macOS)
install_homebrew() {
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -d "/opt/homebrew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        print_success "Homebrew installed"
    else
        print_info "Homebrew already installed"
    fi
}

# Check if tool should be installed
should_install_tool() {
    local tool="$1"
    
    # Check if tool is in skip list
    for skip in "${SKIP_TOOLS[@]}"; do
        if [ "$skip" = "$tool" ]; then
            return 1
        fi
    done
    
    # Check if tool is in install list
    for install in "${TOOLS_TO_INSTALL[@]}"; do
        if [ "$install" = "$tool" ]; then
            return 0
        fi
    done
    
    return 1
}

# Install Claude Code CLI
install_claude() {
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
                # Check Node.js version if installed
                if command_exists node; then
                    NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
                    if [ "$NODE_VERSION" -lt 18 ]; then
                        print_warning "Node.js version is too old (v$NODE_VERSION). Claude Code requires Node.js 18+"
                        print_info "Installing Node.js 20 LTS..."
                        
                        # Install Node.js 20 LTS
                        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                        sudo apt-get install -y nodejs
                    fi
                elif ! command_exists npm; then
                    print_info "Installing Node.js 20 LTS and npm..."
                    # Install Node.js 20 LTS for better compatibility
                    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
                    sudo apt-get install -y nodejs
                fi
                
                # Install Claude Code via npm
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
    
    # Configure Claude with API key if available
    if [ -n "$ANTHROPIC_API_KEY" ]; then
        print_info "Configuring Claude with API key..."
        claude auth login --key "$ANTHROPIC_API_KEY" 2>/dev/null || true
        print_success "Claude Code configured"
    else
        print_warning "No ANTHROPIC_API_KEY found. You'll need to configure Claude manually."
        print_info "Run: claude auth login"
    fi
    
    print_success "Claude Code installation complete"
}

# Install GitHub CLI
install_github_cli() {
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
                sudo apt-get update && sudo apt-get upgrade gh -y 2>/dev/null || true
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
        echo "$GITHUB_TOKEN" | gh auth login --with-token
        print_success "GitHub CLI configured"
    else
        print_warning "No GITHUB_TOKEN found. You'll need to authenticate manually."
        print_info "Run: gh auth login"
    fi
    
    print_success "GitHub CLI installation complete"
}

# Install Doppler CLI
install_doppler() {
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
                
                # Add Doppler's GPG key and repository
                curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg
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
        doppler configure set token "$DOPPLER_TOKEN" --scope / 2>/dev/null || true
        print_success "Doppler configured"
    else
        print_warning "No DOPPLER_TOKEN found. You'll need to authenticate manually."
        print_info "Run: doppler login"
    fi
    
    print_success "Doppler installation complete"
}

# Install Tailscale
install_tailscale() {
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

# Verify installations
verify_installations() {
    print_info "Verifying installations..."
    echo ""
    
    local all_good=true
    
    # Check Claude
    if should_install_tool "claude-code"; then
        if command_exists claude; then
            print_success "Claude Code: $(claude --version 2>/dev/null || echo 'installed')"
        else
            print_error "Claude Code: not found"
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

# Run additional setup functions based on environment
run_additional_setup() {
    local env="$1"
    
    case "$env" in
        vps)
            print_info "Running VPS-specific setup..."
            # Add VPS-specific setup here
            ;;
        codespaces)
            print_info "Running Codespaces-specific setup..."
            # Configure git aliases for Codespaces
            git config --global alias.co checkout 2>/dev/null || true
            git config --global alias.br branch 2>/dev/null || true
            git config --global alias.ci commit 2>/dev/null || true
            git config --global alias.st status 2>/dev/null || true
            ;;
        local_dev)
            print_info "Running local development setup..."
            # Add local dev specific setup here
            ;;
    esac
}

# Main installation flow
main() {
    print_banner
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --env ENV         Force specific environment (vps, codespaces, local_dev, ci_cd, container)"
                echo "  --skip-claude     Skip Claude Code installation"
                echo "  --skip-github     Skip GitHub CLI installation"
                echo "  --skip-tailscale  Skip Tailscale installation"
                echo "  --skip-doppler    Skip Doppler installation"
                echo "  --list-envs       List available environments"
                echo "  --help, -h        Show this help message"
                exit 0
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
            --skip-claude)
                SKIP_TOOLS+=("claude-code")
                shift
                ;;
            --skip-github)
                SKIP_TOOLS+=("github-cli")
                shift
                ;;
            --skip-tailscale)
                SKIP_TOOLS+=("tailscale")
                shift
                ;;
            --skip-doppler)
                SKIP_TOOLS+=("doppler")
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    print_info "Starting Dynamic Development Environment Setup..."
    echo ""
    
    # Check if configuration file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        print_warning "Configuration file not found: $CONFIG_FILE"
        print_info "Using default configuration"
    fi
    
    # Load environment variables
    load_env
    
    # Detect operating system
    detect_os
    
    # Detect or use forced environment
    if [ -n "$FORCE_ENV" ]; then
        DETECTED_ENV="$FORCE_ENV"
        print_info "Using forced environment: $DETECTED_ENV"
    else
        detect_environment
    fi
    
    # Get tools list for detected environment
    get_environment_tools "$DETECTED_ENV"
    
    echo ""
    print_info "Environment: $DETECTED_ENV"
    print_info "OS: $OS"
    echo ""
    
    # Install Homebrew on macOS
    if [[ "$OS" == "macos" ]]; then
        install_homebrew
    fi
    
    # Install tools
    install_claude
    echo ""
    install_github_cli
    echo ""
    install_doppler
    echo ""
    install_tailscale
    echo ""
    
    # Run additional setup for environment
    run_additional_setup "$DETECTED_ENV"
    echo ""
    
    # Verify all installations
    verify_installations
    
    print_info "Setup complete! 🚀"
    echo ""
    print_info "Environment configured: $DETECTED_ENV"
    echo ""
    print_info "Next steps:"
    
    # Environment-specific next steps
    case "$DETECTED_ENV" in
        vps)
            echo "  1. Configure Tailscale: sudo tailscale up"
            echo "  2. Setup GitHub deploy keys if needed"
            ;;
        codespaces)
            echo "  1. Run 'gh auth login' if not already configured"
            echo "  2. Configure Claude: claude auth login"
            ;;
        local_dev)
            echo "  1. Copy .env.example to .env and add your API keys"
            echo "  2. Run 'claude auth login' if not already configured"
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

# Run main function
main "$@"