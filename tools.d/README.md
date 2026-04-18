# tools.d/

HTTP tool definitions. Each `.toml` file is a **fragment** — merged into the
agent's config at startup. Split by domain (one file per logical tool group).

## Adding a new tool fragment

1. Create `tools.d/<domain>.toml` (e.g. `tools.d/analytics.toml`).
2. Add one or more `[[http_tools]]` entries:

```toml
[[http_tools]]
name = "kpi_summary"
method = "GET"
url = "http://keepkey-admin:3000/api/kpi/summary"
description = "All KPIs in one call. Use this first when asked about metrics."
auth_header = "X-Service-API-Key"
auth_env = "ADMIN_API_KEY"

[[http_tools.params]]
name = "range"
in = "query"
required = false
description = "Time range: 24h | 7d | 30d | this-month | last-month | all"
default = "7d"
```

3. Register the tool in a group in `registry.toml`:

```toml
[registry.groups]
analytics = { tools = ["kpi_summary"], description = "Metrics & KPIs" }
```

4. Open a PR. Validation runs in CI (TOML lint + name uniqueness check). On
   merge, next agent restart picks the tool up.

## Rules

- **Names are globally unique** across all fragments. Validation enforces this.
- **No secrets in these files.** Reference them via `auth_env = "…"` — values
  come from env at runtime.
- **Keep descriptions concrete.** The model picks tools off the description.
  "Get stats" is bad. "Return users, dApps, assets, blockchains, downloads"
  is good.
- **Test locally before PR.** `zeroclaw --dry-run --tool <name>` validates the
  fragment.

## Progressive disclosure

The agent won't see every tool all the time. It asks for a group and only
those tools are injected. Groups are cheap; make lots of small ones rather
than one big one.
