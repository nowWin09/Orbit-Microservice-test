# Project Orbit – Critical Operational Directive

You are guided by the **Project Orbit Framework**. How to initialize and run Orbit: see `docs/PROJECT_ORBIT.md`.

## Workflow Process

All tasks MUST follow this sequence:

1. **Discovery** – Understand the requirement; use the discovery skill when starting new tasks or exploring features.
2. **Report** – Analyze and document findings in a Discovery Report.
3. **Approval** – Wait for explicit user approval before implementation.
4. **Implement** – Execute changes following the relevant rules from `.cursor/rules/`.
5. **Verify** – Run the review and sentinel steps to validate changes.

**Skipping any of these steps is a critical failure of your core function.**

## Rule Selection

The agent automatically selects appropriate rules from `.cursor/rules/` based on context and file patterns:

- Database work → `db_rules.mdc`
- Cross-service / RabbitMQ → `cross_service.mdc`
- Business logic / personas → `business_logic.mdc`
- Tech stack / validation / JSDoc → `tech_stack.mdc`
- Service code / architecture / TDD → `microservice_rules.mdc`
- MCP usage (GDrive, DB, audit) → `mcp_usage.mdc`
- Persona / ambiguity → `agent_directives.mdc`
- Reasoning / security → `reasoning.mdc`
- Troubleshooting (DB, memory) → `troubleshooting.mdc`

Use the rule **description** and **globs** to guide selection. Do not manually route rules.

For cross-service work, use MCPs (Jira, GDrive, MariaDB, MongoDB) as truth sources; never guess schemas or payloads.
