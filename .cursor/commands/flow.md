# Flow (RabbitMQ Message Flow Analysis)

Analyze producer → consumer message flow and verify payload contracts.

---

## Workflow Overview

```
/flow → Check Cache → Invoke rabbit-tracer → Report
```

**Estimated Time:** 15-25 seconds (if not cached)

---

## Steps

### 1. Check Cached Report
Look for `docs/<JIRA_TICKET_ID>/message_flow_report.md` from `/start`

**If found:** Reuse (state "Using cached message flow report")  
**If missing:** Proceed to Step 2

### 2. Identify Context
From ticket or open files, identify:
- Producer/Consumer file path
- Service name
- Exchange name
- Routing key
- Queue name(s)

### 3. Invoke rabbit-tracer Subagent
```javascript
Task(
  subagent_type="generalPurpose",
  model="fast",  // Mechanical task
  prompt="Read and execute .cursor/agents/rabbit-tracer.md. 
          Service: <service>. 
          Exchange: <exchange>. 
          Routing Key: <key>. 
          Verbosity: full",
  description="Trace RabbitMQ flow"
)
```

**What it does:**
- Search codebase for producer/consumer
- Verify payload contract (producer vs consumer validation)
- Check DB schema alignment
- Verify queue/exchange bindings

**Output:** `docs/<JIRA_TICKET_ID>/message_flow_report.md`

### 4. Review Report
**Report contains:**
- Message flow: Producer → Exchange → Queue → Consumer
- Payload contract comparison
- Schema mismatches (missing/extra/type differences)
- Binding verification
- Recommendations for alignment

---

## Alternative: Manual Analysis

**If rabbit-tracer unavailable:**  
Use `.cursor/skills/message-flow/SKILL.md` for manual analysis guidance.

**Fallback steps:**
1. Ask user for manual context (producer, consumer, payload examples)
2. Proceed with HIGH RISK warning (not verified via MCP)

---

## Usage

```
/flow
```

**Use when:** Working on RabbitMQ or cross-service message flow
