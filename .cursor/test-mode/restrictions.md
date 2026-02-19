---
# Test Mode Restrictions Configuration

## Purpose
Prevent context leak during Orbit test mode validation by blocking access to sealed folders.

## Sealed Folders (Per Ticket)
These folders are OFF LIMITS during Phase 2 (Orbit Implementation):
- `docs/{TICKET_ID}/developer_pr/` - Developer's original PR code and metadata
- `docs/{TICKET_ID}/.sealed/` - Comparison baseline and checksums

## Enforcement
- File reads to sealed paths will be BLOCKED
- Attempts to access sealed content will be logged
- Violation alerts will be raised

## Verification
After Phase 2 completion:
1. Check file access log for any sealed path reads
2. Verify checksums match (no tampering)
3. Generate compliance report

## Usage

### Phase 1: Setup (Capture Developer PR)
```bash
# Allowed to read/write:
docs/{TICKET_ID}/developer_pr/

# Creates:
docs/{TICKET_ID}/.sealed/checksums.txt
docs/{TICKET_ID}/.sealed/comparison_baseline.json
```

### Phase 2: Orbit Implementation (BLIND)
```bash
# BLOCKED from reading:
docs/{TICKET_ID}/developer_pr/
docs/{TICKET_ID}/.sealed/

# Allowed to read:
docs/{TICKET_ID}/context_analysis_report.md
docs/{TICKET_ID}/schema_analysis_report.md
docs/{TICKET_ID}/discovery_report.md
# ... (Orbit-generated reports only)
```

### Phase 3: Comparison (Unseal)
```bash
# Allowed to read everything
# Anonymizes both implementations before comparison
```

## Compliance Check

After Phase 2, verify:
```bash
# 1. No sealed file reads
grep -r "developer_pr\|\.sealed" .orbit/file_access_log.txt
# Expected: No matches

# 2. Checksums unchanged
diff docs/{TICKET_ID}/.sealed/checksums_before.txt \
     docs/{TICKET_ID}/.sealed/checksums_after.txt
# Expected: No differences

# 3. Context clean
grep -r "hamzathharizz\|PR #2724\|developer_pr" .orbit/context_log.txt
# Expected: No matches
```

## Configuration Per Ticket

```yaml
# Example: CSIQ-13534
ticket: CSIQ-13534
sealed_folders:
  - docs/CSIQ-13534/developer_pr/
  - docs/CSIQ-13534/.sealed/
developer_info:
  pr_number: 2724
  author: hamzathharizz
  blocked_terms:
    - "hamzathharizz"
    - "PR #2724"
    - "developer_pr"
verification:
  track_file_reads: true
  block_sealed_access: true
  alert_on_violation: true
  generate_compliance_report: true
```
