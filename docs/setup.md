# Project Orbit - Installation & Setup Guide

**Install Orbit on a new system in under 30 minutes**

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Install Orbit](#2-install-orbit)
3. [MCP Server Configuration](#3-mcp-server-configuration)
4. [Jira MCP Setup (Local)](#4-jira-mcp-setup-local)
5. [Verify Installation](#5-verify-installation)
6. [Quick Test](#6-quick-test)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Prerequisites

Before installing Orbit, ensure you have:

| Requirement | Version | Purpose |
|-------------|---------|---------|
| **Cursor IDE** | Latest | AI-powered editor (Orbit runs inside Cursor) |
| **Git** | 2.x+ | Clone repository |
| **Node.js** | 16+ | Run microservice (if applicable) |
| **Python** | 3.11+ | Jira MCP server (uvx) |
| **Network** | Office WiFi or VPN | Access remote MCP servers (GDrive, MariaDB, MongoDB) |

### Install Cursor IDE

- Download: [https://cursor.com](https://cursor.com)
- Install and sign in with your account

### Install Python (for Jira MCP)

```bash
# Verify Python
python --version   # Should be 3.11 or 3.12 (avoid 3.14 - MCP compatibility issues)

# Install UV package manager (required for Jira MCP)
pip install uv

# Install Jira MCP package
pip install mcp-atlassian

# Fix dependency issue (if needed)
uv tool install --with "pydantic<2.12" mcp-atlassian --force
```

---

## 2. Install Orbit

### Option A: Clone Repository (Orbit Already Included)

If Orbit is bundled in your project repository:

```bash
# Clone the repository
git clone <your-repo-url> csiq-microservice
cd csiq-microservice

# Ensure you're on master (Orbit lives in master)
git checkout master
git pull origin master
```

**Orbit files are in:**
```
.cursor/
├── agents/          # Subagents (schema-analyzer, tdd-planner, etc.)
├── commands/        # /start, /plan, /finish, /test-mode
├── rules/           # Domain rules (.mdc files)
├── skills/          # Discovery, planning, review skills
└── orbit-config.yaml # Model selection config
```

---

### Option B: Add Orbit to Existing Project

If you need to add Orbit to a project that doesn't have it:

```powershell
# From your project root
.\setup-orbit.ps1
```

**Or run manually:**
```bash
# Clone Orbit template
git clone https://github.com/nowWin09/Orbit-Microservice-test.git orbit-template

# Copy .cursor to your project
cp -r orbit-template/.cursor ./

# Copy AGENTS.md if present
cp orbit-template/AGENTS.md ./

# Clean up
rm -rf orbit-template
```

---

## 3. MCP Server Configuration

**MCP (Model Context Protocol)** connects Orbit to Jira, Google Drive, and databases. This is **required** for Orbit to work.

### Step 1: Locate MCP Configuration File

| OS | Path |
|----|------|
| **Windows** | `C:\Users\<YourUsername>\.cursor\mcp.json` |
| **Mac/Linux** | `~/.cursor/mcp.json` |

**How to open:** Cursor → **Settings** → **MCP Servers** → **Edit Configuration**

---

### Step 2: Add MCP Servers

#### Option A: Quick Install (Recommended)

Use one-click install links to configure remote MCP servers:

1. **Google Drive MCP**  
   [Install Gdrive-MCP-Server](https://cursor.com/en-US/install-mcp?name=Gdrive-MCP-Server&config=eyJ1cmwiOiJodHRwOi8vZGV2Lm1jcHNlcnZlci5jc2lxLmlvOjMwNTAvbWNwIn0%3D)

2. **MongoDB MCP**  
   [Install MongoDB-MCP-Server](https://cursor.com/en-US/install-mcp?name=MongoDB-MCP-Server&config=eyJ1cmwiOiJodHRwOi8vZGV2Lm1jcHNlcnZlci5jc2lxLmlvOjMwNjAvbWNwIn0%3D)

3. **MariaDB MCP**  
   [Install MariaDB-MCP-Server](https://cursor.com/en-US/install-mcp?name=MariaDB-MCP-Server&config=eyJ1cmwiOiJodHRwOi8vZGV2Lm1jcHNlcnZlci5jc2lxLmlvOjMwNzAvbWNwIiwiaGVhZGVycyI6eyJob3N0IjoiMC4wLjAuMCJ9fQ%3D%3D)

Click each link → **Install** or **Add** when prompted.

---

#### Option B: Manual Configuration

Add this to your `mcp.json`:

```json
{
  "mcpServers": {
    "Gdrive-MCP-Server": {
      "url": "http://dev.mcpserver.csiq.io:3050/mcp"
    },
    "MongoDB-MCP-Server": {
      "url": "http://dev.mcpserver.csiq.io:3060/mcp"
    },
    "MariaDB-MCP-Server": {
      "url": "http://dev.mcpserver.csiq.io:3070/mcp",
      "headers": {
        "host": "0.0.0.0"
      }
    },
    "Jira-MCP-Server": {
      "command": "uvx",
      "args": ["mcp-atlassian"],
      "env": {
        "READ_ONLY_MODE": "true",
        "JIRA_URL": "https://carestack.atlassian.net",
        "JIRA_USERNAME": "your.email@carestack.com",
        "JIRA_API_TOKEN": "<YOUR_JIRA_API_TOKEN>"
      }
    }
  }
}
```

**⚠️ Do NOT commit `mcp.json` to git** — it contains credentials.

---

## 4. Jira MCP Setup (Local)

The Jira MCP server runs **locally** and requires additional setup.

### Step 4.1: Install UV and Jira Package

```bash
# Install UV
pip install uv

# Install Jira MCP
pip install mcp-atlassian

# Fix pydantic compatibility (if linker errors occur)
uv tool install --with "pydantic<2.12" mcp-atlassian --force
```

**If you get `link.exe not found` or `pydantic-core` errors:**
- Install **Visual Studio Build Tools** (C++ workload), OR
- Use **Python 3.11** instead of 3.14

---

### Step 4.2: Create Jira API Token

1. Go to: [https://id.atlassian.com/manage-profile/security/api-tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click **Create API token**
3. **Important:**
   - ✅ Create token **without scopes** (basic authentication)
   - ✅ Name it (e.g., "Project Orbit")
   - ✅ **Save immediately** — you won't see it again

---

### Step 4.3: Update mcp.json with Your Credentials

Replace placeholders in `mcp.json`:

```json
"JIRA_USERNAME": "your.email@carestack.com",  ← Your Jira email
"JIRA_API_TOKEN": "ATATT3xFfGF0w..."           ← Token from Step 4.2
```

---

## 5. Verify Installation

### Checklist

- [ ] `.cursor/` directory exists in project root
- [ ] `.cursor/rules/` contains `.mdc` files
- [ ] `.cursor/commands/` contains `start.md`, `plan.md`, `finish.md`
- [ ] `mcp.json` configured (in user home, not project)
- [ ] Jira credentials added to `mcp.json`
- [ ] Connected to **office WiFi** or **office VPN** (for remote MCP servers)

### File Structure

```
your-project/
├── .cursor/
│   ├── agents/           # 10 subagents
│   ├── commands/         # /start, /plan, /finish, /init, /test-mode
│   ├── rules/            # agent_directives, db_rules, business_logic, etc.
│   ├── skills/           # discovery, tdd-planning, review, etc.
│   └── orbit-config.yaml
├── docs/
│   ├── setup.md          # This file
│   └── ORBIT_QUICK_START.md
└── ...
```

---

## 6. Quick Test

### Step 1: Restart Cursor

**Important:** Restart Cursor IDE after editing `mcp.json`.

### Step 2: Run Init

Open Cursor Chat and type:

```
/init
```

**Expected output:**
```
MCP Status:
✅ Jira      - OK
✅ GDrive    - OK
✅ MariaDB   - OK
✅ MongoDB   - OK

Session: READY
```

### Step 3: Run Start (with a ticket)

```
/start CSIQ-12345
```

**Expected:** Orbit fetches the ticket, analyzes context, and generates a Discovery Report.

---

## 7. Troubleshooting

### Issue: "Jira MCP - Connection Failed"

**Fixes:**

1. **Verify UV is installed:**
   ```bash
   uv --version
   ```

2. **Verify API token:**
   - Must be **without scopes** (basic auth)
   - Must be **active** (regenerate if expired)
   - Use full email: `your.email@carestack.com`

3. **Check Python version:**
   ```bash
   python --version  # Use 3.11 if 3.14 causes issues
   ```

---

### Issue: "Remote MCP Servers - Connection Failed"

**Symptoms:** GDrive, MongoDB, MariaDB all fail

**Fixes:**

1. **Check network:**
   - ✅ Connected to **office WiFi**?
   - ✅ OR connected to **office VPN**?
   - ❌ Remote MCP servers do NOT work outside office network

2. **Test connectivity:**
   ```bash
   ping dev.mcpserver.csiq.io
   curl http://dev.mcpserver.csiq.io:3050/mcp
   ```

3. **Restart MCP:** Cursor → Settings → MCP Servers → Restart All

---

### Issue: "link.exe not found" or "pydantic-core" build error

**Cause:** Jira MCP requires native extensions; Python 3.14 + MSVC issues

**Fixes:**

1. **Install Visual Studio Build Tools** (C++ workload)
2. **OR downgrade to Python 3.11:**
   ```bash
   # Use pyenv or conda to install Python 3.11
   pyenv install 3.11.0
   pyenv local 3.11.0
   ```

---

### Issue: "Orbit commands not recognized"

**Fixes:**

1. **Verify .cursor/ exists** in project root
2. **Check Cursor Settings** → Rules → Project rules are loaded
3. **Restart Cursor** after cloning
4. **Open project folder** (not a single file) in Cursor

---

### Issue: "Agent doesn't follow Orbit workflow"

**Fixes:**

1. **Ensure rules are in `.cursor/rules/`** (not elsewhere)
2. **Check `agent_directives.mdc`** is present
3. **Use explicit commands:** `/start`, `/plan`, `/finish` (with leading slash)

---

## Network Requirements Summary

| MCP Server | Type | Network |
|------------|------|---------|
| **Gdrive-MCP-Server** | Remote | Office WiFi or VPN |
| **MongoDB-MCP-Server** | Remote | Office WiFi or VPN |
| **MariaDB-MCP-Server** | Remote | Office WiFi or VPN |
| **Jira-MCP-Server** | Local | Works anywhere |

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/init` | Verify MCP connectivity, start session |
| `/start CSIQ-12345` | Begin discovery for a ticket |
| `/plan` | Create TDD blueprint & implementation plan |
| `/finish` | Run code review & validation |
| `/test-mode CSIQ-12345` | Validate Orbit quality (re-implement & compare) |

---

## Next Steps

- **Quick Start:** See [ORBIT_QUICK_START.md](ORBIT_QUICK_START.md)
- **Commands Guide:** See [ORBIT_COMMANDS_GUIDE.md](ORBIT_COMMANDS_GUIDE.md)
- **Configuration:** See [ORBIT_CONFIGURATION_GUIDE.md](ORBIT_CONFIGURATION_GUIDE.md)
- **Troubleshooting:** See [ORBIT_TROUBLESHOOTING_MATRIX.md](ORBIT_TROUBLESHOOTING_MATRIX.md)

---

## Credits

**Project Orbit** — *"Quality × Speed = Excellence"*

- **Original concept:** Ben S George | Engineering Intern @ CareStack
- **Mentored by:** Nithin S R
- **Extended for:** CSIQ-Microservice (Node.js, multi-model, test mode)

---

**© 2025 CareStack | Project Orbit**
