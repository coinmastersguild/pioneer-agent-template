# workspace/notes/

The agent's long-term, owner-reviewed memory. Every file here is
**committed to git through a pull request** — nothing in this tree is
writable by the agent directly.

See [`../MEMORY_POLICY.md`](../MEMORY_POLICY.md) for the governance rules.

## Subdirectories

### `findings/`
Security findings, incident writeups, vulnerability reports, or
audit-style conclusions. Each file is `YYYY-MM-DD-<slug>.md`.

PRs adding to this directory should be labeled `finding`. The owner
reviews every one before merge; merged findings become canonical.

### `patterns/`
Reusable knowledge the agent has distilled from conversations, code
reads, or research — things that should outlive the ephemeral vector
store. Each file is one pattern.

Suggested shape:
```markdown
---
type: pattern
source: "<where this came from: file path, URL, conversation ID>"
confidence: 0.8
expires: 2027-01-01   # optional
---

# Pattern title

One paragraph on the pattern.

## When it applies

## When it does NOT apply

## Evidence / citations
```

PRs adding to this directory should be labeled `pattern`.
