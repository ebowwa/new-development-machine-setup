# Claude Code + GLM-4.5 + Doppler Integration

This project is now fully configured to work with Claude Code using GLM-4.5 via Z.ai, with all secrets managed through Doppler.

## 🚀 Quick Start

```bash
# Navigate to the project
cd /Users/ebowwa/node-starter

# Load environment from Doppler
eval $(doppler secrets download --config dev --format env --no-file)

# Run Claude Code with Z.ai backend
claude
```

## 🔧 Configuration Details

### Doppler Setup
- **Project**: `node-starter`
- **Environment**: `dev` (Development)
- **Workplace**: `ebowwa-labs`

### AI Assistant Configuration
- **Assistant**: `zai` (Claude Code with Z.ai backend)
- **Base URL**: `https://api.z.ai/api/anthropic`
- **Primary Model**: `glm-4.5`
- **Fast Model**: `glm-4.5-air`
- **API Key**: Securely stored in Doppler

### Environment Variables
All sensitive configuration is stored in Doppler:

```bash
# AI Configuration
AI_ASSISTANT=zai
ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic
ANTHROPIC_AUTH_TOKEN=069739ffb9874d53986f4706acd1ddeb.oARvXer4w2nJZaE4
ANTHROPIC_MODEL=glm-4.5
ANTHROPIC_SMALL_FAST_MODEL=glm-4.5-air

# Development Tools
GITHUB_TOKEN=github_token_here
GCLOUD_ACCOUNT=ec.arbee1@gmail.com
GCLOUD_PROJECT_ID=ebowwa
HETZNER_API_TOKEN=hetzner_token_here
```

## 📋 Usage Examples

### Development Work
```bash
# Load environment and start coding
cd node-starter
eval $(doppler secrets download --config dev --format env --no-file)
claude

# Or use the run wrapper
doppler run --config dev -- claude
```

### Scripts and Automation
```bash
# Use in scripts with doppler run
doppler run --config dev -- ./your-script.sh

# Load environment for other tools
eval $(doppler secrets download --config dev --format env --no-file)
npm run dev
```

### Multiple Environments
```bash
# Switch to staging
doppler secrets download --config stg --format env --no-file > staging.env
source staging.env

# Production
doppler secrets download --config prd --format env --no-file > production.env
source production.env
```

## 🔒 Security Benefits

1. **No Local Secrets**: All sensitive data is stored in Doppler
2. **Environment Isolation**: Separate configs for dev, staging, and production
3. **Access Control**: Doppler provides fine-grained access controls
4. **Audit Trail**: All secret access is logged
5. **Rotation Support**: Easy credential rotation without code changes

## 🛠️ Setup for New Developers

1. **Install Doppler CLI** (already included in setup.sh)
2. **Authenticate with Doppler**:
   ```bash
   doppler login
   ```
3. **Configure project**:
   ```bash
   cd node-starter
   doppler configure set project node-starter --scope .
   ```
4. **Work with the project**:
   ```bash
   doppler run --config dev -- claude
   ```

## 🔄 Working with Other Projects

This setup can be replicated for other projects:

1. Create a Doppler project
2. Configure environments (dev, stg, prd)
3. Add the necessary secrets
4. Use `doppler run` to load environment variables

## 📝 Notes

- The local `.env` file contains only non-sensitive configuration
- All actual secrets are fetched from Doppler at runtime
- The `~/.claude/settings.json` file is configured to use Z.ai by default
- This setup works seamlessly across local development, Codespaces, and VPS environments