# Production-Grade MCP Implementation: VSCode + Local Filesystem + Ollama

This guide will help you build a context-aware coding assistant using MCP to connect VSCode to your local filesystem with Ollama's Gemma 3:4b model.

## Architecture Overview

```
VSCode (MCP Client) 
    ↓
Claude Desktop/Continue.dev (MCP Host)
    ↓
MCP Server (Filesystem)
    ↓
Local Codebase + Git Repository
    ↓
Ollama (Gemma 3:4b LLM)
```

## Prerequisites Checklist

* [ ] macOS machine (works on Linux too)
* [ ] VSCode installed
* [ ] Node.js 18+ installed
* [ ] Python 3.10+ installed
* [ ] Ollama installed
* [ ] Git installed

---

## Step 1: Install and Configure Ollama

### 1.1 Install Ollama (if not already installed)

```bash
# macOS
brew install ollama

# Or download from https://ollama.ai
```

### 1.2 Pull Gemma 3:1b Model

```bash
ollama pull gemma3:4b
# Using gemma3:4b as the primary model
# For better code performance, consider gemma2:9b or codellama:7b

ollama list  # Verify installation
```

### 1.3 Test Ollama

```bash
ollama run gemma3:4b "Write a hello world in Python"
```

### 1.4 Start Ollama Server (runs in background)

```bash
ollama serve
```

---

## Step 2: Choose Your MCP Client Strategy

You have** ****two main options** for connecting VSCode to MCP:

### **Option A: Continue.dev (Recommended for VSCode)**

* Native VSCode extension
* Built-in MCP support
* Integrated chat interface
* Better for coding workflows

### **Option B: Claude Desktop + External Editor**

* Uses Anthropic's Claude Desktop app
* VSCode as external editor
* More powerful reasoning (if using Claude)
* Better for complex tasks

**We'll proceed with Option A (Continue.dev) as it's more integrated with VSCode.**

---

## Step 3: Install Continue.dev Extension

### 3.1 Install Extension

1. Open VSCode
2. Go to Extensions (Cmd+Shift+X)
3. Search for "Continue"
4. Install "Continue - Codestral, Claude, and more"
5. Restart VSCode

### 3.2 Configure Continue with Ollama

1. After installation, Continue sidebar will appear
2. Click the gear icon ⚙️ in Continue sidebar
3. This opens** **`~/.continue/config.json`

Replace with this configuration:

```json
{
  "models": [
    {
      "title": "Gemma 3 4B Local",
      "provider": "ollama",
      "model": "gemma3:4b",
      "apiBase": "http://localhost:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Gemma 3 Autocomplete",
    "provider": "ollama",
    "model": "gemma3:4b",
    "apiBase": "http://localhost:11434"
  },
  "embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text",
    "apiBase": "http://localhost:11434"
  },
  "slashCommands": [
    {
      "name": "edit",
      "description": "Edit selected code"
    },
    {
      "name": "comment",
      "description": "Write comments for selected code"
    },
    {
      "name": "share",
      "description": "Export conversation to markdown"
    },
    {
      "name": "cmd",
      "description": "Generate shell commands"
    }
  ]
}
```

### 3.3 Pull Embedding Model (for better code search)

```bash
ollama pull nomic-embed-text
```

---

## Step 4: Install and Configure MCP Filesystem Server

### 4.1 Install MCP Filesystem Server

```bash
# Using npm (recommended)
npm install -g @modelcontextprotocol/server-filesystem

# Or using npx (no installation needed)
# We'll use npx in config below
```

### 4.2 Configure MCP in Continue

Edit** **`~/.continue/config.json` and add the** **`mcpServers` section:

```json
{
  "models": [
    {
      "title": "Gemma 3 4B Local",
      "provider": "ollama",
      "model": "gemma3:4b",
      "apiBase": "http://localhost:11434"
    }
  ],
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/YOUR_USERNAME/projects",
        "/Users/YOUR_USERNAME/Documents/code"
      ],
      "env": {
        "NODE_ENV": "production"
      }
    },
    "git": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-git",
        "--repository",
        "/Users/YOUR_USERNAME/projects/my-repo"
      ]
    }
  },
  "tabAutocompleteModel": {
    "title": "Gemma 3 Autocomplete",
    "provider": "ollama",
    "model": "gemma3:4b",
    "apiBase": "http://localhost:11434"
  },
  "embeddingsProvider": {
    "provider": "ollama",
    "model": "nomic-embed-text",
    "apiBase": "http://localhost:11434"
  }
}
```

 **Important** : Replace** **`/Users/YOUR_USERNAME/projects` with your actual project paths.

### 4.3 Linux Configuration Adjustments

For Linux, paths would be like:

```json
"args": [
  "-y",
  "@modelcontextprotocol/server-filesystem",
  "/home/YOUR_USERNAME/projects",
  "/home/YOUR_USERNAME/code"
]
```

---

## Step 5: Verify MCP Server Installation

### 5.1 Test Filesystem Server Manually

```bash
# Navigate to a test project
cd ~/projects/test-project

# Run MCP server directly
npx -y @modelcontextprotocol/server-filesystem $(pwd)
```

You should see output like:

```
MCP Filesystem Server running
Allowed directories: ['/Users/you/projects/test-project']
```

Press Ctrl+C to stop.

### 5.2 Restart VSCode

```bash
# Reload VSCode window
# Cmd+Shift+P → "Developer: Reload Window"
```

---

## Step 6: Create a Test Project

### 6.1 Set Up Test Repository

```bash
# Create test project
mkdir -p ~/projects/mcp-test
cd ~/projects/mcp-test

# Initialize git
git init

# Create sample Python project
cat > main.py << 'EOF'
def calculate_fibonacci(n):
    if n <= 1:
        return n
    return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)

def main():
    result = calculate_fibonacci(10)
    print(f"Fibonacci(10) = {result}")

if __name__ == "__main__":
    main()
EOF

# Create tests
cat > test_main.py << 'EOF'
import pytest
from main import calculate_fibonacci

def test_fibonacci_base_cases():
    assert calculate_fibonacci(0) == 0
    assert calculate_fibonacci(1) == 1

def test_fibonacci_recursive():
    assert calculate_fibonacci(5) == 5
    assert calculate_fibonacci(10) == 55
EOF

# Create requirements
cat > requirements.txt << 'EOF'
pytest==7.4.3
EOF

git add .
git commit -m "Initial commit: Fibonacci calculator"
```

### 6.2 Update Continue Config for This Project

Edit** **`~/.continue/config.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/YOUR_USERNAME/projects/mcp-test"
      ]
    },
    "git": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-git",
        "--repository",
        "/Users/YOUR_USERNAME/projects/mcp-test"
      ]
    }
  }
}
```

---

## Step 7: Using MCP-Powered Coding Assistant

### 7.1 Open Project in VSCode

```bash
cd ~/projects/mcp-test
code .
```

### 7.2 Test MCP Capabilities

#### Test 1: Codebase Analysis

1. Open Continue sidebar (Cmd+L or click Continue icon)
2. Ask:** ****"Analyze this codebase and identify performance issues"**

The AI will:

* Use MCP filesystem server to read all files
* Analyze the recursive fibonacci implementation
* Suggest memoization or iterative approach

#### Test 2: Apply Patches

1. Select the** **`calculate_fibonacci` function in** **`main.py`
2. In Continue chat, ask:** ****"Optimize this function using memoization"**
3. Continue will suggest changes
4. Click "Apply" to patch the code

#### Test 3: Generate Tests

1. Ask:** ****"Read test_main.py and add edge case tests for negative numbers"**
2. The AI will:
   * Read existing tests via MCP
   * Generate new test cases
   * Suggest where to add them

#### Test 4: Run Tests

1. Ask:** ****"Create a bash command to run pytest on this project"**
2. Continue might suggest:
   ```bash
   pip install -r requirements.txt && pytest test_main.py -v
   ```
3. You can run this in VSCode terminal

#### Test 5: Git Operations (if git MCP server is configured)

1. Ask:** ****"Show me the git history of main.py"**
2. Ask:** ****"Create a commit message for my changes"**

---

## Step 8: Advanced Production Configurations

### 8.1 Multi-Repository Support

```json
{
  "mcpServers": {
    "filesystem-frontend": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/you/projects/frontend"
      ]
    },
    "filesystem-backend": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/you/projects/backend"
      ]
    },
    "git-monorepo": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-git",
        "--repository",
        "/Users/you/projects/monorepo"
      ]
    }
  }
}
```

### 8.2 Add Database MCP Server (for production)

```bash
npm install -g @modelcontextprotocol/server-postgres
```

```json
{
  "mcpServers": {
    "filesystem": { /* ... */ },
    "database": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://user:pass@localhost:5432/mydb"
      ],
      "env": {
        "PGPASSWORD": "your-password"
      }
    }
  }
}
```

### 8.3 Add Security & Read-Only Permissions

For enterprise deployments, use Docker containers:

```dockerfile
# Dockerfile for read-only MCP server
FROM node:18-alpine

RUN npm install -g @modelcontextprotocol/server-filesystem

# Create read-only user
RUN adduser -D -u 1001 mcpuser

# Mount code as read-only
VOLUME ["/code:ro"]

USER mcpuser

CMD ["npx", "@modelcontextprotocol/server-filesystem", "/code"]
```

Build and run:

```bash
docker build -t mcp-filesystem-ro .
docker run -v $(pwd):/code:ro mcp-filesystem-ro
```

---

## Step 9: Testing the Complete Workflow

### 9.1 End-to-End Test Scenario

 **Scenario** : Refactor a legacy Python function with MCP assistance

1. **Create legacy code** (`legacy.py`):

```python
def process_data(data):
    result = []
    for i in range(len(data)):
        if data[i] > 0:
            result.append(data[i] * 2)
    return result
```

2. **Ask Continue** :

* "Analyze legacy.py for code smells"
* "Refactor this to be more Pythonic"
* "Add type hints and docstrings"
* "Generate unit tests"
* "Apply the changes"

2. **Verify** :

* Check if MCP read the file correctly
* Review suggested changes
* Apply patches
* Run generated tests

### 9.2 Monitor MCP Server Logs

```bash
# Check Continue logs
tail -f ~/.continue/logs/core.log

# Check MCP server output (if running manually)
npx -y @modelcontextprotocol/server-filesystem ~/projects/mcp-test
```

---

## Step 10: Production Hardening

### 10.1 Security Best Practices

1. **Limit filesystem access** to specific directories only
2. **Never expose** sensitive directories like** **`~/.ssh`,** **`~/.aws`
3. **Use environment variables** for credentials
4. **Audit MCP operations** via logging

### 10.2 Create Enterprise Config Template

```json
{
  "models": [
    {
      "title": "Production Gemma",
      "provider": "ollama",
      "model": "gemma3:4b",
      "apiBase": "http://localhost:11434"
    }
  ],
  "mcpServers": {
    "filesystem-readonly": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-v",
        "${workspaceFolder}:/code:ro",
        "mcp-filesystem-secure"
      ]
    },
    "git-operations": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-git",
        "--repository",
        "${workspaceFolder}"
      ],
      "env": {
        "GIT_AUTHOR_NAME": "MCP Agent",
        "GIT_AUTHOR_EMAIL": "mcp@company.com"
      }
    }
  },
  "systemMessage": "You are a senior software engineer. Always follow company coding standards. Never commit code without tests.",
  "contextProviders": [
    {
      "name": "code",
      "params": {
        "maxTokens": 4096
      }
    },
    {
      "name": "diff",
      "params": {}
    }
  ]
}
```

### 10.3 Performance Optimization

For better performance with larger codebases:

```bash
# Use faster models
ollama pull codellama:13b

# Or use quantized versions
ollama pull gemma2:9b-instruct-q4_K_M
```

Update config:

```json
{
  "models": [
    {
      "title": "CodeLlama 13B",
      "provider": "ollama",
      "model": "codellama:13b"
    }
  ]
}
```

---

## Troubleshooting Guide

### Issue 1: MCP Server Not Connecting

 **Symptoms** : Continue can't access filesystem

 **Solutions** :

```bash
# Check if npx works
npx -y @modelcontextprotocol/server-filesystem --version

# Check Continue logs
cat ~/.continue/logs/core.log | grep -i error

# Verify paths in config.json
cat ~/.continue/config.json | grep -A5 mcpServers

# Restart Continue
# Cmd+Shift+P → "Continue: Reload"
```

### Issue 2: Ollama Connection Failed

 **Symptoms** : "Failed to connect to Ollama"

 **Solutions** :

```bash
# Check if Ollama is running
ps aux | grep ollama

# Restart Ollama
pkill ollama
ollama serve &

# Test connection
curl http://localhost:11434/api/tags
```

### Issue 3: Slow Response Times

 **Solutions** :

* Use smaller models (`gemma3:4b` instead of larger variants)
* Reduce context window in config
* Limit filesystem access to specific directories
* Use SSD for model storage

### Issue 4: Permission Denied

 **Symptoms** : MCP can't read files

 **Solutions** :

```bash
# Check directory permissions
ls -la ~/projects/mcp-test

# Fix permissions
chmod -R 755 ~/projects/mcp-test

# Verify user can read files
cat ~/projects/mcp-test/main.py
```

---

## Next Steps for Production Deployment

1. **Set up CI/CD integration** :

* Use MCP in GitHub Actions
* Automate code reviews
* Run security scans

1. **Add more MCP servers** :

* `@modelcontextprotocol/server-github` for PR automation
* `@modelcontextprotocol/server-postgres` for database queries
* `@modelcontextprotocol/server-kubernetes` for cluster management

1. **Implement governance** :

* Create audit logs for all MCP operations
* Set up approval workflows for code changes
* Implement RBAC for different team members

1. **Scale horizontally** :

* Deploy Ollama on GPU servers
* Use remote MCP servers with authentication
* Implement MCP Gateway (TrueFoundry, MintMCP)

---

## Summary

You now have a production-grade MCP setup that:

✅ Connects VSCode to local filesystem via MCP
✅ Uses Ollama (Gemma 3:4b) for AI-powered code assistance
✅ Can read codebases, apply patches, and analyze code
✅ Works on macOS and Linux
✅ Follows security best practices
✅ Is scalable for enterprise use

 **Time to first working prototype** : ~30 minutes
 **Production-ready hardening** : +2-4 hours

This setup forms the foundation for autonomous coding agents, legacy system modernization, and AI-powered DevOps workflows.
