# Supabase MCP Server Integration

## Overview

This guide documents the integration of the official Supabase MCP (Model Context Protocol) server with Claude Code, enabling AI assistants to interact with Supabase databases and services through natural language commands.

## Architecture

### Components

1. **Claude Code** - AI coding assistant with MCP support
2. **Supabase MCP Server** - Remote hosted server at `https://mcp.supabase.com/mcp`
3. **Local Configuration** - MCP config file telling Claude how to connect
4. **Supabase Database** - Your actual Supabase project database
5. **Authentication** - Personal Access Token (PAT) for secure access

### Flow Diagram

```
Claude Code → Local MCP Config → Supabase MCP Server → Your Supabase Database
     ↓              ↓                    ↓                      ↓
Natural Language   HTTP Request      Remote Processing      Database Operations
```

## Setup Instructions

### Prerequisites

- Supabase account with an active project
- Supabase Personal Access Token (PAT)
- Claude Code CLI installed
- Project reference from your Supabase URL

### Step 1: Generate Supabase Personal Access Token

1. Navigate to [Supabase Dashboard](https://supabase.com/dashboard/account/tokens)
2. Click "Generate New Token"
3. Give it a descriptive name (e.g., "Claude MCP Server")
4. Copy the generated token

### Step 2: Get Project Reference

Your project reference is the part after `.supabase.co` in your Supabase URL:
- URL: `https://[PROJECT_REF].supabase.co`
- Example: `https://[PROJECT_REF].supabase.co`
- Project Ref: `[PROJECT_REF]`

### Step 3: Configure MCP Server

Create the MCP configuration file at `~/.claude/mcp_config.json`:

```json
{
  "mcpServers": {
    "supabase": {
      "type": "http",
      "url": "https://mcp.supabase.com/mcp?project_ref=YOUR_PROJECT_REF",
      "headers": {
        "Authorization": "Bearer YOUR_SUPABASE_PAT"
      }
    }
  }
}
```

**Replace:**
- `YOUR_PROJECT_REF` with your actual Supabase project reference
- `YOUR_SUPABASE_PAT` with your generated Personal Access Token

### Step 4: Store Credentials Securely

For better security, store your credentials in Doppler:

```bash
# Add to your Doppler project
doppler secrets set SUPABASE_PAT=your_actual_pat_here
doppler secrets set SUPABASE_URL=your_full_supabase_url_here
doppler secrets set SUPABASE_PROJECT_REF=your_project_ref_here
```

Then reference them in your configuration or scripts.

### Step 5: Verify Connection

Test the MCP server connection:

```bash
curl -X POST "https://mcp.supabase.com/mcp?project_ref=YOUR_PROJECT_REF" \
  -H "Authorization: Bearer YOUR_SUPABASE_PAT" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "list_tables",
      "arguments": {}
    }
  }'
```

## Available Operations

### Database Operations

The Supabase MCP server supports various database operations:

#### Schema Management
- `list_tables` - List all tables in the database
- `describe_table` - Get table schema information
- `list_indexes` - List database indexes

#### Data Operations
- `query` - Execute SQL queries
- `insert` - Insert data into tables
- `update` - Update existing records
- `delete` - Delete records

#### Database Management
- `get_table_info` - Detailed table information
- `get_row_count` - Count rows in tables
- `analyze_schema` - Schema analysis

## Example Usage

### Natural Language Queries

Once configured, you can use natural language:

```bash
# Ask Claude to:
"How many tables do we have in the database?"
"Show me the structure of the users table"
"Insert a new record into the app_info table"
"What's the total number of apps in the database?"
```

### Direct MCP Calls

For programmatic access:

```bash
# List tables
curl -X POST "https://mcp.supabase.com/mcp?project_ref=$PROJECT_REF" \
  -H "Authorization: Bearer $SUPABASE_PAT" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"list_tables","arguments":{}}}'
```

## Security Considerations

### Token Security

1. **Never commit PATs to version control**
2. **Use environment variables or secret managers**
3. **Rotate tokens regularly**
4. **Limit token permissions to minimum required**

### Recommended Practices

```bash
# Use Doppler for secure secret management
doppler run -- your-command-here

# Or export as environment variables
export SUPABASE_PAT=$(doppler secrets get SUPABASE_PAT)
export SUPABASE_PROJECT_REF=$(doppler secrets get SUPABASE_PROJECT_REF)
```

### File Permissions

```bash
# Secure your MCP configuration
chmod 600 ~/.claude/mcp_config.json
```

## Troubleshooting

### Common Issues

1. **"Method not allowed"** - Ensure you're using POST requests
2. **"Not Acceptable"** - Include both `application/json` and `text/event-stream` in Accept header
3. **Authentication failures** - Verify your PAT is valid and not expired
4. **Project not found** - Check your project reference is correct

### Debug Commands

```bash
# Check MCP configuration
cat ~/.claude/mcp_config.json

# Test direct connection
curl -I "https://mcp.supabase.com/mcp?project_ref=$PROJECT_REF"

# Verify Doppler secrets
doppler secrets list | grep SUPABASE
```

### Error Messages

| Error | Cause | Solution |
|-------|--------|----------|
| `404 Not Found` | Invalid project reference | Verify project ref from Supabase URL |
| `401 Unauthorized` | Invalid/ expired PAT | Generate new PAT from dashboard |
| `403 Forbidden` | Insufficient permissions | Ensure PAT has required permissions |
| `500 Internal Error` | Server issue | Contact Supabase support |

## Integration with Seed Project

This MCP setup is particularly useful for the seed project's iOS development tools:

### Database Schema

The typical iOS App Store management database includes:
- `apps` - Application metadata
- `app_store_versions` - Version information
- `builds` - Build tracking
- `app_screenshots` - Screenshot management
- `app_info_localizations` - Localization data
- `newsletter_subscriptions` - User subscriptions

### Workflow Examples

```bash
# Check database status
"How many apps are in development?"

# Analyze build statistics
"Show me the latest builds for each app"

# Review localization coverage
"Which locales are missing translations?"

# Monitor subscriptions
"How many newsletter subscriptions do we have?"
```

## Best Practices

### Performance

1. **Use specific queries** rather than broad table scans
2. **Limit result sets** for large tables
3. **Cache frequently accessed data**
4. **Monitor query performance**

### Development Workflow

1. **Test queries in Supabase Dashboard first**
2. **Use natural language for exploratory analysis**
3. **Create scripts for repetitive operations**
4. **Document custom workflows**

### Backup and Recovery

1. **Regular Supabase backups** (automatic)
2. **Export critical data** periodically
3. **Version control database schemas**
4. **Test recovery procedures**

## Related Documentation

- [Supabase MCP Official Docs](https://supabase.com/docs/guides/getting-started/mcp)
- [Claude Code MCP Integration](https://docs.claude.com/en/docs/claude-code/mcp)
- [Doppler Secret Management](https://docs.doppler.com)
- [Seed Project Documentation](./README.md)

## Updates and Changelog

### v1.0.0 - Initial Setup
- Configured official Supabase MCP server
- Integrated with Doppler secrets
- Created comprehensive documentation
- Tested with iOS development database

---

**Note:** This documentation is maintained as part of the seed project. Update it whenever MCP configurations or workflows change.