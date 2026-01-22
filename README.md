# MCP Project: Local AI Coding Assistant with Ollama & Gemma 3:4b

## 1. Project Overview
This project establishes a **production-grade local AI coding assistant** environment. It integrates **VSCode** (via the Continue.dev extension) with **Ollama** running the **Gemma 3:4b** model, connected to your local filesystem through the **Model Context Protocol (MCP)**.

**Key Goal**: To enable a privacy-focused, offline-capable AI that can read, analyze, and modify your local codebase securely, mirroring the capabilities of cloud-based assistants like Claude or GitHub Copilot but running entirely on your machine.

---

## 2. Project Architecture & File Structure

This repository contains the configuration and test files needed to bootstrap the environment.

### **Core Configuration**
*   **[`continue_config.json`](file:///Users/mac/Miscellaneous/MCPs/continue_config.json)**
    *   **Role**: The "brain" of the setup. It configures the Continue extension to talk to Ollama and initializes the MCP servers.
    *   **Key Settings**:
        *   `models`: Points to `gemma3:4b`.
        *   `mcpServers`: Configures accessibility to local directories (`/Users/mac/Miscellaneous/MCPs`, `/Users/mac/Documents`).
*   **[`starter-guide-claude.md`](file:///Users/mac/Miscellaneous/MCPs/starter-guide-claude.md)**
    *   **Role**: The master reference guide/runbook used to build this environment.

### **Test & Demo Environment**
*   **[`mcp-test/`](file:///Users/mac/Miscellaneous/MCPs/mcp-test/)**
    *   `main.py`: A simple Fibonacci script used to test the AI's ability to read and analyze code.
    *   `test_main.py`: Unit tests to verify the AI's ability to generate and run tests.
    *   `requirements.txt`: Python dependencies for the test project.
*   **[`legacy.py`](file:///Users/mac/Miscellaneous/MCPs/legacy.py)**
    *   **Role**: Intentionally "bad" code used to test the AI's refactoring and "fix this" capabilities.

### **Infrastructure**
*   **[`Dockerfile`](file:///Users/mac/Miscellaneous/MCPs/Dockerfile)**
    *   **Role**: A security-hardened container definition for running the MCP filesystem server in read-only mode, useful for enterprise deployments where you want to prevent the AI from modifying code.

---

## 3. Step-by-Step Setup & Installation Guide

Follow these steps exactly to set up your environment.

### **Prerequisites**
1.  **Frameworks**: Node.js (v18+), Python (v3.10+), and VSCode installed.
2.  **Ollama**: Install from [ollama.com](https://ollama.com).

### **Step 1: Install & Prepare Ollama**
Run these commands in your terminal to get the AI models ready:

```bash
# 1. Start Ollama server (if not already running)
ollama serve

# 2. Pull the main intelligence model
ollama pull gemma3:4b

# 3. Pull the embedding model (crucial for "codebase context" search)
ollama pull nomic-embed-text
```

### **Step 2: Install VSCode Extension**
1.  Open **VSCode**.
2.  Press `Cmd + Shift + X` to open Extensions.
3.  Search for **"Continue"**.
4.  Install the extension: **"Continue - Codestral, Claude, and more"**.

### **Step 3: Configure Continue with MCP**
We need to tell Continue to use our local setup instead of the default cloud configuration.

1.  **Locate the Config File**:
    The config file lives at `~/.continue/config.json`.

2.  **Apply Our Configuration**:
    Run this command in your terminal to overwrite the default config with our project config:
    ```bash
    cp /Users/mac/Miscellaneous/MCPs/continue_config.json ~/.continue/config.json
    ```

### **Step 4: Install MCP Filesystem Server**
The "glue" that lets the AI read your files is a Node.js package.

```bash
# Install the MCP filesystem server globally
npm install -g @modelcontextprotocol/server-filesystem
```

---

## 4. Verification & Testing

Verify that everything is working correctly.

### **Verification 1: Check Ollama Response (CLI)**
Ensure the model is awake and responding.
```bash
ollama run gemma3:4b "Are you ready to code?"
```

### **Verification 2: Check MCP Server Access (Manual)**
Verify the MCP server can start and sees your directory.
```bash
# Run this to confirm it starts without error
npx -y @modelcontextprotocol/server-filesystem /Users/mac/Miscellaneous/MCPs
```
*   *Success*: Output shows `MCP Filesystem Server running`.
*   *Action*: Press `Ctrl + C` to stop it.

### **Verification 3: End-to-End VSCode Test**
1.  **Restart VSCode**: Press `Cmd + Shift + P` -> Select **"Developer: Reload Window"**.
2.  **Open Continue**: Click the Continue logo in the sidebar (or `Cmd + L`).
3.  **Ask a Question**: Type:
    > "Look at legacy.py. What does the process_data function do?"
4.  **Confirm**: The AI should explain the code, proving it read the file via MCP.

---

## 5. Current Capabilities

1.  **Context-Aware Chat**: The AI can "see" your open files and answer questions about them.
2.  **Codebase Indexing**: Using `nomic-embed-text`, it can search across your project to find relevant functions or classes.
3.  **Local Filesystem Access**: via MCP, it has direct access to read directory structures and file contents without manual copy-pasting.
4.  **Refactoring & Code Gen**: capable of rewriting functions, adding docstrings, and generating unit tests locally.
5.  **Edit Mode**: Can apply diffs directly to your files (if user approves).

---

## 6. Enterprise Scaling & Extensibility (Production Grade)

To take this from a local dev tool to an **Enterprise AI Platform**, consider the following evolution:

### **Phase 1: Enhanced Security & Governance**
*   **Read-Only MCP Containers**: Deploy the `Dockerfile` provided to run the MCP server in a container with strictly mounted volumes (`:ro`). This prevents accidental deletions or malicious code insertions.
*   **Audit Logging**: Wrap the MCP server start command in a script that tees standard input/output to a secure log file (`/var/log/mcp_audit.log`) for compliance reviews.

### **Phase 2: Advanced Data Connectors (RAG)**
Instead of just local files, connect MCP to enterprise knowledge bases:
*   **PostgreSQL MCP**: Connect to your internal databases to let the AI query schema and data securely.
    *   *Usage*: `npx -y @modelcontextprotocol/server-postgres postgresql://user:pass@db:5432/internal`
*   **GitHub/GitLab MCP**: Allow the AI to read PRs, issues, and diffs directly.
*   **Slack/Teams MCP**: Enable the AI to answer questions based on team chat history.

### **Phase 3: Centralized Inference (Hybrid Cloud)**
*   **OpenAI Compatible Endpoints**: Instead of local Ollama, point `apiBase` to a centralized, self-hosted LLM gateway (like vLLM or TGI) running on on-premise GPU clusters (e.g., A100s).
*   **Model Router**: Use a gateway like **LiteLLM** to route simple queries (autocomplete) to `gemma3:4b` and complex reasoning (architecture design) to larger models like `Llama-3-70b` or Claude 3.5 Sonnet via API.

### **Phase 4: Specialized Agent Swarms**
Create specialized MCP servers for different domains:
*   **DevOps Agent**: Has MCP access to `kubectl` and `terraform` (read-only) to answer infrastructure questions.
*   **QA Agent**: Has MCP access to your CI logs and JIRA to correlate failures with tickets.

### **Example "Enterprise" Config Snippet**
```json
"mcpServers": {
  "corporate-docs": {
    "command": "python",
    "args": ["-m", "mcp_server_confluence", "--url", "https://wiki.corp.com"]
  },
  "secure-production-db": {
     "command": "docker",
     "args": ["run", "--rm", "mcp-postgres-ro", "--connection", "secret_env_var"]
  }
}
```
