# Start New Task

Initialize a new development task by gathering JIRA context, analyzing dependencies, and creating a discovery report.

---

## Workflow Overview

```
/start → JIRA Context (inline) → Parallel Analysis (schema + rabbit) → Discovery → Approval
```

**Estimated Time:** 45-65 seconds (JIRA: 25-35s, parallel: 20-30s)

---

## Steps

### 1. JIRA Ticket
- Ask for the JIRA ticket link
- Extract ticket ID (e.g., `CSIQ-12043`)
- Use `docs/<JIRA_TICKET_ID>/` for all documentation paths

### 2. JIRA Context Analysis (Inline)
**Main agent uses:** `.cursor/skills/jira-context-analysis/SKILL.md`

**What happens:**
- Fetch ticket + sub-tasks + PRD using Jira/GDrive MCPs
- Synthesize 4-part Context Analysis Report
- **Parse requirements** → extract entities, service, exchange/routing key
- **Save:** `docs/<JIRA_TICKET_ID>/context_analysis_report.md`

**If MCP unavailable:** Use fallback (ask user for manual input, HIGH RISK warning)

### 3. Parallel Analysis (with parsed context)
**Launch in parallel** (single message, multiple Tasks):

**Subagent 1: schema-analyzer** (if DB changes identified)
```javascript
Task(
  subagent_type="generalPurpose",
  model="fast",
  prompt="Read and execute .cursor/agents/schema-analyzer.md 
          for entities: <from JIRA parse>. 
          Verbosity: full",
  description="Analyze DB schemas"
)
```
- **Output:** `docs/<JIRA_TICKET_ID>/schema_analysis_report.md`

**Subagent 2: rabbit-tracer** (if RabbitMQ identified)
```javascript
Task(
  subagent_type="generalPurpose",
  model="fast",
  prompt="Read and execute .cursor/agents/rabbit-tracer.md. 
          Service: <from JIRA parse>. 
          Exchange: <from JIRA parse>. 
          Verbosity: full",
  description="Trace RabbitMQ flow"
)
```
- **Output:** `docs/<JIRA_TICKET_ID>/message_flow_report.md`

**Note:** Only invoke applicable subagents (skip rabbit-tracer if no RabbitMQ)

### 4. Discovery
**Main agent uses:** `.cursor/skills/discovery/SKILL.md`

**What happens:**
- Trace dependencies (routes → controllers → services → repos)
- Identify patterns (2-3 existing examples)
- Check pm2.json, .env.example
- Use outputs from schema-analyzer, rabbit-tracer

### 5. Discovery Report & Approval
- Synthesize all outputs → unified Discovery Report
- **Save:** `docs/<JIRA_TICKET_ID>/discovery_report.md`
- **Present to user** and wait for explicit approval

### 6. Next Steps
After approval, user can proceed to `/plan` for TDD Blueprint and Risk Assessment.

---

## Architecture Note

**Why JIRA is inline (not a subagent):**
- Schema/rabbit analyzers DEPEND on JIRA context to know what to analyze
- Running JIRA as subagent would cause false parallelism (main agent idle)
- Inline execution enables true parallelism for dependent analyses

**Result:** ~10% faster + no idle time + honest dependencies

---

## Usage

```
/start implement user authentication for CSIQ-12043
```
