# Stripe MCP Server Overview

The **Stripe Model Context Protocol (MCP) server** provides AI agents with tools to interact with the Stripe API and search Stripe's knowledge base. It enables programmatic access to Stripe's payment processing, customer management, and financial services.

## Key Features

**Available Tools:**
- Account management
- Balance retrieval
- Customer management (create, read, update)
- Payment processing and links
- Subscription management
- Product and price management
- Coupon creation
- Invoice operations
- Refund processing
- Dispute handling
- Resource search functionality

## Installation Options

**For Claude Code:**
```bash
claude mcp add --transport http stripe https://mcp.stripe.com/
```

**Local Development:**
```bash
npx -y @stripe/mcp --tools=all --api-key=YOUR_STRIPE_SECRET_KEY
```

**Python SDK:**
```bash
pip install stripe-agent-toolkit
```

**TypeScript SDK:**
```bash
npm install @stripe/agent-toolkit
```

## Authentication Methods

1. **OAuth** (recommended) - Detailed permissions with user-based authorization
2. **API Key** - Restricted API keys as Bearer tokens
3. **Local Setup** - Direct API key usage for development

## Security Considerations

- Enable human tool confirmation when possible
- Exercise caution when using with other MCP servers to prevent prompt injection attacks
- Use restricted API keys with minimal required permissions

The Stripe MCP server is particularly useful for building AI-powered financial applications, automated payment systems, and customer service bots that need to interact with Stripe's payment infrastructure.

## Additional Resources

- Official Documentation: https://docs.stripe.com/mcp
- GitHub Repository: https://github.com/stripe/ai
- Contact: mcp@stripe.com