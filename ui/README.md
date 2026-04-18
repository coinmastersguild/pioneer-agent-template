# ui/

Pre-built Pioneer UI bundle. Empty in the template; populated by the
onboarding wizard (or manually for now).

## Populate manually (until wizard lands)

```bash
# from the pioneer-agent repo root:
cd projects/pioneer-agent/pioneer-ui
make build                        # or: bun run build
cd -

# copy dist into this agent repo's ui/:
rsync -a --delete \
  projects/pioneer-agent/pioneer-ui/dist/ \
  ~/.pioneer/agents/<your-agent>/ui/
```

## Why is it in git?

So the Dockerfile can `COPY ui/ /app/ui/` without needing a separate
fetch step at build time. Bundle is static (HTML/JS/CSS) and small;
the scanner dist is ~200 KB gzipped.

If you prefer to keep bundles out of git, add `ui/` to `.gitignore`
and tweak the Dockerfile to fetch from a release artifact instead.

## What's inside

The agent expects:
- `index.html` — entrypoint
- `assets/*` — JS / CSS chunks
- `favicon.svg` — fallback favicon (runtime branding loader overrides)

On boot the UI fetches `/branding/theme.json` from the gateway and
applies the agent's colors, name, logo, and favicon.
