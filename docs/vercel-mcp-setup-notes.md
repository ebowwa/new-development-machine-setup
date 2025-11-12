# Vercel MCP Server Setup Notes

## Overview
Set up the official Vercel MCP server for accessing Vercel projects and domains through Claude Code.

## What was Accomplished
1. ✅ Removed OAuth mentions from documentation pages
2. ✅ Set up official Vercel MCP server (mcp.vercel.com)
3. ✅ Listed all Vercel domains using CLI integration

## Current Vercel Domains
As of November 12, 2025:

| Domain | Age | Project | Nameservers |
|--------|-----|---------|-------------|
| submitops.com | 5 days | v0-submitops | Third Party |
| diytoybricks.com | 19 hours | v0-v0-blocks | Vercel |
| openhardwareai.com | 42 days | - | Third Party |
| printpeer.xyz | 147 days | - | Third Party |
| caringmind.xyz | 368 days | - | Third Party |
| ebowwa.xyz | 479 days | - | Vercel |
| un-automated.com | 507 days | - | Third Party |
| whispaw.com | 533 days | - | Vercel |

## MCP Server Configuration
- **Server URL**: https://mcp.vercel.com
- **Transport**: SSE (Server-Sent Events)
- **Authentication**: OAuth (first-time setup required)
- **Status**: ⚠ Needs authentication

## Setup Commands Used
```bash
# Add official Vercel MCP server
claude mcp add --transport sse vercel https://mcp.vercel.com

# Check MCP server status
claude mcp list

# List domains via CLI (fallback method)
vercel domains ls
```

## Available Tools (when authenticated)
- vercel_list_projects - List all Vercel projects
- vercel_get_project_domain - Get domain information for projects
- vercel_list_deployments - List deployments
- vercel_create_deployment - Create new deployments
- Environment variable management
- Team management tools

## Authentication Required
The MCP server shows "Needs authentication" status. When you first try to use any Vercel MCP tools, it will prompt you to authenticate with Vercel (OAuth flow), after which all tools will be accessible.

## Alternative: CLI Integration
The Vercel CLI is already authenticated and can be used as a fallback:
```bash
vercel projects list
vercel domains ls
```

## Doppler Secrets Consideration
While we tried to set up API token authentication, the official Vercel MCP server only supports OAuth authentication. For API token-based access, consider using alternative MCP servers or CLI integration.

## Next Steps
1. Try using any Vercel MCP tool to trigger OAuth authentication
2. Once authenticated, the MCP server will provide full API access
3. Consider migrating more projects to use Vercel nameservers for better integration

---
*Created: November 12, 2025*
*Last Updated: November 12, 2025*