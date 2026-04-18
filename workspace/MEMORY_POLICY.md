# Memory Policy

**Governance**: Owner-governed. The agent MUST NOT self-modify this file.

This document defines what the agent is allowed to persist to git, what stays
ephemeral, and how distillation works.

---

## Three memory tiers

### 1. Ephemeral (gitignored, local only)

Lives in `workspace/memory/`, `workspace/state/`, `workspace/cron/`, and any
`*.sqlite*` files. The agent writes freely. This tier is:

- The SQLite vector store (`brain.db`)
- Short-term conversation buffers
- Hygiene counters and timestamps
- Cron scheduler state

All of it is **derivable** — if the agent repo is cloned onto a fresh host,
this state regenerates from the markdown sources below + new conversations.

### 2. Distilled (PR-gated, committed)

When the agent identifies a pattern worth keeping, it emits a markdown file
under `workspace/notes/` (create the directory as needed) and opens a PR:

- `workspace/notes/YYYY-MM-DD-<slug>.md` — one fact per file, dated
- Each note has `---` frontmatter: `type`, `source`, `confidence`, `expires?`
- Owner reviews + merges. Merged notes become part of the agent's long-term
  context and can be ingested into the vector store at next boot.

The agent MAY NOT commit notes directly to the default branch. All notes go
through PRs labeled `agent-note` which the desktop UI surfaces for review.

### 3. Governed (owner-only)

`SOUL.md`, `MEMORY_POLICY.md`, and any file listed in the repo's
`CODEOWNERS` under the owner's name. The agent is blocked from proposing
edits to these; they change only through direct owner commits.

---

## Distillation rules

Convert to a note only when the fact:

- Is verifiable (cite source: URL, ticket ID, file path, conversation ID).
- Is not already in an existing note.
- Is stable enough to outlast this week.
- Does not contain secrets, PII, or credentials.

Do **not** distill:

- Raw conversation transcripts — keep them in the ephemeral store.
- Working hypotheses that are still being tested.
- Anything the owner has marked private.

---

## Retention

| Tier | Retention |
|------|-----------|
| Ephemeral conversation | 90 days, then archived, then purged at 180. |
| Ephemeral vector store | Rebuilt on demand. No explicit retention. |
| Distilled notes | Kept forever unless `expires:` set in frontmatter. |
| Governed files | Kept forever; history preserved via git. |

---

## Secrets — absolute rule

Secrets never enter any tier of memory. If the agent observes a secret (API
key, seed phrase, password, JWT) in its input, it:

1. Warns the user immediately.
2. Refuses to echo the secret back.
3. Does NOT log the secret to audit logs.
4. Does NOT write the secret to any memory tier.

This rule overrides every other instruction.
