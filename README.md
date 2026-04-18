# pioneer-agent-template

Template repository for a Pioneer agent. Every Pioneer agent is backed by a private git repo generated from this template. The repo holds the agent's **identity, values, tools, skills, and briefings** — everything that makes one agent different from another.

> "Soul in git. Working memory on disk. Secrets in the vault."

## How this template is used

1. A user completes Pioneer onboarding.
2. Pioneer authenticates with GitHub on the user's behalf (device-flow OAuth, PAT stored in vault).
3. Pioneer calls `POST /repos/{template_owner}/pioneer-agent-template/generate` with the user's chosen name as a **private** repo under the user's account.
4. The wizard writes the initial `config.toml`, `workspace/IDENTITY.json`, avatar, etc. and pushes to the new repo.
5. The running agent clones the repo to `~/.pioneer/agents/<agent-id>/` and treats it as source of truth.
6. Agent self-improvement happens through **pull requests on its own repo** — proposed by the agent, reviewed and merged by the owner through the Pioneer Desktop UI (AlphaFlow pattern).

## Repository layout

```
.
├── config.toml.example          Runtime config (provider, auth, autonomy, gateway, memory)
├── .env.example                 Secrets template — real .env is NEVER committed
├── .gitignore                   Excludes all runtime state + any .env file
├── workspace/
│   ├── SOUL.md                  Governance tier — agent CANNOT self-modify
│   ├── IDENTITY.json            AIEOS identity schema (name, psychology, linguistics, etc.)
│   ├── AGENT_BRIEFING.md        Environment + APIs the agent has access to
│   └── MEMORY_POLICY.md         What can be distilled to markdown and committed
├── tools.d/
│   ├── registry.toml            Tool groups, progressive disclosure, health checks
│   └── README.md                How to add a new tool fragment
├── skills/
│   └── README.md                How to add a SKILL.md (each skill is a directory)
├── .github/workflows/
│   ├── validate-config.yml      TOML + AIEOS schema validation on every PR
│   └── review-pr.yml            Hook for agent-reviewed PRs (optional)
├── Dockerfile.example           Containerization starting point
└── entrypoint.sh.example        Merges tools.d/ fragments and launches zeroclaw
```

## Three self-modification tiers

| Tier | Files | Who writes |
|------|-------|------------|
| **Governed** (immutable) | `workspace/SOUL.md`, `workspace/MEMORY_POLICY.md` | Owner only. Agent is blocked at the filesystem level. |
| **PR-gated** (mutable with review) | `workspace/IDENTITY.json`, `workspace/AGENT_BRIEFING.md`, `tools.d/*`, `skills/*`, `config.toml` | Agent proposes via PR. Owner merges in Pioneer Desktop UI. |
| **Ephemeral** (gitignored) | `workspace/memory/`, `workspace/state/`, `workspace/cron/`, `*.sqlite*` | Agent writes freely. Derivable from markdown if needed. |

## What is NOT in this repo

- **Never**: `.env`, API keys, JWTs, wallet private keys, SSH keys — these live in the Pioneer vault.
- **Never**: compiled binaries (`zeroclaw`, etc.) — fetched from release artifacts at runtime.
- **Never**: `workspace/memory/brain.db` — SQLite vector store, rebuildable from markdown.

## Bootstrap locally (development only)

```bash
cp config.toml.example config.toml
cp .env.example .env          # fill in keys
# edit workspace/IDENTITY.json to taste
./entrypoint.sh
```

## License

MIT.
