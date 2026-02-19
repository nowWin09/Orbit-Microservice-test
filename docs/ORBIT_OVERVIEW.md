# Project Orbit - Complete Overview

## What is Project Orbit?

**Project Orbit** is an AI-driven development framework that ensures **high-quality, production-ready code** through a structured workflow combining:
- **Test-Driven Development (TDD)** – Write tests first, then code
- **Risk Assessment** – Identify and mitigate risks before implementation
- **Code Quality Review** – Automated checks for N+1 queries, HIPAA compliance, validation
- **Regression Detection** – Find breaking changes before they reach production
- **Pattern Learning** – Evolve project rules based on new architectural patterns

## Why Orbit?

Before Orbit, development suffered from:
- ❌ Untested code shipped to production
- ❌ Breaking changes that broke dependent services
- ❌ N+1 database query bugs (performance issues)
- ❌ Missing input validation
- ❌ No HIPAA compliance checks
- ❌ Copy-paste patterns without consistency

**With Orbit:**
- ✅ 100% test coverage (tests written first)
- ✅ Zero breaking changes (regression detection)
- ✅ No N+1 queries (code review enforcement)
- ✅ All inputs validated (Joi requirement)
- ✅ HIPAA compliance verified
- ✅ Consistent architectural patterns

## How Orbit Works - The 3-Phase Workflow

### Phase 1: Discovery (`/start`)
**Goal:** Understand the requirement and dependencies

```
You say: /start implement user authentication for CSIQ-12043

Orbit does:
1. Fetch JIRA ticket + PRD from Google Drive
2. Analyze database schemas (MariaDB/MongoDB)
3. Trace RabbitMQ message flows
4. Find related code and patterns
5. Create Discovery Report
```

**Output:** Discovery Report (what needs to change, where, and why)

---

### Phase 2: Planning (`/plan`)
**Goal:** Create a detailed implementation plan before coding

```
You say: /plan

Orbit does:
1. Generate TDD Blueprint (tests that will verify feature works)
2. Assess risks (breaking changes, performance, security)
3. Create Implementation Plan (18-point technical roadmap)
4. Validate completeness (coverage map, edge cases)
```

**Output:** Implementation Plan + TDD Blueprint + Risk Assessment

---

### Phase 3: Delivery (`/finish`)
**Goal:** Verify code quality and catch regressions

```
You implement the feature, then you say: /finish

Orbit does:
1. Review code (N+1 queries, validation, HIPAA, patterns)
2. Validate tests (execution, coverage, assertion quality)
3. Detect regressions (dependent code that might break)
4. Suggest new patterns if detected
```

**Output:** Code Review Report + Test Validation Report + Regression Report

---

## Architecture: Who Does What?

### Main Agent (You in Cursor)
- Orchestrates the workflow
- Makes decisions
- Implements code
- Fixes issues

### Specialized Subagents (AI Workers)
Each subagent handles ONE specific task:

| Subagent | Purpose | When Used |
|----------|---------|-----------|
| **schema-analyzer** | Analyze DB schemas, detect changes, recommend indexes | `/start` |
| **rabbit-tracer** | Trace RabbitMQ producers/consumers, find payload mismatches | `/start` |
| **tdd-planner** | Design test suite (Red → Green → Refactor) | `/plan` |
| **risk-analyzer** | Identify breaking changes, performance risks, security issues | `/plan` |
| **implementation-planner** | Synthesize 18-aspect technical implementation plan | `/plan` |
| **code-reviewer** | Check for N+1 queries, Joi validation, HIPAA, patterns | `/finish` |
| **test-validator** | Verify tests exist, execute, and cover requirements | `/finish` |
| **regression-detector** | Find code dependencies that might break | `/finish` |
| **orbit-validator** | Quality assurance of entire Orbit execution | After `/finish` |

---

## Configuration & MCP Integration

Orbit uses **Model Context Protocol (MCP)** to access external data sources:

### MCPs (Data Sources)

| MCP | Purpose | Used For |
|-----|---------|----------|
| **Jira MCP** | Fetch tickets, sub-tasks, requirements | Context Analysis |
| **GDrive MCP** | Fetch PRDs, specifications | Context Analysis |
| **MariaDB MCP** | Query live database schema | Schema Analysis |
| **MongoDB MCP** | Query MongoDB collections/schema | Schema Analysis |
| **GitHub MCP** | Push code, create PRs, check CI | Implementation |

### Check MCP Status
```bash
/init
```
This command verifies all MCPs are working and caches their status.

### If MCP is Down
- **Fallback:** Use manual input (ask user for schema/data)
- **HIGH RISK:** Orbit will continue but with reduced accuracy
- **Fix:** Configure MCP in Cursor settings

---

## Key Concepts

### Discovery Report
**What:** Unified analysis of the requirement  
**Contains:**
- What needs to change (scope)
- Where to change it (files affected)
- Why (business context)
- Dependencies (other features, services)

### TDD Blueprint
**What:** Test suite design before implementation  
**Contains:**
- Red Phase: Tests that fail (describe requirements)
- Green Phase: Minimal code to pass tests
- Edge case tests (null, empty, boundary values)
- Performance tests (no N+1 queries)
- HIPAA compliance tests

### Risk Assessment
**What:** Potential issues before they happen  
**Contains:**
- Breaking changes (API contracts, DB schema)
- Performance risks (missing indexes, slow queries)
- Security risks (auth, data exposure)
- Compliance risks (HIPAA violations)

### Regression Detection
**What:** Code that might break due to your changes  
**Contains:**
- Direct dependencies (function calls, imports)
- Indirect dependencies (DB columns, message payloads)
- Risk level per dependency
- Recommended regression tests

---

## File Organization

When you run `/start CSIQ-12043`, Orbit creates:

```
docs/
└── CSIQ-12043/
    ├── context_analysis_report.md          ← What's the requirement?
    ├── schema_analysis_report.md           ← What DB changes?
    ├── message_flow_report.md              ← What RabbitMQ changes?
    ├── discovery_report.md                 ← Unified analysis
    ├── tdd_blueprint.md                    ← Tests to write
    ├── risk_assessment_report.md           ← Risks identified
    ├── implementation_plan.md              ← How to implement (18 points)
    ├── code_review_report.md               ← Code quality issues
    ├── test_validation_report.md           ← Test coverage/quality
    └── regression_impact_report.md         ← Dependent code at risk
```

---

## Workflow Commands

### `/start`
Initialize a new feature
```
/start implement user authentication for CSIQ-12043
```
**Time:** 45-65 seconds  
**Output:** Discovery Report (approval gate)

---

### `/plan`
Create implementation plan (requires `/start` first)
```
/plan
```
**Time:** 25-35 seconds  
**Output:** TDD Blueprint + Risk Assessment + Implementation Plan (approval gate)

---

### `/finish`
Complete and verify implementation
```
/finish
```
**Time:** 25-35 seconds  
**Output:** Code Review + Test Validation + Regression Report

---

### `/init`
Check MCP connectivity and system status
```
/init
```
**Time:** 5-10 seconds  
**Output:** MCP status report, cached for session

---

### Other Commands

| Command | Purpose |
|---------|---------|
| `/explain` | Explain how a feature works |
| `/flow` | Show message flow / architecture |
| `/fix` | Troubleshoot and fix issues |
| `/test-mode` | Blind implementation for testing |

---

## Rules Framework

Orbit applies project-specific rules based on file type:

| Rule File | Applied To | Examples |
|-----------|-----------|----------|
| `db_rules.mdc` | Database changes | No N+1 queries, indexing strategy |
| `microservice_rules.mdc` | Service code | TDD mandatory, HIPAA checks |
| `tech_stack.mdc` | All code | Joi validation, JSDoc format |
| `cross_service.mdc` | RabbitMQ / APIs | Contract verification |
| `business_logic.mdc` | Domain logic | Persona alignment, compliance |
| `mcp_usage.mdc` | MCP operations | Error handling, fallbacks |

---

## Best Practices

### 1. Always Run `/start` First
Never skip discovery. It builds the context for all downstream steps.

### 2. Approval Gates
- After `/start` → Approve Discovery Report
- After `/plan` → Approve TDD Blueprint & Risk Assessment
- After implementation → Run `/finish`

### 3. Don't Skip TDD
Tests must be written FIRST (Red phase), before implementation.

### 4. Use Parallel Execution
When `/start`, `/plan`, `/finish` launch multiple subagents, they run in parallel (not sequentially).

### 5. Check Caching
Orbit caches reports in `docs/<TICKET_ID>/`. Reuse them to save time.

---

## Common Issues & Troubleshooting

See `ORBIT_TROUBLESHOOTING_MATRIX.md` for:
- Symptoms you might encounter
- Root causes
- Fixes and responsible files

**Quick Link:**
- MCP unavailable? → Issue 11.1
- Tests only cover happy path? → Issue 5.1
- N+1 query in code? → Issue 7.1
- Commands too slow? → Issue 14.1

---

## Next Steps for New Users

1. **Read this file** (you're here!)
2. **Review ORBIT_FLOWCHART.md** (visual process flows)
3. **Check ORBIT_COMMANDS_GUIDE.md** (how to run each command)
4. **Review ORBIT_TROUBLESHOOTING_MATRIX.md** (when things break)
5. **Run `/init`** to verify MCP setup
6. **Try `/start`** with a real ticket

---

## Glossary

| Term | Meaning |
|------|---------|
| **TDD** | Test-Driven Development (tests first, code after) |
| **MCP** | Model Context Protocol (data source integration) |
| **N+1 Query** | Bug where loop queries DB repeatedly instead of batch |
| **Breaking Change** | API/schema change that breaks dependent code |
| **Regression** | Code that breaks due to your changes |
| **Joi** | Input validation library (mandatory for all endpoints) |
| **HIPAA** | Healthcare privacy regulation (PHI must not be logged) |
| **RabbitMQ** | Message queue for async communication between services |
| **Rulebook** | Project-specific rules that guide code decisions |

---

**Last Updated:** February 19, 2026  
**Version:** 1.0  
**For New Users:** Start here!
