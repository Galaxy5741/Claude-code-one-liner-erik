# Claude Code One-Liner Setup

One-liner installation script for Claude Code with custom system prompt, MCP memory server, and specialized agents.

## Quick Install

### Universal (Linux/macOS)
```bash
curl -sL https://raw.githubusercontent.com/Galaxy5741/Claude-code-one-liner-erik/main/install.sh | bash
```

### Debian/Ubuntu One-Liner
```bash
curl -sL https://raw.githubusercontent.com/Galaxy5741/Claude-code-one-liner-erik/main/install.sh | bash
```

The script automatically detects your OS and uses `apt-get` on Debian/Ubuntu systems.

## What Gets Installed

This script automatically installs and configures:

1. **npm** - Node Package Manager (if not already installed)
2. **Claude Code** - Anthropic's official CLI via npm
3. **System Prompt** - Custom "Sudo" British Intelligence operative personality in `~/.claude/CLAUDE.md`
4. **Memory MCP Server** - Persistent memory storage via MCP protocol
5. **Specialized Agents** (Sonnet 4.5):
   - `senior-code-reviewer` - Comprehensive code review agent
   - `ui-engineer` - Expert UI/frontend development agent

## System Requirements

- **Linux**: Debian/Ubuntu (apt-get), RHEL/CentOS (yum), or Arch (pacman)
- **macOS**: Requires Homebrew
- Internet connection
- sudo access (for npm installation if needed)

## Manual Installation

If you prefer to inspect the script before running:

```bash
# Download the script
curl -sL https://raw.githubusercontent.com/Galaxy5741/Claude-code-one-liner-erik/main/install.sh -o install.sh

# Review it
cat install.sh

# Make it executable and run
chmod +x install.sh
./install.sh
```

## What's Configured

### System Prompt Location
- `~/.claude/CLAUDE.md` - Custom "Sudo" personality with British wit and brutal honesty

### MCP Server
- `~/.claude/mcp-servers/memory/` - Memory server that connects to `http://192.168.1.166:3012`
- Auto-configured in `~/.claude/config.json`

### Agents
- `~/.claude/agents/senior-code-reviewer.md` - Senior fullstack code reviewer
- `~/.claude/agents/ui-engineer.md` - Expert UI/frontend engineer

## Post-Installation

Start Claude Code:
```bash
claude-code
```

## Files in This Repository

- `install.sh` - Main installation script
- `claude-code-system-prompt.md` - "Sudo" system prompt
- `mcp-client-memory.js` - Memory MCP server client
- `senior-code-reviewer.md` - Code review agent configuration
- `ui-engineer.md` - UI engineering agent configuration

## Uninstall

To remove Claude Code and related configurations:

```bash
npm uninstall -g @anthropic-ai/claude-code
rm -rf ~/.claude
```

## Support

For issues with Claude Code itself, visit: https://github.com/anthropics/claude-code/issues
