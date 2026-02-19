# Fix (Run Tests and Auto-Repair)

Run the project test suite and attempt to fix failing tests or lint errors in line with project rules.

## Steps

1. Execute the project test suite (e.g. `npm test`).
2. For any failures, analyze the cause and apply fixes following `.cursor/rules/` (tech_stack, db_rules, microservice_rules, etc.).
3. Re-run tests until they pass. Fix lint errors (e.g. `.eslintrc.json`) as needed.

## Usage

Type `/fix` to run tests and auto-repair failures.
