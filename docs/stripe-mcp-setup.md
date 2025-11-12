# Stripe MCP Server Setup Documentation

## Overview
Successfully configured the Stripe Model Context Protocol (MCP) server for use with Claude Code, integrated with Doppler for secure secret management.

## Setup Summary

### ✅ **Final Configuration**
- **Server Name**: `stripe`
- **Transport**: `stdio`
- **Command**: `npx -y @stripe/mcp --tools=all`
- **Environment Variable**: `STRIPE_SECRET_KEY`
- **Authentication**: Successfully connected to Stripe API
- **Status**: ✓ Connected

### 🔐 **Authentication Setup**
- **Doppler Project**: `ios-development-tools`
- **Doppler Config**: `prd`
- **Secret Name**: `STRIPE_SECRET_KEY`
- **Key Type**: Test mode key (`sk_test_`)

## Installation Process

### 1. Initial Setup (Failed Approach)
```bash
# First attempt - used wrong project and key type
claude mcp add --transport http stripe https://mcp.stripe.com/
# Result: Connected but needed authentication
```

### 2. Working Configuration (Success)
```bash
# Removed HTTP version and used stdio with Doppler integration
claude mcp remove stripe -s local

# Added with correct Stripe secret key from Doppler
claude mcp add --transport stdio stripe \
  --env STRIPE_SECRET_KEY="$(doppler secrets get STRIPE_SECRET_KEY --project ios-development-tools --config prd)" \
  -- npx -y @stripe/mcp --tools=all
```

## Key Learnings

### 🔑 **API Key Types**
- `STRIPE_MCP_KEY` = Ephemeral key (`ek_test_`) → **Failed** - Not valid for MCP server
- `STRIPE_SECRET_KEY` = Secret key (`sk_test_`) → **Success** - Works with MCP server

### 🏗️ **Transport Methods**
- **HTTP Transport** (`https://mcp.stripe.com/`): Requires OAuth setup
- **STDIO Transport** (`npx -y @stripe/mcp`): Works with API keys

### 📦 **Doppler Integration**
- Used `ios-development-tools` project instead of `seed` project
- Leveraged existing `STRIPE_SECRET_KEY` from production config
- Followed same pattern as `zai-mcp-server` configuration

## Current Status

### 🏦 **Stripe Account Information**
- **Account ID**: `acct_1SQOtSPWTrUUyeC1`
- **Email**: `ec.arbee1@gmail.com`
- **Country**: US
- **Default Currency**: USD
- **Account Type**: Standard
- **Display Name**: submitops.com

### ⚠️ **Account Setup Status**
- **Charges Enabled**: `false` (account setup incomplete)
- **Payouts Enabled**: `false` (account setup incomplete)
- **Details Submitted**: `false`

### 🛠️ **Available MCP Tools**
With `--tools=all` configured, the server provides access to:
- Account management
- Balance retrieval
- Customer management (create, read, update, delete)
- Payment processing and payment links
- Subscription management
- Product and price management
- Coupon creation and management
- Invoice operations
- Refund processing
- Dispute handling
- Resource search functionality

## Usage Examples

### Commands for Management
```bash
# Check MCP server status
claude mcp list

# Get detailed configuration
claude mcp get stripe

# Remove server (if needed)
claude mcp remove stripe -s local

# Test API connection manually
doppler run --project ios-development-tools --config prd \
  -- curl -s "https://api.stripe.com/v1/account" \
  -H "Authorization: Bearer $STRIPE_SECRET_KEY"
```

### Environment Variables
```bash
# For manual testing
STRIPE_SECRET_KEY=$(doppler secrets get STRIPE_SECRET_KEY --project ios-development-tools --config prd)

# Verify environment
doppler run --project ios-development-tools --config prd -- env | grep STRIPE
```

## Security Considerations

### ✅ **Best Practices Applied**
- Used restricted test keys (not live keys)
- Integrated with Doppler for secure secret management
- Followed least privilege principle
- Used stdio transport for better security isolation

### 🔐 **Recommendations**
- Enable human tool confirmation for production use
- Monitor API key usage and rotate regularly
- Keep test and live keys in separate Doppler configs
- Use webhook signatures for any webhook implementations

## Troubleshooting

### Common Issues and Solutions

1. **"Invalid API Key" Error**
   - Cause: Using ephemeral key (`ek_test_`) instead of secret key (`sk_test_`)
   - Solution: Use `STRIPE_SECRET_KEY` not `STRIPE_MCP_KEY`

2. **"API Key not provided" Error**
   - Cause: Wrong environment variable name
   - Solution: Use `STRIPE_SECRET_KEY` not `STRIPE_API_KEY`

3. **"Failed to connect" Error**
   - Cause: Wrong transport method or authentication
   - Solution: Use stdio transport with proper API key

4. **Doppler Integration Issues**
   - Cause: Wrong project or config specified
   - Solution: Verify project name and config exist with `doppler projects` and `doppler configs`

## Next Steps

### 🚀 **To Enable Full Functionality**
1. Complete Stripe account setup in dashboard
2. Enable charges and payouts
3. Configure webhooks if needed
4. Set up proper API key restrictions

### 🔧 **For Production Use**
1. Create restricted API keys with minimal permissions
2. Set up monitoring and alerts
3. Implement proper error handling
4. Configure webhook endpoints

## Related Files
- `/root/seed/stripe-mcp-overview.md` - General MCP overview
- `/root/.claude.json` - Local MCP configuration
- Doppler Project: `ios-development-tools` (Config: `prd`)

---
*Setup completed successfully on: $(date)*
*Status: ✅ Working and ready for use*