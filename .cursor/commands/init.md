# Init (Session Setup)

Prepare the environment and test MCP connectivity before starting any task.

---

## Workflow Overview

```
/init → Test MCPs → Cache Status → Env Setup → Ready
```

**Estimated Time:** 10-30 seconds (depending on env setup)

---

## Steps

### 1. MCP Connectivity Check
Test and report status (✅/❌) for:
- Jira MCP
- Google Drive MCP
- MariaDB MCP
- MongoDB MCP

**If any fail:** Report error and state that you cannot proceed until resolved.

**See:** `.cursor/rules/troubleshooting.mdc` for MCP startup fixes

### 2. Cache MCP Status
Store MCP availability for session:
```
## Session MCP Status
- Jira MCP: ✅ / ❌
- Google Drive MCP: ✅ / ❌
- MariaDB MCP: ✅ / ❌
- MongoDB MCP: ✅ / ❌
```

**Purpose:** Subagents check cache before MCP calls (avoid repeated failures)

### 3. Environment Setup
- Present commands to run (e.g., `npm install`, create `.env`)
- Ask for explicit user approval
- Execute approved commands
- Confirm: **"Initialization complete. Ready for `/start` command."**

---

## Session Context

**MCP status persists** for the entire session. Subsequent commands reference cached status instead of re-testing.

---

## Usage

```
/init
```

**Use:** At the start of each session
