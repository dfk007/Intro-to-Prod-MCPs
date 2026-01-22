# Dockerfile for read-only MCP server
FROM node:18-alpine

RUN npm install -g @modelcontextprotocol/server-filesystem

# Create read-only user
RUN adduser -D -u 1001 mcpuser

# Mount code as read-only
VOLUME ["/code:ro"]

USER mcpuser

CMD ["npx", "@modelcontextprotocol/server-filesystem", "/code"]
