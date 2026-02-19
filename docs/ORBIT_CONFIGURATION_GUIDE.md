# Project Orbit - Configuration & Setup Guide

**Complete setup instructions for enabling Project Orbit**

---

## Pre-Requisites

### System Requirements
- Node.js 16+ or 18+
- npm or yarn
- Git
- Cursor IDE (with MCP support)

### Project Requirements
- `.cursor/commands/` directory (Orbit command definitions)
- `.cursor/agents/` directory (Subagent definitions)
- `.cursor/skills/` directory (AI Skills)
- `.cursor/rules/` directory (Project-specific rules)
- `docs/` directory (for report storage)

---

## Step 1: Verify Orbit Structure

### Check if Orbit is installed

```bash
# From project root
ls -la .cursor/

# Should show:
# commands/       ← Orbit commands
# agents/         ← Subagents
# skills/         ← AI skills
# rules/          ← Project rules
```

### List all command files

```bash
ls -la .cursor/commands/
# Should have:
# start.md
# plan.md
# finish.md
# init.md
# explain.md
# flow.md
# fix.md
# test-mode.md
```

### List all agent files

```bash
ls -la .cursor/agents/
# Should have:
# schema-analyzer.md
# rabbit-tracer.md
# tdd-planner.md
# risk-analyzer.md
# code-reviewer.md
# test-validator.md
# regression-detector.md
# orbit-validator.md
# implementation-planner.md
```

### List all rules

```bash
ls -la .cursor/rules/
# Should have:
# db_rules.mdc
# microservice_rules.mdc
# tech_stack.mdc
# cross_service.mdc
# business_logic.mdc
# mcp_usage.mdc
# agent_directives.mdc
# reasoning.mdc
# troubleshooting.mdc
```

---

## Step 2: Configure MCP (Model Context Protocol)

MCPs allow Orbit to connect to external data sources (Jira, Google Drive, Databases, etc.).

### 2.1 Open Cursor Settings

```
Cursor → Settings → MCP
```

Or edit: `~/.cursor/settings.json`

### 2.2 Configure Jira MCP

```json
{
  "mcps": {
    "jira": {
      "enabled": true,
      "type": "stdio",
      "command": "node",
      "args": ["path/to/jira-mcp.js"],
      "env": {
        "JIRA_URL": "https://jira.company.com",
        "JIRA_USERNAME": "your-username",
        "JIRA_API_TOKEN": "your-api-token"
      }
    }
  }
}
```

**Where to get credentials:**
- JIRA_URL: Your Jira instance URL
- JIRA_USERNAME: Your Jira username
- JIRA_API_TOKEN: Generate at https://id.atlassian.com/manage-profile/security

### 2.3 Configure Google Drive MCP

```json
{
  "mcps": {
    "gdrive": {
      "enabled": true,
      "type": "stdio",
      "command": "node",
      "args": ["path/to/gdrive-mcp.js"],
      "env": {
        "GDRIVE_CLIENT_ID": "your-client-id",
        "GDRIVE_CLIENT_SECRET": "your-client-secret",
        "GDRIVE_REFRESH_TOKEN": "your-refresh-token"
      }
    }
  }
}
```

**Setup:**
1. Go to Google Cloud Console
2. Create OAuth 2.0 credentials
3. Get Client ID, Client Secret
4. Use Google OAuth flow to get Refresh Token

### 2.4 Configure MariaDB MCP

```json
{
  "mcps": {
    "mariadb": {
      "enabled": true,
      "type": "stdio",
      "command": "node",
      "args": ["path/to/mariadb-mcp.js"],
      "env": {
        "MARIADB_HOST": "localhost",
        "MARIADB_PORT": "3306",
        "MARIADB_USER": "your-user",
        "MARIADB_PASSWORD": "your-password",
        "MARIADB_DATABASE": "your-db-name"
      }
    }
  }
}
```

**Configuration:**
- MARIADB_HOST: Database server hostname/IP
- MARIADB_PORT: Database port (default 3306)
- MARIADB_USER: Database username
- MARIADB_PASSWORD: Database password
- MARIADB_DATABASE: Database name to analyze

### 2.5 Configure MongoDB MCP

```json
{
  "mcps": {
    "mongodb": {
      "enabled": true,
      "type": "stdio",
      "command": "node",
      "args": ["path/to/mongodb-mcp.js"],
      "env": {
        "MONGODB_URI": "mongodb://user:pass@host:port/database",
        "MONGODB_DATABASE": "your-db-name"
      }
    }
  }
}
```

**Configuration:**
- MONGODB_URI: MongoDB connection string
- MONGODB_DATABASE: Database to analyze

### 2.6 Configure GitHub MCP (Optional)

```json
{
  "mcps": {
    "github": {
      "enabled": true,
      "type": "stdio",
      "command": "node",
      "args": ["path/to/github-mcp.js"],
      "env": {
        "GITHUB_TOKEN": "your-personal-access-token"
      }
    }
  }
}
```

**Where to get:**
- GITHUB_TOKEN: Generate at https://github.com/settings/tokens

### MCP Verification

After configuring, run:
```
/init
```

Expected output:
```
MCP Connectivity Status:
┌─────────────┬──────────┐
│ MCP         │ Status   │
├─────────────┼──────────┤
│ Jira        │ ✅ OK    │
│ GDrive      │ ✅ OK    │
│ MariaDB     │ ✅ OK    │
│ MongoDB     │ ✅ OK    │
│ GitHub      │ ✅ OK    │
└─────────────┴──────────┘

Session Status: READY TO PROCEED
```

### Troubleshooting MCPs

#### Jira MCP Not Working
```
Issue: Cannot connect to Jira
Fix:
1. Verify JIRA_URL is correct
2. Check JIRA_USERNAME and JIRA_API_TOKEN
3. Verify Jira user has API access enabled
4. Test connection manually:
   curl -u user:token https://jira.company.com/rest/api/3/myself
```

#### MariaDB MCP Not Working
```
Issue: Cannot connect to database
Fix:
1. Verify MARIADB_HOST is reachable
   ping localhost
2. Verify MARIADB_PORT is correct
3. Verify MARIADB_USER and MARIADB_PASSWORD
4. Test connection manually:
   mysql -h localhost -u user -p database
5. Check firewall (if remote server)
```

#### GDrive MCP Not Working
```
Issue: Cannot fetch PRD from Google Drive
Fix:
1. Verify Google OAuth credentials are valid
2. Check GDRIVE_REFRESH_TOKEN hasn't expired
3. Re-authenticate through OAuth flow
4. Verify file sharing permissions
```

---

## Step 3: Configure Project Rules

Rules define coding standards for your project. They're in `.cursor/rules/` directory.

### Available Rules

| File | Purpose | Examples |
|------|---------|----------|
| `db_rules.mdc` | Database best practices | N+1 prevention, indexing |
| `microservice_rules.mdc` | Service architecture | TDD, HIPAA, error handling |
| `tech_stack.mdc` | Tech requirements | Joi validation, JSDoc format |
| `cross_service.mdc` | RabbitMQ/APIs | Contract verification |
| `business_logic.mdc` | Domain logic | Persona alignment |
| `mcp_usage.mdc` | MCP usage | Error handling, fallbacks |

### How Rules Are Applied

Orbit **automatically selects** rules based on file patterns:
- `.ts` service file → Apply `microservice_rules.mdc`
- `.ts` file with DB query → Apply `db_rules.mdc`
- `.ts` file with RabbitMQ → Apply `cross_service.mdc`
- `.ts` controller file → Apply `tech_stack.mdc`

**You don't manually route rules** - Orbit does it automatically.

### Example: Customizing db_rules

If your project has different N+1 thresholds:

```markdown
# Your Customization in db_rules.mdc

## N+1 Query Prevention

**Threshold (when to flag):**
- Our project: 2+ queries in a loop
- Default: 3+ queries

**Acceptable patterns:**
- Batch queries with IN clause
- GraphQL DataLoader
- Projection to single column

**Unacceptable patterns:**
❌ for (const item of items) { await db.query(...) }
❌ items.map(item => db.query(...))
✅ db.query({ id: { $in: item_ids } })
```

### Creating New Rules

To add a new rule for your project:

1. Create file: `.cursor/rules/my-custom-rule.mdc`
2. Define trigger (file pattern)
3. Define standards
4. Reference in commands/agents

See `create-rule` skill for detailed guidance.

---

## Step 4: Enable Orbit Commands

Orbit commands are defined in `.cursor/commands/` and are invoked via `/command-name`.

### Check Commands Are Loaded

In Cursor:
```
Cmd+K (or Ctrl+K on Windows)

Type: /start
→ Should show suggestions
```

If no suggestions:
1. Check `.cursor/commands/start.md` exists
2. Restart Cursor
3. Check command syntax in file

### Available Commands

```bash
# Initialize
/init                           # Check MCP status

# Core Workflow
/start TICKET_ID                # Discover & analyze
/plan                           # Plan & design
/finish                         # Verify & complete

# Information
/explain <feature>              # Understand feature
/flow <service>                 # Show architecture
/fix <problem>                  # Troubleshoot

# Testing
/test-mode TICKET_ID            # Blind implementation test
/test-mode-blind-handoff        # Capture PR for comparison
```

---

## Step 5: Configure Project Structure

Orbit expects certain directories:

```
project-root/
├── .cursor/
│   ├── commands/               ← Orbit workflow commands
│   ├── agents/                 ← AI subagents
│   ├── skills/                 ← AI skills
│   └── rules/                  ← Project rules
├── docs/
│   ├── ORBIT_OVERVIEW.md       ← You're reading this!
│   ├── ORBIT_FLOWCHART.md      ← Visual flows
│   ├── ORBIT_COMMANDS_GUIDE.md ← Command reference
│   └── CSIQ-12043/             ← Per-ticket reports
│       ├── context_analysis_report.md
│       ├── discovery_report.md
│       ├── tdd_blueprint.md
│       └── ... (other reports)
├── src/
│   ├── controllers/
│   ├── services/
│   ├── models/
│   └── ...
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
└── pm2.json                    ← Service process definitions
```

### Create docs/ Directory

```bash
mkdir -p docs
```

This is where Orbit stores all analysis reports.

### Verify pm2.json

Orbit checks `pm2.json` for service configuration:

```json
{
  "apps": [
    {
      "name": "auth-service",
      "script": "./src/services/auth-service.js",
      "watch": true,
      "env": {
        "NODE_ENV": "development"
      }
    },
    {
      "name": "user-service",
      "script": "./src/services/user-service.js",
      "watch": true
    }
  ]
}
```

When you add a new service, update `pm2.json` so Orbit knows about it.

---

## Step 6: Enable Caching

Orbit caches reports to avoid redundant work. Caching is in `docs/<TICKET_ID>/`.

### Cache Files

```
docs/CSIQ-12043/
├── context_analysis_report.md       ← From /start
├── schema_analysis_report.md        ← From /start (if DB changes)
├── message_flow_report.md           ← From /start (if RabbitMQ)
├── discovery_report.md              ← From /start
├── tdd_blueprint.md                 ← From /plan
├── risk_assessment_report.md        ← From /plan
├── implementation_plan.md           ← From /plan
├── code_review_report.md            ← From /finish
├── test_validation_report.md        ← From /finish
└── regression_impact_report.md      ← From /finish
```

### Clearing Cache

If you need to re-run analysis:
```bash
rm -rf docs/CSIQ-12043/
```

Then re-run `/start` for fresh analysis.

---

## Step 7: Configure Logging

Orbit generates detailed logs for debugging.

### View Orbit Logs

```bash
# Cursor logs (built-in commands)
Cursor → Help → Toggle Developer Tools

# Agent execution logs
Look in browser console (F12)

# MCP server logs (if applicable)
Check MCP server output in terminal
```

### Enable Debug Mode

In Cursor settings:
```json
{
  "debug": {
    "orbit": true,
    "subagents": true,
    "mcp": true
  }
}
```

---

## Step 8: Verify Complete Setup

Run this checklist:

### ✅ Directory Structure
```bash
[ ] .cursor/commands/start.md exists
[ ] .cursor/agents/tdd-planner.md exists
[ ] .cursor/skills/discovery/SKILL.md exists
[ ] .cursor/rules/db_rules.mdc exists
[ ] docs/ directory exists
```

### ✅ MCP Configuration
```bash
[ ] /init returns all MCPs READY
[ ] Jira MCP can fetch tickets
[ ] GDrive MCP can fetch files
[ ] MariaDB MCP can query schema
[ ] MongoDB MCP can query collections
```

### ✅ Commands Available
```bash
[ ] /start works
[ ] /plan works
[ ] /finish works
[ ] /init works
[ ] /explain works
```

### ✅ Rules Loaded
```bash
[ ] Orbit applies db_rules to DB files
[ ] Orbit applies microservice_rules to service files
[ ] Orbit applies tech_stack.mdc to all code
```

### ✅ Reports Generate
```bash
[ ] Run /start CSIQ-12043 (test ticket)
[ ] docs/CSIQ-12043/context_analysis_report.md created
[ ] docs/CSIQ-12043/discovery_report.md created
```

**If all ✅ → Orbit is ready!**

---

## Troubleshooting Setup

### Command Not Found: /start

**Symptom:**
```
/start command not recognized
```

**Fix:**
1. Check `.cursor/commands/start.md` exists
2. Restart Cursor (Cmd+Q and reopen)
3. Check for syntax errors in start.md

### MCP Timeout Error

**Symptom:**
```
Jira MCP: ❌ TIMEOUT
```

**Fix:**
1. Check network connectivity
2. Verify MCP credentials
3. Check if MCP server is running
4. Increase timeout in MCP config

### Rules Not Being Applied

**Symptom:**
```
Code review doesn't catch N+1 queries
```

**Fix:**
1. Verify `db_rules.mdc` exists and has N+1 rules
2. Check if rule is referenced in `.cursor/agents/code-reviewer.md`
3. Verify file patterns in rules match your files

### Reports Not Generating

**Symptom:**
```
docs/CSIQ-12043/ folder not created
```

**Fix:**
1. Verify `docs/` directory exists (create if needed)
2. Check Jira MCP can fetch ticket
3. Verify ticket ID is correct (CSIQ-12043 not 12043)

---

## Performance Tuning

### Optimize MCP Response Time

```json
{
  "mcps": {
    "mariadb": {
      "timeout": 30000,      // Increase from 10s to 30s
      "max_retries": 3,      // Retry failed queries
      "connection_pool": 5   // Use connection pooling
    }
  }
}
```

### Parallel Execution Performance

Orbit runs subagents in parallel when possible:
- `schema-analyzer` + `rabbit-tracer` run together
- `tdd-planner` + `risk-analyzer` run together
- `code-reviewer` + `test-validator` run together

This reduces `/start` time from ~90s → ~65s (28% faster).

### Caching Optimization

Orbit caches reports. To leverage:
1. Run `/start` once
2. Don't delete `docs/CSIQ-12043/`
3. Run `/plan` (reuses cache, no re-analysis)
4. This saves ~40s per `/plan` run

---

## Advanced Configuration

### Custom MCP Server

To add a custom MCP:

1. Create MCP server file (e.g., `custom-mcp.js`)
2. Register in `.cursor/settings.json`
3. Reference in agents that need it

See MCP documentation for server implementation.

### Custom Skills

To add a custom Skill:

1. Create skill file: `.cursor/skills/my-skill/SKILL.md`
2. Follow SKILL.md format
3. Reference in commands/agents that use it

See `create-skill` guidance for details.

---

## Next Steps

1. **Run `/init`** - Verify all MCPs working
2. **Try `/start`** - Test with real Jira ticket
3. **Review Discovery Report** - Check quality
4. **Run `/plan`** - Generate TDD Blueprint
5. **Implement feature** - Write code per TDD
6. **Run `/finish`** - Verify quality

---

## Support & Debugging

### Check Orbit Status
```
/init
```

### Understand Feature
```
/explain how <feature> works
```

### Troubleshoot Issues
```
/fix <problem description>
```

### View Troubleshooting Matrix
```
docs/ORBIT_TROUBLESHOOTING_MATRIX.md
```

---

**Last Updated:** February 19, 2026  
**Version:** 1.0  
**Configuration Status:** Complete
