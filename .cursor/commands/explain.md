# Explain (Code Explanation Report)

Generate a **Code Explanation Report** and save it to `docs/<JIRA_TICKET_ID>/code_explanation.md`.

## Sections to Include

- **high-level-summary** – Goal, architectural approach, key decisions
- **data-flow-walkthrough** – Step-by-step request/message flow (e.g. route → controller → service → repository → response; or queue → consumer → service → repository → ACK)
- **component-by-component-breakdown** – Each new/changed file: path, purpose. For each new or changed method: logic, parameters, return values. Explain the "why" and justify by referencing rules from MicroServicePrompt and DatabasePrompt.
- **test-suite-explanation** – Test files, what they validate, test-by-test breakdown
- **database-schema-explanation** – If DB changed: tables/collections, columns, constraints. For each index: purpose and justification per Universal Indexing Decision Framework.

## Usage

Type `/explain` or `orbit:explain` after implementation to generate the report. Use the JIRA ticket ID from the current task for the path.
