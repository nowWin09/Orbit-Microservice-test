---
name: jira-context-analysis
description: Inline JIRA context gathering for main agent. Fetch ticket + sub-tasks + PRD, synthesize 4-part Context Analysis Report, parse entities/service/exchange. Use at start of /start command before launching parallel subagents.
disable-model-invocation: false
---

# JIRA Context Analysis Skill (Inline Execution)

**Purpose:** Guide the main agent to gather JIRA context inline during the `/start` command.

**Architecture Decision:** JIRA context gathering is inline (not a subagent) because schema-analyzer and rabbit-tracer subagents DEPEND on JIRA context to know what entities/services to analyze. This enables true parallelism for dependent analyses.

---

## When to Use This Skill

- **Trigger:** `/start` command (every time)
- **Timing:** First step, before launching schema-analyzer or rabbit-tracer subagents
- **Purpose:** Gather requirements from JIRA ticket + PRD, parse to extract entities/service/exchange for dependent analyses

---

## Steps: Extract and Synthesize Requirements from Jira Tickets and PRDs

### 1. Fetch the Jira Ticket (using Jira MCP)

Use the Jira MCP to fetch:
- Main ticket (description, summary, status, assignee, comments)
- **All sub-tasks and child issues** (recursively)
- All comments and attachments across the entire hierarchy
- Extract any **web links** (especially PRD links, Google Drive docs, diagrams)

**MCP Tools:**
- `jira_get_issue` - Fetch main ticket
- `jira_search` - Fetch sub-tasks if needed (use JQL: `parent = <TICKET_ID>`)

### 2. Fetch PRDs (using Google Drive MCP)

If the ticket or comments contain Google Drive links (e.g. PRD documents):
- Fetch them using the GDrive MCP (`read_file`)
- If no PRD is found, state **"No PRD document found in ticket or comments."**
- If a required document is missing or cannot be accessed, **state what information is missing** and the **risks of proceeding without it**.

**MCP Tools:**
- `read_file` - Fetch PRD from Google Drive

### 3. Synthesize the Context Analysis Report

Create a report with **four sections**:

#### (1) PRD / Primary Document Summary
- If PRD exists: summarize the business goal, data flow, acceptance criteria, and any technical constraints.
- If no PRD: state "No PRD found; relying on ticket text only."

#### (2) JIRA Hierarchy Analysis
- **Main Ticket:** Key requirements and decisions from the main ticket description and comments.
- **Sub-Task Breakdown:** A dedicated section listing findings from **each** sub-task. For each sub-task, note:
  - Sub-task key and title
  - Unique requirements, technical notes, or decisions in its description or comments
  - Any attachments or links specific to that sub-task
- If no sub-tasks: state "No sub-tasks; single-ticket scope."

#### (3) Linked Asset Analysis
- Consolidated list of **all files, attachments, and URLs** across the ticket hierarchy.
- For each asset, state its **relevance** (e.g. "PRD defines data contract", "Diagram shows message flow", "Screenshot of expected UI").
- **Linked PR (optional):** If the ticket or comments contain a GitHub PR link (e.g. `https://github.com/.../pull/123`), fetch and analyze it via GitHub MCP (`mcp_github_get_file_contents` with `refs/pull/<N>/head`). Add a **PR Analysis** subsection: architecture, config source, acknowledgment flow, CDR changes. *(Note: PRs are typically created after development; in normal flow no PR exists. This applies when re-implementing, testing, or comparing.)*
- If no links: state **"No supplementary documents found in comments."**

#### (4) Final Synthesized Requirements
- Numbered list of requirements synthesized from all sources (PRD, main ticket, sub-tasks, comments, attachments).
- Highlight any **contradictions** or **ambiguities** between sources.
- State **what is clear** and **what needs clarification** from the user.
- **CDR field mapping:** When user says "CDR has X", "from CDR", "in the CDR we get Y" – identify **which service consumes CDR and updates callhistory** for this feature. Typically: `service-csiq-postcall` consumes CDR; `service-csiq-cdr` produces formatted CDR. Do not assume webhooks or other services – trace to the actual CDR consumer.

### 4. Parse Requirements (Critical Step)

From the Context Analysis Report, **extract**:

**For schema-analyzer:**
- **Entities:** Database tables/collections mentioned (e.g., "contacts", "practices", "agents", "appointments")
- **Keywords:** Look for: "table", "collection", "schema", "database", "DB", "store", "persist", "save to", "query"

**For rabbit-tracer:**
- **Service:** Service name from ticket or file paths (e.g., "service-csiq-cdr", "service-cs-one-api")
- **Exchange:** Exchange name (e.g., "contact_events", "call_events")
- **Routing Key:** Routing key (e.g., "contact.updated", "call.completed")
- **Keywords:** Look for: "RabbitMQ", "queue", "message", "event", "publish", "consume", "exchange", "routing key"

**Store the parsed context for use in parallel subagent invocation.**

### 5. Save Report

Save the Context Analysis Report as:
```
docs/<JIRA_TICKET_ID>/context_analysis_report.md
```

**Purpose:** Reuse in `/plan` and `/finish` commands without re-fetching.

---

## Error Handling

### If Jira MCP Unavailable
1. Check session MCP status from `/init`
2. State **"Jira MCP is unavailable. Cannot fetch ticket."**
3. **Use fallback:** Ask user for ticket details (copy-paste ticket description, comments, sub-tasks)
4. **Proceed with HIGH RISK warning** that requirements may be outdated
5. **Flag:** Ticket context is not verified against live Jira

### If GDrive MCP Unavailable (but PRD link exists)
1. State **"GDrive MCP is unavailable. Cannot fetch PRD. Risks: missing data contract and business flow details."**
2. **Continue with ticket-only context** (state "PRD unavailable; relying on ticket text")
3. **Flag risk:** Data contract and business flow details may be incomplete

---

## Output Format

Return the Context Analysis Report with the four sections above. Use markdown headings. Be concise but thorough. If something is missing or unclear, explicitly call it out.

**Example structure:**
```markdown
# Context Analysis Report - CSIQ-12043

## 1. PRD / Primary Document Summary
[Summary or "No PRD found; relying on ticket text only."]

## 2. JIRA Hierarchy Analysis
### Main Ticket
[Key requirements and decisions]

### Sub-Task Breakdown
[For each sub-task...]

## 3. Linked Asset Analysis
[List of assets with relevance]

## 4. Final Synthesized Requirements
1. [Requirement 1]
2. [Requirement 2]
...

**Ambiguities:**
- [List any unclear or contradictory requirements]

**Needs Clarification:**
- [List what needs user input]
```

---

## Verbosity Control

**When to use summary mode:**
- Quick validation of ticket context
- Token budget is limited

**Summary mode output:**
- **PRD Summary:** 3-5 bullet points only (key goals, constraints)
- **JIRA Hierarchy:** List sub-task titles only, not full descriptions
- **Linked Assets:** Count only (e.g. "3 attachments, 2 links")
- **Requirements:** Top 5-7 requirements only

**Full mode (default):**
- Return complete Context Analysis Report with all details

---

## After This Skill

Once JIRA context is gathered and parsed:

1. **Launch parallel subagents** (if applicable):
   ```javascript
   [
     Task(schema-analyzer, entities: [from parse]),
     Task(rabbit-tracer, service/exchange: [from parse])
   ]
   ```

2. **Continue to discovery skill** for dependency tracing and pattern validation

3. **Synthesize Discovery Report** combining JIRA context + subagent outputs

---

## Architecture Rationale

**Why inline (not a subagent)?**

1. **Dependency:** Schema and RabbitMQ analyzers NEED JIRA context to know what to analyze
2. **No true parallelism:** Running JIRA as a subagent would cause main agent to sit idle waiting for context
3. **Performance:** Inline execution eliminates subagent overhead (~10% faster)
4. **Honesty:** JIRA context is the INPUT to discovery, not a parallel analysis task

**Result:** True parallelism for schema-analyzer and rabbit-tracer (both run simultaneously with correct context from JIRA).

---

## Usage Example

```
User: /start implement contact preferred method for CSIQ-12043

Main Agent:
  1. [Invokes jira-context-analysis skill]
     - Fetches JIRA-12043 using Jira MCP
     - Fetches PRD from GDrive (if linked)
     - Synthesizes Context Analysis Report
     - Parses: entities = ["contacts"], service = "service-cs-one-api"
     - Saves: docs/CSIQ-12043/context_analysis_report.md
  
  2. [Launches parallel subagents with parsed context]
     [
       Task(schema-analyzer, entities: ["contacts"]),
       Task(rabbit-tracer, service: "service-cs-one-api") ← only if RabbitMQ mentioned
     ]
  
  3. [Continues to discovery skill]
```
