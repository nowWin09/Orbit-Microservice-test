# Project Orbit - Troubleshooting Matrix

**Purpose:** Comprehensive troubleshooting guide for Project Orbit workflow. Maps symptoms → root causes → fixes → responsible files.  
**Last Updated:** February 19, 2026  
**Scope:** Applies to all `/start`, `/plan`, `/finish` commands and subagent execution.

---

## Quick Navigation by Symptom

| If You See... | Jump To... |
|---|---|
| "Cannot fetch ticket" | [Issue 1.1](#11-jira-context-issues) |
| Schema analysis failed | [Issue 2.2](#2-schema-analysis-issues) |
| Missing consumer found | [Issue 3.1](#3-rabbitmq-flow-issues) |
| Tests only cover happy path | [Issue 5.1](#5-tdd-blueprint-issues) |
| Breaking change not detected | [Issue 6.1](#6-risk-analysis-issues) |
| N+1 query in code | [Issue 7.1](#7-code-review-issues) |
| Commands too slow | [Issue 14.1](#14-performance-issues) |
| MCP unavailable | [Issue 11.1](#11-mcp-connection-issues) |

---

## How to Use This Guide

1. **Identify the symptom** - What went wrong?
2. **Find the category** - Which workflow step?
3. **Check responsible files** - Which prompts are the culprit?
4. **Apply the fix** - How to correct the issue?

---

## Issue Categories

- [1. JIRA Context Issues](#1-jira-context-issues)
- [2. Schema Analysis Issues](#2-schema-analysis-issues)
- [3. RabbitMQ Flow Issues](#3-rabbitmq-flow-issues)
- [4. Discovery Issues](#4-discovery-issues)
- [5. TDD Blueprint Issues](#5-tdd-blueprint-issues)
- [6. Risk Analysis Issues](#6-risk-analysis-issues)
- [7. Code Review Issues](#7-code-review-issues)
- [8. Test Validation Issues](#8-test-validation-issues)
- [9. Regression Detection Issues](#9-regression-detection-issues)
- [10. Parallel Execution Issues](#10-parallel-execution-issues)
- [11. MCP Connection Issues](#11-mcp-connection-issues)
- [12. Caching Issues](#12-caching-issues)
- [13. Pattern Detection Issues](#13-pattern-detection-issues)
- [14. Performance Issues](#14-performance-issues)
- [15. Architectural Issues](#15-architectural-issues)

---

## 1. JIRA Context Issues

### Issue 1.1: AI Can't Find JIRA Ticket

**Symptom:** "Cannot fetch ticket CSIQ-12043"

**Workflow Step:** `/start` command, Phase 1 (JIRA context)

**Root Cause:** 
- Jira MCP unavailable
- Ticket ID incorrect
- Missing Jira permissions

**Responsible Files:**
- `.cursor/skills/jira-context-analysis/SKILL.md` - Main procedure
- `.cursor/commands/init.md` - MCP connectivity check
- `.cursor/rules/mcp_usage.mdc` - MCP error handling rules

**Fix:**
1. Run `/init` to check MCP status
2. Verify ticket ID is correct (e.g., "CSIQ-12043" not "12043")
3. Check Jira MCP server configuration
4. Use fallback: Ask user for ticket details manually

---

### Issue 1.2: AI Doesn't Parse Entities/Service from Ticket

**Symptom:** Schema-analyzer or rabbit-tracer invoked with empty/wrong entities

**Workflow Step:** `/start` command, Phase 1 (JIRA context parsing)

**Root Cause:**
- Entities/service not mentioned in ticket
- AI didn't extract keywords correctly
- Parsing logic incomplete

**Responsible Files:**
- `.cursor/skills/jira-context-analysis/SKILL.md` - Parsing instructions (Step 4)
- `.cursor/commands/start.md` - Phase 1 parsing requirements

**Fix:**
1. Check if ticket mentions entities (tables, collections, DB)
2. Enhance parsing keywords in SKILL.md:
   - Add more keywords: "model", "data", "record", etc.
3. Manually specify entities if AI misses them

---

### Issue 1.3: AI Doesn't Fetch PRD from Google Drive

**Symptom:** "No PRD found" but PRD link exists in ticket

**Workflow Step:** `/start` command, Phase 1 (PRD fetch)

**Root Cause:**
- GDrive MCP unavailable
- PRD link not recognized (not in standard format)
- Link in attachment, not comment

**Responsible Files:**
- `.cursor/skills/jira-context-analysis/SKILL.md` - PRD fetch logic (Step 2)
- `.cursor/rules/mcp_usage.mdc` - GDrive error handling

**Fix:**
1. Check if GDrive MCP is available (`/init`)
2. Verify link format (should be `https://docs.google.com/...` or `https://drive.google.com/...`)
3. Use fallback: Ask user to copy-paste PRD content
4. Check if link is in attachment (AI may not parse attachments)

---

### Issue 1.4: Context Analysis Report Missing Sub-Tasks

**Symptom:** Report doesn't include sub-task details

**Workflow Step:** `/start` command, Phase 1 (JIRA hierarchy analysis)

**Root Cause:**
- AI didn't use `jira_search` to fetch sub-tasks
- Sub-tasks exist but not linked correctly
- JQL query incorrect

**Responsible Files:**
- `.cursor/skills/jira-context-analysis/SKILL.md` - Sub-task fetch (Step 1)
- `.cursor/rules/mcp_usage.mdc` - Jira MCP usage

**Fix:**
1. Enhance SKILL.md to explicitly use JQL: `parent = <TICKET_ID>`
2. Verify sub-tasks exist in Jira
3. Check if AI used `jira_search` tool

---

## 2. Schema Analysis Issues

### Issue 2.1: Schema-Analyzer Invoked with Wrong Entities

**Symptom:** Schema analysis for wrong tables/collections

**Workflow Step:** `/start` command, Phase 2 (parallel analysis)

**Root Cause:**
- JIRA context parsing failed (see Issue 1.2)
- Entities not extracted correctly from ticket

**Responsible Files:**
- `.cursor/skills/jira-context-analysis/SKILL.md` - Parsing logic (Step 4)
- `.cursor/commands/start.md` - Phase 2 invocation

**Fix:**
1. Verify JIRA parsing extracted correct entities
2. Manually specify entities in `/start` invocation
3. Enhance parsing keywords in jira-context-analysis SKILL

---

### Issue 2.2: Schema-Analyzer Returns "DB MCP Unavailable"

**Symptom:** Cannot verify schema against live DB

**Workflow Step:** `/start` command, Phase 2 (schema analysis)

**Root Cause:**
- MariaDB or MongoDB MCP down
- Connection timeout
- Missing permissions

**Responsible Files:**
- `.cursor/agents/schema-analyzer.md` - MCP usage and fallback (Fallback Strategy section)
- `.cursor/commands/init.md` - MCP connectivity check
- `.cursor/rules/troubleshooting.mdc` - DB MCP troubleshooting

**Fix:**
1. Run `/init` to check MCP status
2. Use fallback: Ask user for schema dump
3. Or proceed with code models only (HIGH RISK, requires approval)
4. Check MCP server logs

---

### Issue 2.3: Missing Index Recommendations

**Symptom:** Schema analysis doesn't suggest indexes for new queries

**Workflow Step:** `/start` command, Phase 2 (schema analysis)

**Root Cause:**
- Query patterns not identified
- Universal Indexing Framework not applied
- Discovery Report doesn't mention query patterns

**Responsible Files:**
- `.cursor/agents/schema-analyzer.md` - Index recommendation logic (Step 5)
- `.cursor/rules/db_rules.mdc` - Universal Indexing Framework

**Fix:**
1. Ensure Discovery Report mentions query patterns (WHERE clauses)
2. Verify schema-analyzer applies Universal Indexing Framework
3. Check if 2+ criteria met: query >100/day, scan >10K rows, response >200ms, user-facing

---

### Issue 2.4: Schema Comparison Shows False Mismatches

**Symptom:** AI reports fields in DB but not in code (but they exist)

**Workflow Step:** `/start` command, Phase 2 (schema analysis)

**Root Cause:**
- Code model paths incorrect
- AI didn't read model files
- Model files in different location

**Responsible Files:**
- `.cursor/agents/schema-analyzer.md` - Model comparison (Step 4)
- `.cursor/commands/start.md` - Model paths in invocation

**Fix:**
1. Verify model file paths are correct in invocation
2. Check if model files exist at specified paths
3. Manually specify model paths if AI can't find them

---

## 3. RabbitMQ Flow Issues

### Issue 3.1: Rabbit-Tracer Can't Find Consumer

**Symptom:** "Consumer not found for exchange X / routing key Y"

**Workflow Step:** `/start` command, Phase 2 (RabbitMQ flow analysis)

**Root Cause:**
- Consumer doesn't exist (feature not implemented)
- Consumer in different service (codebase search missed it)
- Exchange/routing key incorrect

**Responsible Files:**
- `.cursor/agents/rabbit-tracer.md` - Search logic (Step 2)
- `.cursor/rules/cross_service.mdc` - Service map reference
- `.cursor/rules/generated/service_map.mdc` - Service list

**Fix:**
1. Check service map for related services
2. Expand search to `.env.example`, `pm2.json`, `Library/RabbitMQ/`
3. Ask user if consumer exists or is planned
4. Verify exchange/routing key is correct

---

### Issue 3.2: Payload Contract Mismatch Not Detected

**Symptom:** Producer/consumer payload mismatch exists but AI doesn't report it

**Workflow Step:** `/start` command, Phase 2 (RabbitMQ flow analysis)

**Root Cause:**
- AI didn't extract payload from producer/consumer code correctly
- No Joi schema in consumer (uses loose validation)
- Payload comparison logic incomplete

**Responsible Files:**
- `.cursor/agents/rabbit-tracer.md` - Payload comparison (Step 4)
- `.cursor/rules/cross_service.mdc` - Contract verification rules

**Fix:**
1. Verify rabbit-tracer extracts producer payload correctly
2. Check consumer has Joi schema or DTO
3. Manually review producer/consumer code for mismatches
4. Enhance rabbit-tracer payload extraction logic

---

### Issue 3.3: AI Doesn't Use DB MCP to Verify Payload Against Schema

**Symptom:** Payload fields don't match DB schema but AI doesn't catch it

**Workflow Step:** `/start` command, Phase 2 (RabbitMQ flow analysis)

**Root Cause:**
- Rabbit-tracer didn't query DB MCP
- DB entity not identified from payload
- MCP unavailable

**Responsible Files:**
- `.cursor/agents/rabbit-tracer.md` - DB MCP usage (Step 5)
- `.cursor/rules/cross_service.mdc` - Schema verification

**Fix:**
1. Verify rabbit-tracer identifies DB entities in payload
2. Check if DB MCP is available
3. Use fallback: Compare with code models
4. Enhance rabbit-tracer to always check DB schema for payloads

---

## 4. Discovery Issues

### Issue 4.1: Discovery Doesn't Trace Dependencies

**Symptom:** Discovery Report missing files to modify or dependencies

**Workflow Step:** `/start` command, Discovery phase

**Root Cause:**
- Discovery skill not invoked
- Semantic search didn't find related files
- Patterns not identified

**Responsible Files:**
- `.cursor/skills/discovery/SKILL.md` - Dependency tracing (Step 1)
- `.cursor/commands/start.md` - Discovery invocation

**Fix:**
1. Verify discovery skill is invoked after context analysis
2. Manually search for related files (controllers, services, repositories)
3. Enhance discovery skill with better search patterns

---

### Issue 4.2: AI Doesn't Check pm2.json or .env.example

**Symptom:** New service/config not added to pm2.json

**Workflow Step:** `/start` command, Discovery phase

**Root Cause:**
- Discovery skill doesn't mention pm2.json check
- AI forgot this step

**Responsible Files:**
- `.cursor/skills/discovery/SKILL.md` - Infrastructure check (Step 1)
- `.cursor/rules/tech_stack.mdc` - PM2 requirements

**Fix:**
1. Enhance discovery skill to explicitly check pm2.json and .env.example
2. Add checklist item for infrastructure files
3. Remind AI in start.md to verify pm2.json

---

### Issue 4.3: Discovery Report Doesn't Mention Existing Patterns

**Symptom:** Implementation doesn't follow existing patterns

**Workflow Step:** `/start` command, Discovery phase

**Root Cause:**
- Discovery didn't find 2-3 existing examples
- Patterns not documented
- Search didn't find similar features

**Responsible Files:**
- `.cursor/skills/discovery/SKILL.md` - Pattern identification (Step 1)
- `.cursor/rules/microservice_rules.mdc` - "NEVER Generate Code Blindly" rule

**Fix:**
1. Explicitly search for similar features (2-3 examples)
2. Document patterns found
3. Reference patterns in Discovery Report

---

## 5. TDD Blueprint Issues

### Issue 5.1: TDD Blueprint Missing Edge Case Tests

**Symptom:** Tests only cover happy path

**Workflow Step:** `/plan` command, TDD planning

**Root Cause:**
- tdd-planner subagent didn't design edge case tests
- Requirements don't mention edge cases
- AI focused only on primary flow

**Responsible Files:**
- `.cursor/agents/tdd-planner.md` - Test design (Step 2)
- `.cursor/skills/tdd-planning/SKILL.md` - Completeness checklist

**Fix:**
1. Apply TDD Blueprint Completeness Checklist (in tdd-planning SKILL)
2. Verify edge case tests are included
3. Manually add edge case tests if missing

---

### Issue 5.2: TDD Blueprint Doesn't Map Requirements to Tests

**Symptom:** No coverage map showing which tests validate which requirements

**Workflow Step:** `/plan` command, TDD planning

**Root Cause:**
- tdd-planner didn't create coverage map
- Output format incomplete

**Responsible Files:**
- `.cursor/agents/tdd-planner.md` - Coverage mapping (Step 3)
- `.cursor/skills/tdd-planning/SKILL.md` - Output requirements

**Fix:**
1. Verify tdd-planner creates Coverage Map section
2. Manually create coverage map: Requirement 1 → Test A, B
3. Reject TDD Blueprint if coverage map missing

---

### Issue 5.3: Tests Don't Check for N+1 Queries

**Symptom:** Implementation has N+1 but tests don't catch it

**Workflow Step:** `/plan` command, TDD planning

**Root Cause:**
- TDD Blueprint doesn't include performance tests
- Core Compliance Checklist not applied

**Responsible Files:**
- `.cursor/agents/tdd-planner.md` - Compliance verification (Step 3)
- `.cursor/rules/db_rules.mdc` - N+1 prevention
- `.cursor/skills/tdd-planning/SKILL.md` - Completeness checklist (performance tests)

**Fix:**
1. Apply TDD Blueprint Completeness Checklist
2. Add performance tests to verify batch queries (not loops)
3. Test with realistic data volume (not just 1-2 records)

---

## 6. Risk Analysis Issues

### Issue 6.1: Risk Analysis Doesn't Flag Breaking Changes

**Symptom:** Breaking change deployed, but risk report was Green

**Workflow Step:** `/plan` command, Risk analysis

**Root Cause:**
- risk-analyzer didn't identify breaking change
- No API contract analysis
- DB schema change not flagged

**Responsible Files:**
- `.cursor/agents/risk-analyzer.md` - Breaking change analysis (Step 2)
- `.cursor/commands/plan.md` - Risk analyzer invocation

**Fix:**
1. Verify risk-analyzer checks:
   - API contract changes (new required fields, removed fields, type changes)
   - DB schema changes (dropped columns, altered types, new NOT NULL)
   - Message payload changes
2. Manually review for breaking changes
3. Enhance risk-analyzer logic for contract analysis

---

### Issue 6.2: Risk Report Missing Performance Impact

**Symptom:** Performance degradation not predicted in risk report

**Workflow Step:** `/plan` command, Risk analysis

**Root Cause:**
- risk-analyzer didn't check for missing indexes
- No query performance analysis
- schema-analyzer output not used

**Responsible Files:**
- `.cursor/agents/risk-analyzer.md` - Performance risks (Step 2)
- `.cursor/rules/db_rules.mdc` - Performance rules

**Fix:**
1. Verify risk-analyzer uses schema-analyzer output for index recommendations
2. Check for N+1 queries in TDD Blueprint
3. Predict data volume impact

---

### Issue 6.3: Risk Report Is Always Green (Never Red/Yellow)

**Symptom:** Risk analyzer too lenient, doesn't flag real risks

**Workflow Step:** `/plan` command, Risk analysis

**Root Cause:**
- Severity ratings too low
- Mitigation strategies assumed too easily
- No critical risks detected

**Responsible Files:**
- `.cursor/agents/risk-analyzer.md` - Severity ratings (Step 3)
- `.cursor/rules/microservice_rules.mdc` - "NEVER" rules

**Fix:**
1. Review severity criteria (P0, P1, P2, P3)
2. P0 = production outage, data loss, security breach, HIPAA violation
3. Flag schema changes without DB MCP verification as P0
4. Set readiness to Red if any P0 exists

---

## 7. Code Review Issues

### Issue 7.1: Code Reviewer Doesn't Catch N+1 Queries

**Symptom:** N+1 query in implementation but review passed

**Workflow Step:** `/finish` command, Code review

**Root Cause:**
- code-reviewer didn't search for loops with queries
- N+1 pattern not recognized
- Review logic incomplete

**Responsible Files:**
- `.cursor/agents/code-reviewer.md` - N+1 detection (Step 3, Rejection Criteria)
- `.cursor/rules/db_rules.mdc` - N+1 rules

**Fix:**
1. Verify code-reviewer searches for:
   - `for (const x of items) { await repo.find(...) }`
   - `.map()` or `.forEach()` with async DB calls
2. Manual review for N+1 patterns
3. Enhance code-reviewer regex patterns for N+1

---

### Issue 7.2: Missing Joi Validation Not Detected

**Symptom:** Controller doesn't validate req.body but review passed

**Workflow Step:** `/finish` command, Code review

**Root Cause:**
- code-reviewer didn't check validation
- Controller pattern not followed
- Rejection criteria not applied

**Responsible Files:**
- `.cursor/agents/code-reviewer.md` - Joi validation check (Step 3, Rejection Criteria)
- `.cursor/rules/tech_stack.mdc` - Joi validation mandatory

**Fix:**
1. Verify code-reviewer checks ALL controllers for Joi validation
2. Fail review if req.body, req.query, req.params not validated
3. Check RabbitMQ consumers for message validation

---

### Issue 7.3: HIPAA Compliance Issue Not Flagged

**Symptom:** PHI logged to console but review passed

**Workflow Step:** `/finish` command, Code review

**Root Cause:**
- code-reviewer didn't check for PHI in logs
- HIPAA compliance check skipped
- AI doesn't recognize PHI

**Responsible Files:**
- `.cursor/agents/code-reviewer.md` - HIPAA compliance (Step 4)
- `.cursor/rules/microservice_rules.mdc` - HIPAA rules

**Fix:**
1. Verify code-reviewer searches for `console.log`, `logger.info` with user data
2. Check for PHI fields: email, phone, name, address, DOB, SSN
3. Fail review if PHI in logs
4. Require redaction or removal

---

## 8. Test Validation Issues

### Issue 8.1: Tests Exist But Don't Actually Test Anything

**Symptom:** Weak tests with meaningless assertions (e.g., `expect(result).toBeDefined()`)

**Workflow Step:** `/finish` command, Test validation

**Root Cause:**
- test-validator didn't check assertion quality
- Tests are stubs
- Coverage metrics misleading

**Responsible Files:**
- `.cursor/agents/test-validator.md` - Test quality assessment (Step 4)
- `.cursor/skills/review/SKILL.md` - Test validator invocation

**Fix:**
1. Verify test-validator checks assertion strength
2. Flag weak assertions (`.toBeDefined()`, `.toBeTruthy()`)
3. Require meaningful assertions (`.toBe(expected)`, `.toHaveLength(2)`)
4. Examples in test-validator.md (lines 38-52)

---

### Issue 8.2: Missing Tests Not Detected

**Symptom:** New function has no test but validation passed

**Workflow Step:** `/finish` command, Test validation

**Root Cause:**
- test-validator didn't verify all functions have tests
- Test existence check incomplete

**Responsible Files:**
- `.cursor/agents/test-validator.md` - Test existence (Step 2)
- `.cursor/skills/tdd-planning/SKILL.md` - TDD Blueprint compliance

**Fix:**
1. Verify test-validator compares TDD Blueprint with actual tests
2. List missing tests
3. Fail validation if any function without test

---

### Issue 8.3: Test Coverage Below 80% But Validation Passed

**Symptom:** Coverage report shows 60% but test-validator returned PASS

**Workflow Step:** `/finish` command, Test validation

**Root Cause:**
- test-validator didn't check coverage metrics
- Coverage report not available
- Threshold not enforced

**Responsible Files:**
- `.cursor/agents/test-validator.md` - Coverage analysis (Step 5)
- `.cursor/rules/microservice_rules.mdc` - TDD requirements

**Fix:**
1. Verify test-validator checks line/branch/function coverage
2. Target: 80%+ coverage for new code
3. Fail validation if below threshold
4. Run `npm test -- --coverage` to get metrics

---

## 9. Regression Detection Issues

### Issue 9.1: Dependent Code Not Found

**Symptom:** Change broke other features but regression-detector didn't find them

**Workflow Step:** `/finish` command, Regression detection

**Root Cause:**
- Codebase search didn't find dependencies
- Indirect dependencies missed (DB schema, API contracts)
- Search patterns incomplete

**Responsible Files:**
- `.cursor/agents/regression-detector.md` - Dependency analysis (Step 2)
- `.cursor/skills/sentinel/SKILL.md` - Regression detector invocation

**Fix:**
1. Verify regression-detector searches for:
   - Direct: function calls, imports, inheritance
   - Indirect: DB columns, API fields, constants, message payloads
2. Expand search to related services
3. Use semantic search for complex dependencies

---

### Issue 9.2: Risk Assessment Too Low

**Symptom:** High-risk change marked as "Low impact"

**Workflow Step:** `/finish` command, Regression detection

**Root Cause:**
- Impact assessment logic too lenient
- Severity ratings incorrect
- User-facing features not prioritized

**Responsible Files:**
- `.cursor/agents/regression-detector.md` - Impact assessment (Step 3)

**Fix:**
1. Review impact criteria:
   - No impact: Optional field added
   - Low impact: Missing new field in response (suboptimal)
   - High impact: Removed required field, changed types
2. Prioritize user-facing features (API endpoints, message flow)
3. Flag breaking changes as high risk

---

### Issue 9.3: No Regression Tests Recommended

**Symptom:** Regression-detector found dependencies but didn't recommend tests

**Workflow Step:** `/finish` command, Regression detection

**Root Cause:**
- Existing test coverage assumed sufficient
- Test recommendation logic incomplete

**Responsible Files:**
- `.cursor/agents/regression-detector.md` - Test recommendations (Step 5)

**Fix:**
1. Verify regression-detector recommends tests for ALL high-risk dependencies
2. Check if existing tests cover dependent code
3. Add regression tests even if existing tests exist (belt & suspenders)

---

## 10. Parallel Execution Issues

### Issue 10.1: Subagents Run Sequentially (Not in Parallel)

**Symptom:** Commands take 2x longer than expected

**Workflow Step:** `/start`, `/plan`, `/finish` commands

**Root Cause:**
- AI invoked subagents sequentially (one Task → wait → another Task)
- Not following parallel execution guidance
- Multiple messages instead of single message with multiple Tasks

**Responsible Files:**
- `.cursor/commands/start.md` - Parallel execution examples
- `.cursor/commands/plan.md` - Parallel execution examples
- `.cursor/commands/finish.md` - Parallel execution examples
- `.cursor/agents/README.md` - Parallel execution best practices

**Fix:**
1. Verify AI uses single message with multiple Task calls:
   ```javascript
   [
     Task(...subagent1...),
     Task(...subagent2...)
   ]
   ```
2. NOT sequential:
   ```javascript
   Task(...subagent1...) → wait → Task(...subagent2...)
   ```
3. Review command files for CORRECT examples
4. Emphasize "CRITICAL: parallel execution" in prompts

---

### Issue 10.2: Wrong Model Selected for Subagent

**Symptom:** Mechanical subagent uses default model (expensive)

**Workflow Step:** `/start` or `/plan` commands

**Root Cause:**
- AI didn't specify `model: "fast"` for mechanical tasks
- Model selection guidance not followed

**Responsible Files:**
- `.cursor/commands/start.md` - Model selection in invocations
- `.cursor/agents/README.md` - Model selection guidance

**Fix:**
1. Verify mechanical subagents use `model: "fast"`:
   - schema-analyzer
   - rabbit-tracer
2. Reasoning subagents use `model: "default"`:
   - tdd-planner
   - risk-analyzer
   - code-reviewer
   - test-validator
   - regression-detector
3. Add model selection to all command examples

---

## 11. MCP Connection Issues

### Issue 11.1: MCP Down But AI Didn't Use Fallback

**Symptom:** "MCP unavailable" error and execution stopped

**Workflow Step:** Any step using MCPs

**Root Cause:**
- Fallback strategy not applied
- AI stopped instead of using fallback

**Responsible Files:**
- `.cursor/commands/init.md` - MCP caching
- `.cursor/skills/jira-context-analysis/SKILL.md` - Fallback strategies
- `.cursor/agents/schema-analyzer.md` - Fallback strategies
- `.cursor/agents/rabbit-tracer.md` - Fallback strategies
- `.cursor/rules/mcp_usage.mdc` - Error handling

**Fix:**
1. Verify AI checks session MCP status (from `/init`)
2. If MCP unavailable, use fallback:
   - Ask user for manual input
   - Use code models only (HIGH RISK, requires approval)
   - Stop and wait for MCP (default)
3. Enhance fallback sections in all relevant files

---

### Issue 11.2: Session MCP Status Not Cached

**Symptom:** Repeated MCP connection attempts after `/init`

**Workflow Step:** `/init` command

**Root Cause:**
- Init didn't cache MCP status
- Subagents don't check cached status

**Responsible Files:**
- `.cursor/commands/init.md` - MCP caching (Step 2)
- All subagent files - Should check cached status

**Fix:**
1. Verify `/init` creates session MCP status cache
2. Verify subagents check cache before MCP calls
3. Add explicit cache format in init.md

---

### Issue 11.3: MariaDB MCP – Request Timed Out / Connection Failures

**Symptom (from Cursor MCP logs):**
- `MCP error -32001: Request timed out`
- `Error connecting to streamableHttp server, falling back to SSE`
- `Client error for command This operation was aborted`
- `No stored tokens found`

**Workflow Step:** Any step that uses MariaDB MCP (e.g. `/init` MCP check, schema-analyzer, discovery).

**Root Causes (most likely first):**

| Cause | What to check |
|-------|----------------|
| **1. MariaDB server unreachable** | MariaDB not running; wrong host/port in MCP config; firewall or VPN blocking (e.g. DB only on internal network). |
| **2. MCP server startup / config** | MariaDB MCP server not running or crashing; wrong connection string in Cursor MCP config (e.g. `connectionString` or env vars). |
| **3. Connection timeout too short** | DB or network slow; first connection or cold start exceeds Cursor/MCP timeout → streamableHttp times out, then fallback to SSE can also abort. |
| **4. Auth / credentials** | Wrong user/password in MCP config; MariaDB not allowing remote user; "No stored tokens found" can indicate missing or invalid auth. |
| **5. Client closed / operation aborted** | User cancelled; Cursor closed the command; or timeout/abort cascaded from the initial timeout. |
| **6. SSL/TLS mismatch** | Connection string uses `ssl: true` but server has no SSL, or the opposite; certificate errors. |
| **7. Cursor MCP client bug** | Rare; try restarting Cursor or updating; try different transport (SSE vs streamableHttp) if config allows. |

**Fix (in order):**
1. **Verify MariaDB is reachable** from the machine running Cursor: e.g. `mysql -h <host> -P <port> -u <user> -p` (or your DB client). If this fails, fix network/firewall/DB first.
2. **Check MCP config** (Cursor settings → MCP → MariaDB): correct host, port, user, password, database; connection string or env vars (e.g. `MARIADB_CONNECTION_STRING` or `MARIADB_HOST`, etc.).
3. **Increase timeouts** if your DB or network is slow: in MCP server config or Cursor, if there is a timeout option, raise it so the first connection can complete.
4. **Restart MariaDB MCP server** (and Cursor if needed) after config changes.
5. **Run `/init` again** to refresh MCP status; if MariaDB MCP is still failing, Orbit will cache "MariaDB MCP: ❌" and use fallbacks (manual input / HIGH RISK) until the MCP is fixed.

**Responsible Files (for Orbit behavior when MariaDB MCP is down):**
- `.cursor/commands/init.md` - MCP connectivity check and cache
- `.cursor/agents/schema-analyzer.md` - Fallback when DB MCP unavailable
- `.cursor/rules/db_rules.mdc` - "Database MCP unavailable" protocol
- `.cursor/rules/troubleshooting.mdc` - MCP startup fixes

---

## 12. Caching Issues

### Issue 12.1: Reports Not Cached

**Symptom:** `/plan` re-fetches JIRA context instead of using cache

**Workflow Step:** `/plan` command

**Root Cause:**
- Cache file path incorrect
- AI didn't check for cached reports
- Cache file doesn't exist

**Responsible Files:**
- `.cursor/commands/start.md` - Cache saving (Step 5)
- `.cursor/commands/plan.md` - Cache reuse (Step 1)

**Fix:**
1. Verify `/start` saves reports to `docs/<TICKET_ID>/`
2. Verify `/plan` checks for cached reports before re-running
3. Cache file naming convention: `context_analysis_report.md`, `schema_analysis_report.md`, etc.

---

### Issue 12.2: Stale Cached Reports Used

**Symptom:** Old data from previous run used instead of fresh data

**Workflow Step:** Any command using cached reports

**Root Cause:**
- Cache not invalidated
- No timestamp check
- Different ticket but same cache file

**Responsible Files:**
- All commands that use caching

**Fix:**
1. Cache files are per-ticket (`docs/<TICKET_ID>/`)
2. If ticket ID different, cache won't be reused
3. If re-running same ticket, delete `docs/<TICKET_ID>/` first
4. Add timestamp to cached reports for freshness check

---

## 13. Pattern Detection Issues

### Issue 13.1: New Pattern Not Detected by Sentinel

**Symptom:** New RabbitMQ exchange added but rulebook not updated

**Workflow Step:** `/finish` command, Sentinel

**Root Cause:**
- Pattern detection criteria not applied
- AI didn't recognize pattern as "new"
- Auto-detection logic incomplete

**Responsible Files:**
- `.cursor/skills/sentinel/SKILL.md` - Pattern detection criteria (Step 2)
- `.cursor/commands/finish.md` - Sentinel invocation

**Fix:**
1. Apply pattern detection criteria (16 criteria in sentinel SKILL)
2. Verify AI checks for:
   - New external library/framework
   - New architectural pattern
   - New cross-service integration
   - New workflow state
   - New business rule
3. Manual review for new patterns
4. Propose rule addition to user

---

### Issue 13.2: Rulebook Update Proposed for Non-Pattern

**Symptom:** AI suggests rulebook update for minor code change

**Workflow Step:** `/finish` command, Sentinel

**Root Cause:**
- Pattern detection too sensitive
- Minor change flagged as "new pattern"
- Criteria not applied correctly

**Responsible Files:**
- `.cursor/skills/sentinel/SKILL.md` - Pattern detection criteria

**Fix:**
1. Verify criteria are met (11 for tech_stack, 5 for business_logic)
2. If criteria NOT met, state "No new patterns detected"
3. Don't propose rulebook updates for:
   - Minor refactoring
   - Bug fixes
   - Code style changes

---

## 14. Performance Issues

### Issue 14.1: Commands Take Too Long

**Symptom:** `/start` takes 2-3 minutes instead of 45-65 seconds

**Workflow Step:** Any command

**Root Cause:**
- Sequential execution instead of parallel (see Issue 10.1)
- Multiple MCP calls instead of reusing cache
- Subagents using default model instead of fast

**Responsible Files:**
- All command files
- `.cursor/agents/README.md` - Performance section

**Fix:**
1. Verify parallel execution (single message, multiple Tasks)
2. Verify model selection (fast for mechanical, default for reasoning)
3. Verify cache reuse (no redundant MCP calls)
4. Check MCP response times (may be slow)

---

### Issue 14.2: Token Usage Too High (Expensive)

**Symptom:** Commands cost more than expected

**Workflow Step:** Any command

**Root Cause:**
- Using default model for mechanical tasks
- Verbosity always full (never summary)
- No report caching (redundant work)

**Responsible Files:**
- All command files
- All subagent files (model and verbosity)

**Fix:**
1. Use `model: "fast"` for mechanical subagents
2. Use `verbosity: summary` when full details not needed
3. Cache and reuse reports across commands
4. Estimated savings: 50-60% with optimizations

---

## 15. Architectural Issues

### Issue 15.1: False Parallelism (Dependencies Not Respected)

**Symptom:** Subagents launched in parallel but depend on each other

**Workflow Step:** Any parallel execution

**Root Cause:**
- Dependencies not identified
- Parallel execution forced when sequential needed

**Responsible Files:**
- All command files with parallel execution

**Fix:**
1. Identify dependencies:
   - JIRA context → schema-analyzer, rabbit-tracer
   - Discovery → TDD planner, risk analyzer
2. Run dependent tasks sequentially:
   - Phase 1: JIRA inline
   - Phase 2: Parallel (schema + rabbit)
3. Only parallelize truly independent tasks

---

### Issue 15.2: JIRA Context as Subagent (Old Architecture)

**Symptom:** JIRA context analyzer invoked as subagent

**Workflow Step:** `/start` command

**Root Cause:**
- Using old architecture (pre-February 5, 2026)
- Prompt files not updated

**Responsible Files:**
- `.cursor/commands/start.md` - Should use inline JIRA
- `.cursor/skills/jira-context-analysis/SKILL.md` - Should be a skill, not subagent

**Fix:**
1. Verify JIRA context is gathered inline (not as subagent)
2. Verify jira-context-analysis is in `.cursor/skills/` not `.cursor/agents/`
3. Update all references to use inline execution

---

### Issue 15.3: Monolithic Discovery Report (Not Incremental)

**Symptom:** Entire Discovery Report regenerated when user asks for clarification

**Workflow Step:** `/start` command, Discovery

**Root Cause:**
- Discovery Report not structured as sections
- AI regenerates entire report for small changes

**Responsible Files:**
- `.cursor/skills/discovery/SKILL.md` - Report structure

**Fix:**
1. Structure Discovery Report as sections:
   - Section 1: Context Analysis ✅
   - Section 2: Schema Analysis ✅
   - Section 3: Message Flow Analysis ⏳
2. Update sections independently
3. Don't regenerate completed sections

---

## Quick Reference: File Responsibility Matrix

| Issue Category | Primary Files |
|----------------|---------------|
| JIRA Context | `.cursor/skills/jira-context-analysis/SKILL.md`, `.cursor/commands/start.md` |
| Schema Analysis | `.cursor/agents/schema-analyzer.md`, `.cursor/rules/db_rules.mdc` |
| RabbitMQ Flow | `.cursor/agents/rabbit-tracer.md`, `.cursor/rules/cross_service.mdc` |
| Discovery | `.cursor/skills/discovery/SKILL.md`, `.cursor/rules/microservice_rules.mdc` |
| TDD Planning | `.cursor/agents/tdd-planner.md`, `.cursor/skills/tdd-planning/SKILL.md` |
| Risk Analysis | `.cursor/agents/risk-analyzer.md`, `.cursor/commands/plan.md` |
| Code Review | `.cursor/agents/code-reviewer.md`, `.cursor/skills/review/SKILL.md` |
| Test Validation | `.cursor/agents/test-validator.md`, `.cursor/skills/review/SKILL.md` |
| Regression Detection | `.cursor/agents/regression-detector.md`, `.cursor/skills/sentinel/SKILL.md` |
| Parallel Execution | All command files, `.cursor/agents/README.md` |
| MCP Issues | `.cursor/commands/init.md`, `.cursor/rules/mcp_usage.mdc`, `.cursor/rules/troubleshooting.mdc` |
| Caching | All command files |
| Pattern Detection | `.cursor/skills/sentinel/SKILL.md`, `.cursor/commands/finish.md` |
| Performance | All files (model selection, parallel execution, caching) |
| Architecture | `.cursor/commands/start.md`, `.cursor/skills/jira-context-analysis/SKILL.md` |

---

## How to Report Issues

If you encounter an issue not covered here:

1. **Document the symptom** - What went wrong?
2. **Identify the step** - Which command/workflow step?
3. **Find the pattern** - Is this a recurring issue?
4. **Suggest a fix** - Which files should be updated?
5. **Test the fix** - Verify it resolves the issue

**Add to this document** for future reference.

---

**Last Updated:** February 19, 2026  
**Version:** 2.0  
**Status:** Living document (actively maintained)
