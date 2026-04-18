# branding/

Per-agent visual identity. The running agent serves this directory at
`/branding/*`; the Pioneer UI fetches `/branding/theme.json` at boot,
applies CSS custom properties, and swaps logo + favicon + document title.

## Files

| File | Purpose | Format |
|------|---------|--------|
| `theme.json` | Agent name, colors, mode, asset paths | JSON (strict schema — CI validates) |
| `logo.svg` | Header logo — appears top-left in the UI | SVG, recommended viewBox 0 0 240 60 |
| `favicon.svg` | Browser tab icon | SVG, viewBox 0 0 64 64 |
| `avatar.svg` | Agent portrait used in chat bubbles | SVG, viewBox 0 0 128 128 |

SVG is preferred everywhere — scales cleanly, tiny over the wire, easy
to version-diff. PNGs work too (PUT in paths in `theme.json` → `assets`).

## theme.json schema

```json
{
  "name":        "Pioneer Scanner",       // full name shown in UI
  "short_name":  "Scanner",               // compact form (title bar)
  "tagline":     "Whitehat contract scanner",
  "mode":        "dark",                  // "dark" | "light" | "system"
  "colors": {
    "primary_400": "#…",
    "primary_500": "#…",
    "primary_600": "#…",
    "accent":       "#…",
    "accent_hover": "#…",
    "bg":           "#…",
    "bg_surface":   "#…",
    "bg_elevated":  "#…",
    "border":       "#…",
    "text":         "#…",
    "text_muted":   "#…",
    "danger":       "#…",
    "warn":         "#…"
  },
  "assets": {
    "logo":    "/branding/logo.svg",
    "favicon": "/branding/favicon.svg",
    "avatar":  "/branding/avatar.svg"
  }
}
```

All color values must be `#RRGGBB` or `#RRGGBBAA` — CI rejects named
colors and `rgb(...)` forms because they behave differently across the
theme switch.

## Runtime model

1. Gateway (zeroclaw) serves `workspace/../branding/*` (this directory is
   one level above `workspace/` so branding lives at the agent repo root).
2. Pioneer UI on boot: `fetch('/branding/theme.json')`.
3. For each `colors.*` entry, set the matching CSS custom property on
   `document.documentElement`: `--pioneer-400`, `--accent`, etc.
4. Swap `document.title = theme.name`.
5. Rewrite the `<link rel="icon">` href to `assets.favicon`.
6. Re-render the logo `<img src=…>` with `assets.logo`.

If `theme.json` is missing or malformed, the UI keeps the built-in
defaults and logs a single warning.

## Editing

- Owner-editable directly in git.
- Agent may propose updates via PR (e.g. to improve avatar art) but may
  NOT modify `name`, `short_name`, or identity-bound fields without
  explicit owner review — CODEOWNERS enforces this for the whole dir.
