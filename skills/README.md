# skills/

Skills are the agent's self-authored capabilities. Each skill is a directory
with a `SKILL.md` at its root:

```
skills/
├── my-skill-name/
│   └── SKILL.md            Description + invocation pattern
└── another-skill/
    ├── SKILL.md
    └── run.sh              Optional executable script
```

## SKILL.md shape

```markdown
---
name: kb-refresh
description: Rebuild the knowledge-base vector index from workspace/notes/
triggers: ["refresh knowledge", "rebuild kb", "reindex notes"]
---

# kb-refresh

When the agent decides to run this skill, it executes `./run.sh` from the
skill directory. The script exits 0 on success.

Output is captured and fed back to the agent as the next message.
```

## Rules

- Skills are **PR-gated**. The agent proposes new skills by opening a PR
  adding a directory here. The owner reviews and merges.
- Skills are **bash-shaped** by default. If a skill needs more, write a
  Python/Node script and invoke it from `run.sh`.
- Skills may read the workspace but **MUST NOT** modify `SOUL.md` or
  `MEMORY_POLICY.md`.
- Each skill declares its triggers — the agent pattern-matches on user
  requests to decide which skill to run.
