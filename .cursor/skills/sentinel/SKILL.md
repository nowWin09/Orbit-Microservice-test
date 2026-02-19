---
name: sentinel
description: Final validation before closing a feature. Ask whether the PR introduced a new pattern or business rule; if yes, update tech_stack.mdc or business_logic.mdc. Use when the user runs /finish.
disable-model-invocation: true
---

# Sentinel Skill (Context Sentinel)

**From Roadmap – Self-Healing Logic:** "Most AI rules get stale in 2 weeks. Our system includes a 'Context Sentinel'. Every time a developer closes a major feature, the AI analyzes the changes and proposes updates to its own rulebook—whether that's a new architectural pattern or a shift in business logic. The system learns as we code."

## Logic

**Trigger:** On `/finish` command (after review).

### Step 1: Regression Detection

**PREFERRED APPROACH: Delegate to `regression-detector` subagent**

```
Task(
  subagent_type="generalPurpose",
  prompt="Read and execute .cursor/agents/regression-detector.md. Context:
    - Changed files: <list of files>
    - Changed functions: <list of modified/added functions>
    - Schema changes: <if any>
    - Ticket: <TICKET_ID>
    
    Identify potential regressions and recommend regression tests.",
  description="Detect regression impact"
)
```

The subagent will return a **Regression Impact Report** with:
- Dependency analysis (direct + indirect)
- Risk assessment (high/medium/low risk features)
- Existing test coverage for dependent code
- Recommended regression tests

**Review the report.** If high-risk regressions are found without tests, **add regression tests** before proceeding.

### Step 2: Rulebook Update

**Evaluate Pattern Changes Using Criteria:**

Before asking the user, automatically check these criteria:

#### Criteria for "New Pattern" (Update `tech_stack.mdc`)
- [ ] **New external library/framework** (e.g., GraphQL, Redis, Socket.io, new npm package)
- [ ] **New architectural pattern** (e.g., CQRS, Event Sourcing, Repository with Transactions, new layered approach)
- [ ] **New cross-service integration** (e.g., new RabbitMQ exchange, new BigQuery dataset, new external API)
- [ ] **New security mechanism** (e.g., JWT refresh, 2FA, encryption, new auth middleware)
- [ ] **New validation approach** (e.g., custom Joi plugin, new validation library)
- [ ] **New deployment mechanism** (e.g., Docker, Kubernetes config, new PM2 pattern)

#### Criteria for "Business Rule Change" (Update `business_logic.mdc`)
- [ ] **New workflow state** (e.g., new status in state machine, new approval flow)
- [ ] **New calculation formula** (e.g., pricing logic, SLA calculation, metric computation)
- [ ] **New user role or permission** (e.g., new persona, access level)
- [ ] **New data retention rule** (e.g., TTL policy, archival logic, PII handling)
- [ ] **New compliance requirement** (e.g., HIPAA rule, audit requirement, consent management)

**Action:**

1. **Auto-detect:** Check if ANY criterion above is met (scan changed files, commits, PR description)
2. **If detected:** 
   - State **which criteria are met** (e.g., "New RabbitMQ exchange detected: contact_events")
   - **Propose the rule addition** (show the exact text to add to the rule file)
   - **Ask user for approval:** "Should I add this rule to `tech_stack.mdc` / `business_logic.mdc`?"
   - **If approved:** Append the rule immediately
3. **If no criteria met:** State "No new patterns detected; no rulebook update needed."

**Example Auto-Detection:**

```markdown
**Pattern Detection Results:**

✅ New RabbitMQ exchange detected: `contact_events`
  - Criterion: "New cross-service integration"
  - Proposed rule for `tech_stack.mdc`:
    ```
    ## RabbitMQ Exchange: contact_events
    - **Purpose:** Notify services when contact data changes
    - **Producers:** ContactService (service-cs-one-api)
    - **Consumers:** BigQuerySync, AuditLogger
    - **Routing keys:** contact.created, contact.updated, contact.deleted
    - **Payload schema:** { contactId, practiceId, changeType, timestamp, data: {...} }
    ```

Should I add this rule to `tech_stack.mdc`? (yes/no)
```

**Result:** The rules files grow smarter with every ticket closed, regressions are detected before merge, and **pattern detection is systematic** (not ad-hoc).
