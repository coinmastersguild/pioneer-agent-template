# pioneer-agent-template

Template repository for a Pioneer agent. Every Pioneer agent is backed by a private git repo generated from this template. The repo holds the agent's **identity, values, tools, skills, and briefings** — everything that makes one agent different from another.

> "Soul in git. Working memory on disk. Secrets in the vault."

## How this template is used

1. A user completes Pioneer onboarding.
2. Pioneer authenticates with GitHub on the user's behalf (device-flow OAuth, PAT stored in vault).
3. Pioneer calls `POST /repos/{template_owner}/pioneer-agent-template/generate` with the user's chosen name as a **private** repo under the user's account.
4. The wizard fills in `workspace/IDENTITY.json`, replaces `@OWNER` placeholders in `.github/CODEOWNERS`, and pushes.
5. The running agent clones the repo to `~/.pioneer/agents/<agent-id>/` and treats it as source of truth.
6. Agent self-improvement happens through **pull requests on its own repo** — proposed by the agent, reviewed and merged by the owner through the Pioneer Desktop UI (AlphaFlow pattern).

## Repository layout

```
.
├── config.toml                  Runtime config (provider, auth, autonomy, gateway, memory)
├── .env.example                 Local-dev bootstrap only — real .env is NEVER committed
├── .gitignore                   Excludes all runtime state + any .env file + fetched binaries
├── workspace/
│   ├── SOUL.md                  Governance tier — agent CANNOT self-modify
│   ├── IDENTITY.json            AIEOS identity schema (name, psychology, linguistics, etc.)
│   ├── AGENT_BRIEFING.md        Environment + APIs the agent has access to
│   ├── MEMORY_POLICY.md         What can be distilled to markdown and committed
│   ├── credentials.yaml         Machine-readable map of vault keys this agent needs
│   └── notes/                   Long-term owner-reviewed memory (PR-gated)
│       ├── findings/            Incident reports, security findings, audit conclusions
│       └── patterns/            Distilled reusable knowledge
├── branding/
│   ├── theme.json               Per-agent colors, name, asset paths (CI-validated)
│   ├── logo.svg                 Header logo
│   ├── favicon.svg              Browser tab icon
│   ├── avatar.svg               Portrait used in chat bubbles
│   └── README.md                Schema + runtime-theming model
├── tools.d/
│   ├── registry.toml            Tool groups, progressive disclosure, health checks
│   └── README.md                How to add a new tool fragment
├── skills/
│   └── README.md                How to add a SKILL.md (each skill is a directory)
├── .github/
│   ├── CODEOWNERS               Enforces the three-tier model via PR review
│   └── workflows/
│       └── validate-config.yml  TOML + JSON + YAML validation + "no .env" guard
├── Dockerfile                   Multi-stage build (release or local binary source)
└── entrypoint.sh                Merges tools.d/ fragments and launches zeroclaw
```

## Three self-modification tiers

| Tier | Files | Who writes |
|------|-------|------------|
| **Governed** (immutable) | `workspace/SOUL.md`, `workspace/MEMORY_POLICY.md`, `.github/CODEOWNERS`, `.github/workflows/` | Owner only. CODEOWNERS blocks agent-authored PRs. |
| **PR-gated** (mutable with review) | `workspace/IDENTITY.json`, `workspace/AGENT_BRIEFING.md`, `workspace/credentials.yaml`, `workspace/notes/**`, `tools.d/*`, `skills/*`, `config.toml` | Agent proposes via PR. Owner merges in Pioneer Desktop UI. |
| **Ephemeral** (gitignored) | `workspace/memory/`, `workspace/state/`, `workspace/cron/`, `*.sqlite*`, any `.env` | Agent writes freely. Derivable from markdown if needed. |

## What is NOT in this repo

- **Never**: `.env`, API keys, JWTs, wallet private keys, SSH keys — these live in the Pioneer vault.
- **Never**: compiled binaries (`zeroclaw`, etc.) — Docker build fetches them at image build time.
- **Never**: `workspace/memory/brain.db` — SQLite vector store, rebuildable from markdown.

## Credentials

Tools declare the vault keys they need via `vault_key = "<name>"` in their `tools.d/*.toml` fragment. The full catalog for an agent lives in `workspace/credentials.yaml` — a non-secret declaration of what the agent needs to operate.

The Pioneer Desktop wizard reads `credentials.yaml` on first run to prompt for each key, stores the values in the vault, and serves them to the agent on demand via the local gateway. Secrets never appear in this repo, in environment variables, or in image layers.

## Build locally

The Dockerfile supports two binary sources — pick based on whether the `pioneer-platform` release repo is public to you.

```bash
# A. Release fetch (default). Private repo? Pass --secret with a token.
export GH_TOKEN="$(gh auth token)"
DOCKER_BUILDKIT=1 docker build \
  --secret id=gh_token,env=GH_TOKEN \
  --build-arg ZEROCLAW_VERSION=v0.1.0 \
  -t my-agent .

# B. Pre-fetched binary (faster on Apple Silicon).
gh release download v0.1.0 \
  --repo coinmastersguild/pioneer-platform \
  --pattern zeroclaw-linux-amd64 \
  -O ./zeroclaw
docker build --build-arg ZEROCLAW_SOURCE=local-binary -t my-agent .
```

`./zeroclaw` is in `.gitignore` — it will never be committed.

## Run locally (no container)

```bash
cp .env.example .env             # fill in any dev overrides
# edit workspace/IDENTITY.json
./entrypoint.sh                  # needs `zeroclaw` on PATH
```

## License

MIT.
