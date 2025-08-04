#!/bin/bash

# New Development Machine Setup - Essential Tools Installation Script
# Installs: Claude Code CLI, GitHub CLI, and Tailscale
# Supports: macOS, Ubuntu/Debian, and other Linux distributions

set -e  # Exit on error

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

# Install Claude Code CLI
install_claude() {
    if [ "${SKIP_CLAUDE}" == "true" ]; then
        print_info "Skipping Claude Code installation"
        return
    fi
    
    print_info "Installing Claude Code CLI..."
    
    if command_exists claude; then
        print_info "Claude Code already installed, checking for updates..."
        if [[ "$OS" == "macos" ]]; then
            brew upgrade claude-code 2>/dev/null || true
        fi
    else
        case "$OS" in
            macos)
                brew install claude-code
                ;;
            debian|linux)
                # Install using npm (cross-platform method)
                if ! command_exists npm; then
                    print_info "Installing Node.js and npm first..."
                    if [[ "$OS" == "debian" ]]; then
                        sudo apt-get update
                        sudo apt-get install -y nodejs npm
                    else
                        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
                        sudo yum install -y nodejs
                    fi
                fi
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
    if [ "${SKIP_GITHUB}" == "true" ]; then
        print_info "Skipping GitHub CLI installation"
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

# Install Tailscale
install_tailscale() {
    if [ "${SKIP_TAILSCALE}" == "true" ]; then
        print_info "Skipping Tailscale installation"
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
    if command_exists claude; then
        print_success "Claude Code: $(claude --version 2>/dev/null || echo 'installed')"
    else
        print_error "Claude Code: not found"
        all_good=false
    fi
    
    # Check GitHub CLI
    if command_exists gh; then
        print_success "GitHub CLI: $(gh --version | head -n1)"
    else
        print_error "GitHub CLI: not found"
        all_good=false
    fi
    
    # Check Tailscale
    if command_exists tailscale; then
        print_success "Tailscale: $(tailscale --version | head -n1)"
    else
        print_error "Tailscale: not found"
        all_good=false
    fi
    
    echo ""
    if [ "$all_good" = true ]; then
        print_success "All tools installed successfully!"
    else
        print_warning "Some tools failed to install. Please check the errors above."
    fi
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
                echo "  --skip-claude     Skip Claude Code installation"
                echo "  --skip-github     Skip GitHub CLI installation"
                echo "  --skip-tailscale  Skip Tailscale installation"
                echo "  --help, -h        Show this help message"
                exit 0
                ;;
            --skip-claude)
                export SKIP_CLAUDE=true
                shift
                ;;
            --skip-github)
                export SKIP_GITHUB=true
                shift
                ;;
            --skip-tailscale)
                export SKIP_TAILSCALE=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    print_info "Starting New Development Machine Setup..."
    echo ""
    
    # Load environment variables
    load_env
    
    # Detect operating system
    detect_os
    
    # Install Homebrew on macOS
    if [[ "$OS" == "macos" ]]; then
        install_homebrew
    fi
    
    # Install tools
    install_claude
    echo ""
    install_github_cli
    echo ""
    install_tailscale
    echo ""
    
    # Verify all installations
    verify_installations
    
    print_info "Setup complete! 🚀"
    echo ""
    print_info "Next steps:"
    echo "  1. Copy .env.example to .env and add your API keys"
    echo "  2. Run 'claude auth login' if not already configured"
    echo "  3. Run 'gh auth login' if not already configured"
    echo "  4. Run 'tailscale up' to connect to your tailnet"
    echo ""
    print_success "Welcome to your newly configured development environment!"
}

# Run main function
main "$@"