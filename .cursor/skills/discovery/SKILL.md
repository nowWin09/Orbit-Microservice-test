---
name: discovery
description: Trace dependencies, identify patterns, verify infrastructure. Main agent inline procedure during /start. Uses outputs from schema-analyzer and rabbit-tracer subagents.
disable-model-invocation: false
---

# Discovery Skill

Main agent procedure for analyzing codebase dependencies and patterns. Used inline during `/start` command after JIRA context and parallel analysis complete.

**Input:** JIRA context + schema analysis + RabbitMQ flow (from earlier steps)  
**Output:** Discovery Report

## Steps

1. **Trace Dependencies** – If modifying an existing module, trace the API route to its controller, services, and repositories to map all dependencies. Find all variations (V1, V2; Agent, Practice, Admin). Identify 2–3 existing patterns (validation, error handling). Verify shared `Library/` modules and `Constants.js` mappings. Check if changes are needed to `pm2.json` or `.env.example`.

2. **Live Schema Check (MCP)** – **Delegate to `schema-analyzer` subagent** for comprehensive schema analysis:
   - **Invocation (with model optimization):** 
     ```javascript
     Task(
       subagent_type="generalPurpose",
       model="fast",  // Schema fetching is mechanical, use fast model
       prompt="Read and execute .cursor/agents/schema-analyzer.md for entities: <list tables/collections>. Compare with code models at: <list model file paths>. Verbosity: full",
       description="Analyze DB schemas"
     )
     ```
   - The subagent will query MariaDB/MongoDB MCPs for actual schemas, compare with code models, and return schema comparison + index recommendations.
   - If subagent is unavailable or MCP is down, STOP and ask for schema definition. **Schema over guessing:** never invent field names.

3. **Data Architecture Analysis** – If the task involves database changes: use the output from `schema-analyzer` subagent (step 2). Additionally, run **Database Selection Analysis** (Tenancy Check, Aggregate Volume Estimation, Multi-Tenancy Volume Rule, Final Selection). If the feature involves multi-step state (e.g., draft → pending → processed), apply Atomic State Management and plan for `Constants.js` enums and atomic repository methods.

4. **CDR Pipeline Trace (MANDATORY for telecom/voicemail features)** – If the task involves any of: "voicemail", "CDR", "playback", "retry", "DTMF", "acknowledge", "call history":
   - **Trace:** Bifrost → `service-csiq-cdr` (format-normal-cdr, format-parent-cdr) → `service-csiq-postcall`
   - **Identify:** Which service consumes CDR and updates callhistory for this feature
   - **Document in Discovery Report:** "CDR Consumer Analysis" section with: consumer file, payload fields, update logic, parent-child call relationship (if playback/retry calls produce separate CDRs)
   - **CRITICAL:** When user says "CDR has X" or "from CDR" – map to the actual CDR consumer (typically postcall), not webhooks or other services.

5. **Workflow Config Trace (MANDATORY for workflow actions)** – If the task involves "workflow action", "retry", "playback", "workflow config":
   - **Trace:** `Library/Workflow/WorkflowController.js` → `getActionConfig` → workflow/action schema in DB
   - **Identify:** Where config lives – `action.isRetryEnabled`, `action.maxRetries`, `action.retryInterval`, `playbackParams`, or `Constants.js`
   - **Document in Discovery Report:** "Config Source" section – where does retry/config live (DB, params, Constants)?

6. **Schema Verification (when user mentions field names)** – If user specifies field names (e.g. "voicemailAcknowledged", "voicemailPlaybackAcknowledgment"):
   - **Use DB MCP:** `mcp_MongoDB-MCP-Server_collection-schema` for callhistory (or relevant collection)
   - **Compare:** User-provided field names vs actual schema
   - **Flag mismatches** in Context Analysis Report and Discovery Report (e.g. "User said 'voicemailAcknowledged' but schema has 'voicemailPlaybackAcknowledgment' – verify intended field")

7. **Cross-Service / RabbitMQ (if applicable)** – If the task touches RabbitMQ or message flow between services, **delegate to `rabbit-tracer` subagent**:
   
   **Note:** JIRA context should already be gathered inline by the main agent (see `/start` command). Use parsed context (service, exchange, routing key) to invoke rabbit-tracer.
   
   ```javascript
   Task(
     subagent_type="generalPurpose",
     model="fast",
     prompt="Read and execute .cursor/agents/rabbit-tracer.md. 
             Service: <service from JIRA parse>. 
             Exchange: <exchange from JIRA parse>. 
             Routing Key: <routing key from JIRA parse>. 
             Ticket: <TICKET_ID>. 
             Verbosity: full",
     description="Trace RabbitMQ flow"
   )
   ```
   
   **Can run in parallel with schema-analyzer** if both are needed:
   ```javascript
   [
     Task(subagent_type="generalPurpose", model="fast", prompt="...schema-analyzer... for entities: <from JIRA>", description="Analyze DB schemas"),
     Task(subagent_type="generalPurpose", model="fast", prompt="...rabbit-tracer... Service: <from JIRA>", description="Trace RabbitMQ flow")
   ]
   ```
   
   **Performance Impact:** Schema and RabbitMQ analysis run in parallel (true parallelism) after JIRA context is available.
   
   - The message-flow skill can also be used for manual analysis if subagents are unavailable.

## Discovery Report Contents

- Mandatory Database Selection Analysis (if applicable).
- **If telecom/voicemail (CDR, playback, retry, DTMF):** CDR Consumer Analysis – which service consumes CDR and updates callhistory; consumer file, payload fields, update logic; parent-child call relationship if applicable.
- **If workflow actions:** Config Source – where does retry/config live (WorkflowController, action schema, playbackParams, Constants)?
- **If linked PR exists:** Include PR Analysis section (architecture, config source, acknowledgment flow, CDR changes). If PR exists but was not analyzed in Context Analysis, do not proceed – first fetch and analyze the PR.
- **If RabbitMQ/cross-service:** Message flow (producer → exchange/routing key/queue → consumer), schema/contract alignment, any mismatches or missing consumer logic.
- **Schema Change Workflow (Laravel):** If the task involves **any** schema change (MariaDB table/column, MongoDB collection/field), you MUST explicitly ask the user: **"Have the necessary Laravel migrations and seeders already been created in the repository?"** If the user answers **NO**, you MUST generate the necessary PHP code for them. **Output location:** create these files in: **`laravel_files/<JIRA_TICKET_ID>/migrations/`** and **`laravel_files/<JIRA_TICKET_ID>/seeders/`** (do not pollute the main codebase during drafting).
- Complete list of files to be modified.
- Summary of established patterns your solution will follow.
- Risk assessment if implementation is partial.

After presenting the report, ask for and receive **explicit user confirmation** before proceeding to the TDD Blueprint.
