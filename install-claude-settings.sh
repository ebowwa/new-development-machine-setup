#!/bin/bash

# Claude Settings Installation Script for node-starter
# This script installs Claude Code settings optimized for Z.ai integration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_TEMPLATE="${SCRIPT_DIR}/.claude/settings.template.json"
SETTINGS_LOCAL="${SCRIPT_DIR}/.claude/settings.local.json"
CLAUDE_SETTINGS_DIR="$HOME/.claude"
CLAUDE_SETTINGS_FILE="$CLAUDE_SETTINGS_DIR/settings.json"

echo "🔧 Installing Claude Code settings for Z.ai integration..."

# Check if we're in the right directory
if [ ! -f "$SETTINGS_TEMPLATE" ]; then
    echo "❌ Error: Claude settings template not found. Please run this from the node-starter directory."
    exit 1
fi

# Create Claude settings directory if it doesn't exist
mkdir -p "$CLAUDE_SETTINGS_DIR"

# Backup existing settings if they exist
if [ -f "$CLAUDE_SETTINGS_FILE" ]; then
    echo "💾 Backing up existing Claude settings..."
    cp "$CLAUDE_SETTINGS_FILE" "$CLAUDE_SETTINGS_DIR/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Copy the template settings to Claude's config directory
echo "📋 Installing Claude settings template..."
cp "$SETTINGS_TEMPLATE" "$CLAUDE_SETTINGS_FILE"

# Also create local settings for project-specific overrides
if [ -f "$SETTINGS_LOCAL" ]; then
    echo "📋 Local settings file already exists"
else
    echo "📋 Creating local settings file..."
    cp "$SETTINGS_TEMPLATE" "$SETTINGS_LOCAL"
fi

# Set proper permissions
chmod 600 "$CLAUDE_SETTINGS_FILE" 2>/dev/null || true
chmod 600 "$SETTINGS_LOCAL" 2>/dev/null || true

echo "✅ Claude Code settings installed successfully!"
echo ""
echo "🎯 Settings configured for:"
echo "   • Base URL: https://api.z.ai/api/anthropic"
echo "   • Primary Model: glm-4.5"
echo "   • Fast Model: glm-4.5-air"
echo "   • UV integration for Python"
echo ""
echo "💡 To use with Doppler environment:"
echo "   doppler run --project node-starter --config dev -- claude"
echo ""
echo "📝 Settings files:"
echo "   • Global: $CLAUDE_SETTINGS_FILE"
echo "   • Template: $SETTINGS_TEMPLATE"
echo "   • Local: $SETTINGS_LOCAL"