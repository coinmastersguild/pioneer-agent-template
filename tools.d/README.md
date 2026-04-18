# tools.d/

HTTP tool definitions. Each `.toml` file is a **fragment** — merged into the
agent's config at startup. Split by domain (one file per logical tool group).

## Adding a new tool fragment

1. Create `tools.d/<domain>.toml` (e.g. `tools.d/analytics.toml`).
2. Add one or more `[[http_tools]]` entries:

```toml
[[http_tools]]
name = "reports_summary"
method = "GET"
url = "https://api.example.com/v1/reports/summary"
description = "Return a compact summary of the last N days of activity. Use this first when the user asks about metrics."

# Credential handling — pick ONE of these patterns:
#
#  • vault_key: the agent asks Pioneer Desktop to resolve this key from the
#    vault at call time. The secret never lives on this agent's disk.
#    This is the recommended pattern for production.
vault_key = "reports_api_key"
auth_header = "X-Service-API-Key"
#
#  • auth_env: use an env var. Only appropriate for local dev or when the
#    agent genuinely owns the credential (rare). Uncomment to use:
# auth_env = "REPORTS_API_KEY"

[[http_tools.params]]
name = "range"
in = "query"
required = false
description = "Time range: 24h | 7d | 30d | all"
default = "7d"
```

3. Register the tool in a group in `registry.toml`:

```toml
[registry.groups]
reports = { tools = ["reports_summary"], description = "Activity & reporting" }
```

4. Open a PR. Validation runs in CI (TOML lint + name uniqueness check). On
   merge, next agent restart picks the tool up.

## Rules

- **Names are globally unique** across all fragments. Validation enforces this.
- **No secrets in these files.** Reference them via `vault_key = "…"` — the
  agent resolves the value against Pioneer Desktop's vault at call time.
  Never paste real tokens into tool fragments, even in `auth_env` form.
- **Keep descriptions concrete.** The model picks tools off the description.
  "Get stats" is bad. "Return users, dApps, assets, blockchains, downloads"
  is good.
- **Test locally before PR.** `zeroclaw --dry-run --tool <name>` validates the
  fragment.

## Where do credentials come from?

Tools never carry their own secrets. Three sources, in order of preference:

1. **Pioneer Desktop vault** — `vault_key = "<name>"` on the tool; the agent
   asks the gateway for the value right before the call. Secret never
   touches this repo or the agent's filesystem.
2. **Swarm request** — for capabilities another agent in the swarm owns,
   delegate to that agent rather than trying to hold the credential
   yourself.
3. **Local env var** — `auth_env = "<VAR>"`. Only for local development or
   when the agent genuinely owns the credential outright.

## Progressive disclosure

The agent won't see every tool all the time. It asks for a group and only
those tools are injected. Groups are cheap; make lots of small ones rather
than one big one.
