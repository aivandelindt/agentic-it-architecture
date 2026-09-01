<!-- diagram-design-profile
name: Deloitte Nederland
slug: deloitte-nl
source-url: https://deloitte.nl
created: 2026-08-31
updated: 2026-08-31
notes: Onboarded from deloitte.nl and deloitte.com/nl
-->
# Style Guide

**The single source of truth for colors, typography, and tokens.** Every diagram draws from this — not from hex values inlined in other reference files. If you want to change the visual skin of Diagram Design, change this file.

Active skin: **Deloitte Nederland** — pure-white canvas, true-black ink, Deloitte Green focal accent, teal interactive links. Onboarded from [deloitte.nl](https://deloitte.nl).

To generate your own from a website URL, see [`onboarding.md`](onboarding.md).

---

## Tokens

### Semantic roles

Every token is referred to by **semantic role**, not by its hex value. Type references (`type-*.md`) and SKILL.md say `accent`, not `#86BC25`.

| Role | Purpose | Default (light) | Default (dark) |
|---|---|---|---|
| `paper` | Page background, default node fill | `#ffffff` (white) | `#121212` (black) |
| `paper-2` | Diagram container bg, secondary fill | `#e8eae9` (cool gray 1) | `#1e1e1e` |
| `ink` | Primary text, primary stroke | `#000000` (black) | `#ffffff` (white) |
| `muted` | Secondary text, default arrow stroke | `#63666a` (cool gray 11) | `#d0d0ce` (cool gray 2) |
| `soft` | Sublabels, boundary labels | `#75787b` (cool gray 9) | `#bbbcbc` (cool gray 6) |
| `rule` | Hairline borders | `rgba(0,0,0,0.12)` | `rgba(255,255,255,0.12)` |
| `rule-solid` | Stronger borders, baselines | `#bbbcbc` (cool gray 6) | `rgba(187,188,188,0.25)` |
| `accent` | Focal / 1–2 max per diagram | `#86BC25` (Deloitte Green) | `#9FD044` |
| `accent-tint` | Fill for accent-bordered boxes | `rgba(134,188,37,0.08)` | `rgba(159,208,68,0.10)` |
| `link` | HTTP/API calls, external arrows | `#1076A8` (teal) | `#62B5E5` |

> **Brand palette source:** Deloitte master palette — `black #000000`, `white #ffffff`, `Deloitte Green #86BC25`, `teal #1076A8`, `cool gray 2 #D0D0CE`, `cool gray 6 #BBBCBC`, `cool gray 9 #75787B`, `cool gray 11 #63666A`. Green is reserved for focal accents (logo-period discipline); teal carries interactive and external/API paths.

> **Note:** The pre-baked example HTML files in `assets/` were built under an earlier skin. New diagrams in this project use the Deloitte tokens above.

### Inversion rule (light → dark)

Any `rgba(0,0,0, X)` in light becomes `rgba(255,255,255, X)` in dark. Same opacities, RGB flipped. The accent gets a slight hue-shift brighter to read on dark paper.

### Series palette (multi-series chart types only)

| Token | Light | Dark | Notes |
|---|---|---|---|
| `series-1` | `#43B02A` (green 4) | `#6BC04A` | Non-focal series |
| `series-2` | `#1076A8` (teal) | `#62B5E5` | Non-focal series |
| `series-3` | `#75787b` (cool gray 9) | `#bbbcbc` | Non-focal series |
| `series-4` | `#046A38` (green 6) | `#2C8A5A` | Non-focal series |
| `series-5` | `#53565a` (cool gray 10) | `#97999b` | Non-focal series |

Fills sit at `0.18` opacity light, `0.22` dark; strokes use the full color. **Don't backfill these tokens to non-chart types** — architecture, swimlane, etc. continue to use muted-ink variants.

### Terminal skin (opt-in alternate)

Unchanged from shipped defaults — opt-in CLI chrome, not part of Deloitte onboarding.

| Token | Hex | Purpose |
|---|---|---|
| `terminal-page` | `#0a0a0a` | Page background behind the window |
| `terminal-paper` | `#141414` | Window body, node fill |
| `terminal-bar` | `#1b1b1b` | Titlebar strip |
| `terminal-border` | `#2b2b2b` | Window border, hairlines |
| `terminal-ink` | `#f5f5f5` | Primary text, primary stroke |
| `terminal-muted` | `#9a9a9a` | Secondary text, sublabels, ring stroke |
| `terminal-soft` | `#5c5c5c` | Tertiary — inactive dots, spokes |
| `terminal-accent` | `#ff5a36` | The one accent — focal station, prompt sign, active dot |
| `terminal-accent-tint` | `rgba(255,90,54,0.12)` | Fill for accent-bordered boxes |

---

## Typography

| Role | Family | Size | Weight | Usage |
|---|---|---|---|---|
| `title` | Open Sans | 1.75rem | 300 | Page H1 — light weight per Deloitte web |
| `node-name` | Open Sans | 12px | 600 | Human-readable labels |
| `sublabel` | Geist Mono | 9px | 400 | Port, protocol, URL, field type (fallback — site has no mono) |
| `eyebrow` | Geist Mono | 7–8px | 500, tracked 0.18em, uppercase | Type tags, axis labels |
| `arrow-label` | Geist Mono | 8px | 400, tracked 0.06em | Arrow annotations |
| `callout` | Open Sans *italic* | 14px | 300 | Editorial asides only |

### Font stack

```html
<link href="https://fonts.googleapis.com/css2?family=Open+Sans:ital,wght@0,300;0,400;0,600;0,700;1,300&family=Geist+Mono:wght@400;500;600&display=swap" rel="stylesheet">
```

**Load-bearing rule:** Open Sans carries all human-readable text at Deloitte's light 300 for display and semibold 600 for labels. Mono is for *technical* content only (ports, commands, URLs). Geist Mono is a fallback because deloitte.nl ships no monospace stack. **Never JetBrains Mono** as a blanket "dev" font.

---

## Stroke, radius, spacing

| Token | Value | Use |
|---|---|---|
| `stroke-thin` | `0.8` | Tag-box outlines, leaf nodes |
| `stroke-default` | `1` | Most strokes |
| `stroke-strong` | `1.2` | Emphasis strokes |
| `radius-sm` | `4` | Small tags |
| `radius-md` | `6` | Node boxes |
| `radius-lg` | `8` | Containers, rings |
| `grid` | `4` | Every coord, size, and gap is divisible by 4 (hard rule) |

---

## Node type → treatment

| Type | Fill | Stroke |
|---|---|---|
| `focal` (1–2 max) | `accent-tint` | `accent` |
| `backend` | `#ffffff` (white) | `ink` |
| `store` | `ink @ 0.05` | `muted` |
| `external` | `ink @ 0.03` | `ink @ 0.30` |
| `input` | `muted @ 0.10` | `soft` |
| `optional` | `ink @ 0.02` | `ink @ 0.20` dashed `4,3` |
| `security` | `accent @ 0.05` | `accent @ 0.50` dashed `4,4` |

---

## Customizing the skin

1. **Run onboarding** — see [`onboarding.md`](onboarding.md).
2. **Edit by hand** — change the hex values in the tables above.
3. **Brand handoff** — paste design-token JSON and map to semantic roles.
4. **Client profiles** — save and switch named skins via [`profiles.md`](profiles.md). Active profile: `deloitte-nl`.

### Constraints (don't break these)

- **Contrast**: `ink` must hit WCAG AA on `paper`. `muted` must hit AA on `paper` for 11px+ text.
- **One accent**: Deloitte Green is the sole focal hue. Teal is for links/API paths, not a second accent.
- **Green discipline**: use `#86BC25` on ≤2 focal elements per diagram — same restraint as the wordmark period.
- **Pure white paper**: intentional for Deloitte; do not warm-shift without explicit approval.
