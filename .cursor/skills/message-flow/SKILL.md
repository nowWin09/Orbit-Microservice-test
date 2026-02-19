---
name: message-flow
description: Analyze producer → consumer flow across services, schema mismatches, or missing consumer logic. Use when working on RabbitMQ or cross-service message flow.
disable-model-invocation: false
---

# Message Flow Skill (Cross-Service Trace)

Use this skill when analyzing **producer → consumer** flow across services or when asked to check for **schema mismatches** or **missing consumer logic**.

## Protocol

**PREFERRED APPROACH: Delegate to `rabbit-tracer` subagent**

For comprehensive analysis, invoke the `rabbit-tracer` subagent with model optimization:

```javascript
Task(
  subagent_type="generalPurpose",
  model="fast",  // Message flow tracing is largely mechanical (search + compare)
  prompt="Read and execute .cursor/agents/rabbit-tracer.md. Context:
    - Producer/Consumer file: <file path>
    - Service: <service name>
    - Exchange: <exchange name>
    - Routing Key: <routing key>
    - Queue: <queue name>
    - Ticket: <TICKET_ID> (if applicable)
    - Verbosity: full
    
    Additional context: <any relevant info>",
  description="Trace RabbitMQ producer-consumer flow"
)
```

**If analyzing multiple message flows, run subagents in PARALLEL:**

```javascript
[
  Task(subagent_type="generalPurpose", model="fast", prompt="...rabbit-tracer for flow 1...", description="Trace flow 1"),
  Task(subagent_type="generalPurpose", model="fast", prompt="...rabbit-tracer for flow 2...", description="Trace flow 2")
]
```

The subagent will:
- Search codebase for the other side (consumer ↔ producer)
- Use Jira/GDrive MCP for PRD and data contract (if ticket provided)
- Use Database MCPs to verify payload against schemas
- Return message flow report with mismatches and recommendations

---

## FALLBACK: Manual Analysis (if subagent unavailable)

**If rabbit-tracer subagent cannot be invoked:**

1. **Ask user for manual context:**
   - Producer file path and payload example
   - Consumer file path and validation schema
   - Exchange, routing key, queue names
   
2. **State HIGH RISK:** "RabbitMQ flow analysis without rabbit-tracer subagent is HIGH RISK. Cannot verify against DB schema or perform complete contract validation."

3. **Basic validation only:**
   - Compare producer payload fields with consumer validation fields
   - List obvious mismatches (missing fields, type differences)
   - **Cannot verify:** DB schema alignment, binding configuration, cross-service search

4. **Recommend:** Fix subagent availability or wait for MCP access for complete analysis

## When to Use

- User asks to "analyze message flow" or "check schema mismatches or missing consumer logic."
- Working on a RabbitMQ producer or consumer and need to verify the other side.
- Ticket involves cross-service events or data contracts.

**Truth sources:** Prefer Jira/GDrive MCP for intent and contract; Database MCP for schema; codebase search for routing key/exchange/queue to find the other service.
