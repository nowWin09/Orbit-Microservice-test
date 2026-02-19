---
name: implementation-planning
description: Synthesize Technical Implementation Plan from discovery reports, TDD Blueprint, and Risk Assessment. Creates structured plan with 18 aspects (architecture, DB, APIs, security, performance, rollback). Use after TDD/Risk planning complete.
disable-model-invocation: false
---

# Implementation Planning Skill (The Synthesizer)

This skill **synthesizes** all discovery and planning outputs into a comprehensive Technical Implementation Plan document.

**When to use:** After TDD Blueprint and Risk Assessment are complete (during `/plan` command).

---

## Purpose

Create a structured Technical Implementation Plan that:
- Extracts problem/solution from Context Analysis
- Organizes technical details into 18-aspect table format
- Cross-references with Schema Analysis, Rabbit Tracer outputs
- Integrates TDD Blueprint and Risk Assessment
- Provides implementation readiness checklist

---

## Input Requirements

This skill requires these reports to exist in `docs/<JIRA_TICKET_ID>/`:
1. **context_analysis_report.md** (from `/start`)
2. **discovery_report.md** (from `/start`)
3. **tdd_blueprint.md** (from `/plan` - just completed)
4. **risk_assessment_report.md** (from `/plan` - just completed)
5. **schema_analysis_report.md** (optional, if DB changes)
6. **message_flow_report.md** (optional, if RabbitMQ)

**If any required report is missing:** STOP and inform user which report is needed.

---

## Output Structure

Create: `docs/<JIRA_TICKET_ID>/implementation_plan.md`

### Section 1: Problem Summary
- Extract from Context Analysis Report (PRD summary) OR Jira ticket description
- 2-3 sentences: What problem? Who is affected? Why is manual process insufficient?

### Section 2: Proposed Solution Overview
- Extract from Context Analysis Report (synthesized requirements)
- 3-5 sentences: What features are being delivered? Who benefits? Key capabilities?

### Section 3: Technical Implementation Plan

**Format:** Markdown table with these 18 aspects:

| Aspect | Details / Plan |
|--------|---------------|
| **Code Area / Module** | List services and files to be modified (from Discovery Report)<br/>Example: `service-csiq-microservice → contact-service`, `frontend-admin → contact-settings` |
| **Architecture Impact** | New components, scheduler jobs, message queues, integrations<br/>Note if breaking change or backward-compatible<br/>Reference Discovery Report patterns |
| **Database Changes** | **New tables/collections:** (from Schema Analysis if exists)<br/>**New fields:** (list with types)<br/>**Altered fields:** (list changes)<br/>**Dropped fields:** (list removals)<br/>**Indexes:** (from schema-analyzer recommendations)<br/>**Platform Consulted:** Yes/No (check Discovery Report for mention of platform team consultation) |
| **API / Event Changes** | **New endpoints:** Method, path, purpose (from Discovery Report)<br/>**Modified endpoints:** What changed<br/>**New RabbitMQ events:** Exchange, routing key, payload (from Rabbit Tracer if exists)<br/>**Breaking changes:** Yes/No |
| **Inter-Service Communication** | RabbitMQ flow: Producer → Exchange/Routing Key/Queue → Consumer<br/>Payload contract (from Rabbit Tracer if exists)<br/>New bindings needed<br/>Reference `.env.example` for queue configs |
| **Security / Permissions** | Required role/permission checks (from Discovery Report)<br/>Middleware to apply<br/>HIPAA considerations (if PHI involved - check Context Analysis)<br/>Auth flow |
| **Feature Flags** | Feature flag name (format: `feature_<name>_v1`)<br/>Where to check (backend, frontend, both)<br/>Default state (enabled/disabled)<br/>Rollout plan |
| **Telemetry / Observability** | **Metrics:** What to measure (API response time, queue depth, error rate)<br/>**Logs:** What to log (start/end of jobs, errors, per-tenant summary)<br/>**Alerts:** When to alert (failure rate thresholds, performance degradation) |
| **Dependencies** | **External services:** (email, SMS, analytics)<br/>**Internal services:** (from Discovery Report cross-service dependencies)<br/>**Cron windows:** Coordinate with platform<br/>**Rate limits:** Service quotas to consider |
| **Performance Considerations** | **Query optimization:** Batch operations, indexes (reference Schema Analysis recommendations)<br/>**Caching:** Redis keys, TTL<br/>**Pagination:** Limits for large datasets<br/>**Background jobs:** Batching strategy |
| **Error Handling** | **Retry strategy:** Max retries, backoff (exponential)<br/>**Fallback behavior:** Default values, graceful degradation<br/>**Alerting:** Sentry, PagerDuty thresholds<br/>**User-facing errors:** HTTP codes, clear messages |
| **Testing Strategy** | Reference TDD Blueprint:<br/>**Unit tests:** Key functions to test<br/>**Integration tests:** End-to-end flows<br/>**E2E tests:** User scenarios (if UI)<br/>**Load tests:** Performance validation |
| **Rollback Strategy** | **Feature flag:** How to disable<br/>**Database:** Rollback script, data backup<br/>**Queue cleanup:** Stop consumers, purge messages<br/>**Deployment order:** Steps to rollback safely |
| **Documentation Updates** | **User-facing:** Admin guides, FAQs<br/>**API docs:** Swagger/OpenAPI, Postman<br/>**Internal:** Architecture diagrams, Runbooks<br/>**Changelog:** Release notes |
| **Expected Completion** | **Complexity:** Simple / Medium / Complex<br/>**Note:** DO NOT provide timeline estimates (days/weeks)<br/>**Blockers:** List any dependencies not yet available |

### Section 4: Risk Assessment
- Copy from `risk_assessment_report.md`
- Include: Readiness (Green/Yellow/Red), critical risks, mitigation checklist

### Section 5: TDD Blueprint
- Copy from `tdd_blueprint.md`
- Include: Test suite structure, coverage map, implementation guidance

### Section 6: Implementation Readiness Checklist
Synthesize from all reports:
- [ ] Context Analysis Report complete
- [ ] Discovery Report reviewed
- [ ] Schema changes verified with DB MCP (if applicable)
- [ ] RabbitMQ flow traced (if applicable)
- [ ] Risk assessment complete
- [ ] TDD Blueprint created
- [ ] Platform team consulted for DB changes (if applicable)
- [ ] Feature flag naming confirmed
- [ ] Rollback strategy validated

---

## Cross-Referencing Guidelines

### Use Schema Analysis Report (if exists)
- **Database Changes section:** Copy table schemas, recommended indexes
- **Performance Considerations section:** Reference index justifications

### Use Rabbit Tracer Report (if exists)
- **Inter-Service Communication section:** Copy message flow diagram, payload contract
- **API / Event Changes section:** List new events and routing keys

### Use Discovery Report
- **Code Area / Module:** Extract file paths from "Files to be modified"
- **Architecture Impact:** Extract patterns from "Established patterns to follow"
- **Platform Consulted:** Check if platform team mentioned for DB changes

### Use TDD Blueprint
- **Testing Strategy:** Reference specific test files and test cases
- Link requirements to test coverage

### Use Risk Assessment
- **Performance Considerations:** Address performance risks with concrete solutions
- **Error Handling:** Address operational risks with retry/fallback strategies
- **Rollback Strategy:** Address deployment risks

---

## Validation Rules

Before saving `implementation_plan.md`, verify:

1. **All 18 aspects have content** (no "TODO" placeholders without reason)
2. **Cross-references are valid** (file paths exist in reports)
3. **Platform Consulted is accurate** (check Discovery Report for DB team mention)
4. **Feature flag follows naming convention** (`feature_<name>_v1`)
5. **Risk mitigation aligns** (Performance section addresses performance risks)
6. **Test coverage is complete** (TDD Blueprint covers all requirements)

---

## Error Handling

**If Context Analysis missing:**
- STOP, state: "Cannot create implementation plan without Context Analysis Report. Please run `/start` first."

**If Discovery Report missing:**
- STOP, state: "Cannot create implementation plan without Discovery Report. Please run `/start` first."

**If TDD Blueprint missing:**
- STOP, state: "TDD Blueprint not found. The `/plan` command should run tdd-planner subagent first."

**If Risk Assessment missing:**
- STOP, state: "Risk Assessment not found. The `/plan` command should run risk-analyzer subagent first."

**If Schema/Rabbit reports missing but needed:**
- Continue, but flag in Implementation Plan: "⚠️ Schema Analysis not run; Database Changes section needs DB MCP verification."

---

## Example Execution Flow

```
/plan command runs:
  1. [Parallel] tdd-planner + risk-analyzer subagents
  2. Wait for both to complete
  3. Main agent invokes this skill (implementation-planning)
  4. Skill reads all 6 reports
  5. Skill synthesizes implementation_plan.md
  6. Skill saves to docs/<TICKET_ID>/
  7. Main agent presents to user for approval
```

---

## Tips for Quality Output

- **Be specific:** Use actual file paths, function names, table names from reports
- **Be concrete:** Provide actual values (not "appropriate timeout" but "30s timeout with 3 retries")
- **Be consistent:** Use same terminology across all sections
- **Cross-reference:** Link back to source reports (e.g., "See Schema Analysis: index on practice_id, status")
- **Flag unknowns:** If information is missing, state what's missing and why it's needed

---

## See Also

- Sample output: `docs/SAMPLE_IMPLEMENTATION_PLAN.md`
- TDD Blueprint format: `.cursor/skills/tdd-planning/SKILL.md`
- Risk Assessment format: `.cursor/agents/risk-analyzer.md`
