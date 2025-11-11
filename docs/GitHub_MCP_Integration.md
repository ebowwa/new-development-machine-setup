# GitHub MCP Server Integration

## Overview

GitHub provides Model Context Protocol (MCP) servers that enable AI assistants to interact with GitHub repositories and APIs through natural language commands. This documentation covers both official and community GitHub MCP implementations.

## GitHub MCP vs CLI: When to Use Each

### MCP Server Benefits

**Use GitHub MCP when:**
- ✅ You need conversational repository exploration
- ✅ Want to search across multiple repositories
- ✅ Need semantic code understanding
- ✅ Want to automate GitHub workflows through conversation
- ✅ Prefer integrated AI assistant experience

**Key Advantages:**
- **Integrated Experience** - Works directly within Claude conversation
- **Real-time Queries** - Live repository data without switching contexts
- **Semantic Search** - Better code understanding than raw CLI
- **Workflow Automation** - Can create/manage issues, PRs conversationally
- **Cross-repository Operations** - Easy access to multiple repos

### CLI Benefits (Like We Used for This Push)

**Use GitHub CLI when:**
- ✅ You're working within a specific repository
- ✅ Want maximum control over operations
- ✅ Already have GitHub CLI configured
- ✅ Need precise, command-level control
- ✅ Want transparency in executed commands

**Key Advantages:**
- **Transparency** - You see exactly what commands are executed
- **Existing Auth** - Uses your already-configured GitHub CLI
- **Debuggability** - Easy to troubleshoot
- **Familiar Tools** - Uses git, gh commands you already know

## Available GitHub MCP Servers

### Official GitHub MCP Server

**Features:**
- 🔍 Repository Intelligence: Search code, stream repository data
- 🤖 Advanced Automation: Interact with GitHub APIs
- ☁️ Always Available: No installation required (hosted by GitHub)
- 📊 Real-time Data: Access to live repository information

### Community Implementations

1. **modelcontextprotocol/servers** - Official reference implementations
2. **rohithdasm/github-mcp** - Popular community implementation
3. **github/mcp** - GitHub's MCP registry
4. **Various third-party implementations** with different specializations

## Setup Instructions

### Prerequisites

- GitHub Personal Access Token (PAT) with appropriate scopes
- Claude Code with MCP support
- Node.js (for npm-based servers)

### Step 1: Generate GitHub Personal Access Token

1. Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Configure scopes based on your needs:
   - **Basic operations:** `repo`, `read:org`
   - **Advanced features:** `issues`, `pull requests`, `workflows`
   - **Organization access:** `admin:org`, `read:org`

### Step 2: Configure MCP Server

#### Option A: Official GitHub MCP Server (Recommended)

Create or update `~/.claude/mcp_config.json`:

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://mcp.github.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_GITHUB_PAT"
      }
    }
  }
}
```

#### Option B: Community Implementation

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["@github/github-mcp-server"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_PAT"
      }
    }
  }
}
```

### Step 3: Secure Your Credentials

**Using Doppler (Recommended):**

```bash
# Add to your Doppler project
doppler secrets set GITHUB_PAT=your_github_pat_here
doppler secrets set GITHUB_USERNAME=your_username

# Use with Doppler
doppler run --project your-project --config dev -- claude
```

**Environment Variables:**

```bash
# Add to your shell profile
export GITHUB_PAT="your_pat_here"
export GITHUB_USERNAME="your_username"
```

## Available Operations

### Repository Operations

**Data Access:**
- **Search code** across repositories
- **Read repository contents** and metadata
- **Access issues**, pull requests, discussions
- **Browse file structures**
- **Get commit history** and diffs

**Example Queries:**
```bash
# Natural language examples
"Find all TypeScript files in the seed repository"
"Show me recent commits to the main branch"
"List open issues in the ebowwa organization"
"What repositories in my org use Docker?"
"Find all TODO comments in this repository"
```

### Workflow Integration

**Automation:**
- **Create and manage issues/PRs**
- **Automate repository tasks**
- **Integrate with GitHub Actions**
- **Access repository analytics**

**Example Commands:**
```bash
# Workflow automation examples
"Create an issue for each TODO comment found"
"Generate a pull request for these changes"
"Close all issues labeled 'duplicate'"
"Create a project board for the v2.0 release"
"Set up GitHub Actions for automated testing"
```

### Cross-Repository Operations

**Organization Management:**
- **Search across multiple repositories**
- **Analyze organization-level metrics**
- **Manage team access and permissions**
- **Monitor repository health**

**Example Queries:**
```bash
# Cross-repository examples
"Find all repositories using TypeScript in my organization"
"Which repos have outdated dependencies?"
"Show me the most active repositories this month"
"Find all repos with failing GitHub Actions"
"Analyze code quality across the organization"
```

## Configuration Examples

### Complete MCP Configuration

**With Multiple MCP Servers:**

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://mcp.github.com/mcp",
      "headers": {
        "Authorization": "Bearer ${GITHUB_PAT}"
      }
    },
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=${SUPABASE_PROJECT_REF}",
      "headers": {
        "Authorization": "Bearer ${SUPABASE_PAT}"
      }
    },
    "stripe": {
      "command": "npx",
      "args": ["-y", "@stripe/mcp"],
      "env": {
        "STRIPE_SECRET_KEY": "${STRIPE_API_KEY}"
      }
    }
  }
}
```

### Environment-Specific Configuration

**Development Environment:**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["@github/github-mcp-server", "--debug"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_DEV_PAT}",
        "NODE_ENV": "development"
      }
    }
  }
}
```

**Production Environment:**

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://mcp.github.com/mcp",
      "headers": {
        "Authorization": "Bearer ${GITHUB_PROD_PAT}"
      }
    }
  }
}
```

## Security Best Practices

### Token Management

1. **Principle of Least Privilege**
   ```bash
   # Read-only token for basic operations
   # Full token only when necessary for write operations
   ```

2. **Token Rotation**
   ```bash
   # Set expiry dates on PATs
   # Use short-lived tokens for automated processes
   # Regular audit of active tokens
   ```

3. **Secure Storage**
   ```bash
   # Use Doppler or equivalent secret manager
   # Never commit tokens to version control
   # Use environment-specific tokens
   ```

### Permissions Scoping

**Read-Only Operations:**
- `repo` (read access)
- `read:org`
- `read:user`

**Write Operations:**
- `repo` (full access)
- `admin:org`
- `write:discussion`
- `workflow` (for Actions)

### Access Control

**Repository-Level:**
```bash
# Use repository-specific tokens when possible
# Limit scope to specific repositories
# Use deploy keys for CI/CD operations
```

**Organization-Level:**
```bash
# Create service accounts for automation
# Use team-based access control
# Implement approval workflows
```

## Troubleshooting

### Common Issues

**Authentication Problems:**
```bash
# Verify token is valid
curl -H "Authorization: token YOUR_PAT" https://api.github.com/user

# Check token scopes
curl -H "Authorization: token YOUR_PAT" https://api.github.com/rate_limit
```

**MCP Server Connection:**
```bash
# Test MCP server availability
curl -I https://mcp.github.com/mcp

# Verify Claude Code configuration
cat ~/.claude/mcp_config.json
```

**Rate Limiting:**
```bash
# Check current rate limits
gh api /rate_limit

# Use authenticated requests for higher limits
# Implement exponential backoff for retries
```

### Debug Commands

```bash
# Test GitHub API access
gh api user

# Verify MCP configuration
claude --help | grep -i mcp

# Check environment variables
env | grep -E "(GITHUB|MCP)"
```

## Integration with Seed Project

### Existing GitHub CLI Setup

The seed project already includes GitHub CLI setup:

```bash
# Already configured in setup.sh
gh auth login
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Adding GitHub MCP to Seed

**Update `.env.example`:**

```bash
# GitHub MCP Server Configuration
GITHUB_PAT=
GITHUB_USERNAME=
GITHUB_ORG=
```

**Extend `setup.sh`:**

```bash
# Add GitHub MCP server setup
if [ "$SKIP_GITHUB_MCP" != "true" ]; then
    echo "Setting up GitHub MCP server..."
    # Add MCP configuration logic here
fi
```

### Workflow Examples

**Repository Management:**
```bash
# Create new repository with structure
"Create a new repository called 'my-project' with TypeScript setup"

# Initialize with standard structure
"Set up this repository with README, LICENSE, and .gitignore"

# Configure team access
"Add the dev team to this repository with write access"
```

**Code Analysis:**
```bash
# Security scanning
"Find all repositories with exposed API keys"

# Dependency management
"Show me repositories with outdated dependencies"

# Code quality
"Analyze code quality across TypeScript repositories"
```

## Performance Considerations

### Optimization Tips

1. **Limit Repository Scope**
   ```bash
   # Specify repositories when possible
   "Search in ebowwa/seed only"
   # Rather than across entire organization
   ```

2. **Use Specific Queries**
   ```bash
   # Be specific in your requests
   "Find TypeScript files with TODO comments"
   # Instead of broad searches
   ```

3. **Cache Results**
   ```bash
   # Store frequently accessed data
   # Use local caching for large repositories
   ```

### Rate Limit Management

**GitHub API Limits:**
- **Authenticated requests:** 5,000 requests/hour
- **Unauthenticated requests:** 60 requests/hour
- **GraphQL:** 5,000 points/hour

**Best Practices:**
- Use authentication for higher limits
- Implement caching strategies
- Batch operations when possible
- Use GraphQL for complex queries

## Related Documentation

- [GitHub MCP Official Documentation](https://docs.github.com/en/mcp)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [Claude Code MCP Integration](https://claude.ai/mcp)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Seed Project README](../README.md)

## Changelog

### v1.0.0 - Initial Documentation
- Complete GitHub MCP server integration guide
- Comparison with GitHub CLI workflow
- Security best practices and troubleshooting
- Integration examples with seed project

---

**Note:** This documentation complements the existing GitHub CLI setup in the seed project. Use MCP for conversational GitHub operations and CLI for precise, command-level control.