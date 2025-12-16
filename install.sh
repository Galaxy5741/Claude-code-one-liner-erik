#!/bin/bash
set -e

REPO_URL="https://raw.githubusercontent.com/Galaxy5741/Claude-code-one-liner-erik/main"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
MCP_DIR="$CLAUDE_DIR/mcp-servers"
NVM_DIR="$HOME/.nvm"

echo "🚀 Installing Claude Code Setup..."

# Check Node.js version
NODE_VERSION_OK=false
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        NODE_VERSION_OK=true
        echo "✓ Node.js $(node -v) detected"
    else
        echo "⚠️  Node.js $(node -v) is too old (need >=18.0.0)"
    fi
fi

# Install/setup nvm and Node.js if needed
if [ "$NODE_VERSION_OK" = false ]; then
    echo "📦 Setting up Node.js via nvm..."

    # Install nvm if not present
    if [ ! -d "$NVM_DIR" ]; then
        echo "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi

    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install Node.js 18 LTS
    echo "Installing Node.js 18 LTS..."
    nvm install 18
    nvm use 18
    nvm alias default 18

    echo "✓ Node.js $(node -v) installed"
else
    # Load nvm if it exists (for consistency)
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
fi

# Install Claude Code
echo "🤖 Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

# Create directories
echo "📁 Creating directories..."
mkdir -p "$CLAUDE_DIR" "$AGENTS_DIR" "$MCP_DIR/memory"

# Download and install system prompt
echo "📝 Installing system prompt..."
curl -sL "$REPO_URL/claude-code-system-prompt.md" -o "$CLAUDE_DIR/CLAUDE.md"

# Download and install MCP memory server
echo "🧠 Installing Memory MCP server..."
curl -sL "$REPO_URL/mcp-client-memory.js" -o "$MCP_DIR/memory/mcp-client-memory.js"
chmod +x "$MCP_DIR/memory/mcp-client-memory.js"

# Install axios for MCP server
cd "$MCP_DIR/memory"
npm init -y &> /dev/null
npm install axios &> /dev/null
cd - > /dev/null

# Download and install agents
echo "🔧 Installing agents..."
curl -sL "$REPO_URL/senior-code-reviewer.md" -o "$AGENTS_DIR/senior-code-reviewer.md"
curl -sL "$REPO_URL/ui-engineer.md" -o "$AGENTS_DIR/ui-engineer.md"

# Configure MCP server in Claude Code config
echo "⚙️  Configuring MCP server..."
CONFIG_FILE="$CLAUDE_DIR/config.json"

# Backup existing config if it exists
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%s)"
    echo "  (Backed up existing config)"
fi

# Create/overwrite config with MCP server using Python for JSON handling
python3 << PYTHON_SCRIPT
import json
import os

config_file = "$CONFIG_FILE"
mcp_dir = "$MCP_DIR"

# Read existing config or start with empty dict
config = {}
if os.path.exists(config_file):
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
    except:
        config = {}

# Ensure mcpServers key exists
if 'mcpServers' not in config:
    config['mcpServers'] = {}

# Add memory server
config['mcpServers']['memory'] = {
    "command": "node",
    "args": [f"{mcp_dir}/memory/mcp-client-memory.js"]
}

# Write config
with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print(f"✓ MCP server configured in {config_file}")
PYTHON_SCRIPT

echo "✅ Installation complete!"
echo ""
echo "📋 Installed components:"
echo "  ✓ Node.js $(node -v) via nvm"
echo "  ✓ Claude Code ($(claude-code --version 2>/dev/null || echo 'installed'))"
echo "  ✓ System Prompt: $CLAUDE_DIR/CLAUDE.md"
echo "  ✓ Memory MCP Server: $MCP_DIR/memory/"
echo "  ✓ Agents:"
echo "    - senior-code-reviewer (Sonnet 4.5)"
echo "    - ui-engineer (Sonnet 4.5)"
echo ""
if [ -d "$NVM_DIR" ]; then
    echo "⚠️  IMPORTANT: For new terminal sessions, nvm is now available."
    echo "   To use Node.js in new shells, restart your terminal or run:"
    echo "   source ~/.bashrc (or ~/.zshrc)"
    echo ""
fi
echo "🎉 Ready to use! Run 'claude-code' to start."
