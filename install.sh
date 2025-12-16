#!/bin/bash
set -e

REPO_URL="https://raw.githubusercontent.com/Galaxy5741/Claude-code-one-liner-erik/main"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
MCP_DIR="$CLAUDE_DIR/mcp-servers"

echo "🚀 Installing Claude Code Setup..."

# Install npm if not present
if ! command -v npm &> /dev/null; then
    echo "📦 Installing npm..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y nodejs npm
        elif command -v yum &> /dev/null; then
            sudo yum install -y nodejs npm
        elif command -v pacman &> /dev/null; then
            sudo pacman -S nodejs npm
        else
            echo "❌ Unsupported package manager. Please install npm manually."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install node
        else
            echo "❌ Please install Homebrew first or install npm manually."
            exit 1
        fi
    else
        echo "❌ Unsupported OS. Please install npm manually."
        exit 1
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

if [ -f "$CONFIG_FILE" ]; then
    # Backup existing config
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    # Merge MCP server config
    cat "$CONFIG_FILE" | jq '.mcpServers.memory = {
        "command": "node",
        "args": ["'$MCP_DIR'/memory/mcp-client-memory.js"]
    }' > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
else
    # Create new config
    cat > "$CONFIG_FILE" << 'EOF'
{
  "mcpServers": {
    "memory": {
      "command": "node",
      "args": ["$MCP_DIR/memory/mcp-client-memory.js"]
    }
  }
}
EOF
    # Replace $MCP_DIR with actual path
    sed -i.bak "s|\$MCP_DIR|$MCP_DIR|g" "$CONFIG_FILE" && rm "$CONFIG_FILE.bak"
fi

echo "✅ Installation complete!"
echo ""
echo "📋 Installed components:"
echo "  ✓ Claude Code ($(claude-code --version 2>/dev/null || echo 'installed'))"
echo "  ✓ System Prompt: $CLAUDE_DIR/CLAUDE.md"
echo "  ✓ Memory MCP Server: $MCP_DIR/memory/"
echo "  ✓ Agents:"
echo "    - senior-code-reviewer (Sonnet 4.5)"
echo "    - ui-engineer (Sonnet 4.5)"
echo ""
echo "🎉 Ready to use! Run 'claude-code' to start."
