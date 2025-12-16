#!/usr/bin/env node

const axios = require('axios');

const MEMORY_SERVER_URL = 'http://192.168.1.166:3012';

class MCPMemoryBridge {
  constructor() {
    this.requestId = 1;
    this.initialized = false;
    this.capabilities = {
      tools: {},
      resources: {}
    };
  }

  handleInitialize(request) {
    this.initialized = true;
    return {
      jsonrpc: "2.0",
      id: request.id,
      result: {
        protocolVersion: "2025-06-18",
        capabilities: this.capabilities,
        serverInfo: {
          name: "mcp-memory-bridge",
          version: "1.0.0"
        }
      }
    };
  }

  handleListTools(request) {
    const tools = [
      {
        name: "store_memory",
        description: "Store a new memory entry",
        inputSchema: {
          type: "object",
          properties: {
            content: { type: "string", description: "Memory content to store" },
            tags: { type: "array", items: { type: "string" }, description: "Tags for categorization" }
          },
          required: ["content"]
        }
      },
      {
        name: "get_memories",
        description: "Retrieve all memory entries",
        inputSchema: {
          type: "object",
          properties: {},
          required: []
        }
      },
      {
        name: "get_memory",
        description: "Retrieve a specific memory entry by ID",
        inputSchema: {
          type: "object",
          properties: {
            id: { type: "string", description: "Memory ID to retrieve" }
          },
          required: ["id"]
        }
      },
      {
        name: "delete_memory",
        description: "Delete a memory entry by ID",
        inputSchema: {
          type: "object",
          properties: {
            id: { type: "string", description: "Memory ID to delete" }
          },
          required: ["id"]
        }
      }
    ];

    return {
      jsonrpc: "2.0",
      id: request.id,
      result: {
        tools: tools
      }
    };
  }

  async handleCallTool(request) {
    try {
      const { name, arguments: args } = request.params;
      let endpoint;
      let httpMethod = 'GET';
      let data = {};

      switch (name) {
        case 'store_memory':
          endpoint = '/memories';
          httpMethod = 'POST';
          data = args;
          break;
        case 'get_memories':
          endpoint = '/memories';
          httpMethod = 'GET';
          break;
        case 'get_memory':
          endpoint = `/memories/${args.id}`;
          httpMethod = 'GET';
          break;
        case 'delete_memory':
          endpoint = `/memories/${args.id}`;
          httpMethod = 'DELETE';
          break;
        default:
          throw new Error(`Unknown tool: ${name}`);
      }

      const response = await axios({
        method: httpMethod,
        url: MEMORY_SERVER_URL + endpoint,
        data: httpMethod === 'POST' ? data : undefined,
        timeout: 10000
      });

      return {
        jsonrpc: "2.0",
        id: request.id,
        result: {
          content: [
            {
              type: "text",
              text: JSON.stringify(response.data, null, 2)
            }
          ]
        }
      };

    } catch (error) {
      return {
        jsonrpc: "2.0",
        id: request.id,
        error: {
          code: -32603,
          message: `Memory service error: ${error.message}`,
          data: error.response?.data || null
        }
      };
    }
  }

  async processRequest(request) {
    if (!request.jsonrpc || request.jsonrpc !== "2.0") {
      return {
        jsonrpc: "2.0",
        id: request.id || null,
        error: {
          code: -32600,
          message: "Invalid Request"
        }
      };
    }

    switch (request.method) {
      case 'initialize':
        return this.handleInitialize(request);
      case 'tools/list':
        return this.handleListTools(request);
      case 'tools/call':
        return await this.handleCallTool(request);
      case 'notifications/initialized':
        return null;
      default:
        return {
          jsonrpc: "2.0",
          id: request.id,
          error: {
            code: -32601,
            message: `Method not found: ${request.method}`
          }
        };
    }
  }
}

const bridge = new MCPMemoryBridge();
let buffer = '';

process.stdin.setEncoding('utf8');

process.stdin.on('data', async (chunk) => {
  buffer += chunk;
  
  const lines = buffer.split('\n');
  buffer = lines.pop();
  
  for (const line of lines) {
    if (line.trim()) {
      try {
        const request = JSON.parse(line);
        const response = await bridge.processRequest(request);
        if (response !== null) {
          console.log(JSON.stringify(response));
        }
      } catch (error) {
        console.log(JSON.stringify({
          jsonrpc: "2.0",
          id: null,
          error: {
            code: -32700,
            message: "Parse error",
            data: error.message
          }
        }));
      }
    }
  }
});

process.stdin.on('end', () => {
  process.exit(0);
});

process.on('SIGTERM', () => {
  process.exit(0);
});

process.on('SIGINT', () => {
  process.exit(0);
});