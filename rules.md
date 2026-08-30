# Project Rules — Piggy Smasher (working title)

## What this is
A small solo portfolio prototype: click/smash moving piggy banks with a hammer, they drop coins, coins buy upgrades, rarer piggies are tougher but worth more. Priority is a fast, complete, satisfying loop — not scope.

## Engine & language
- Godot 4.x, **GDScript only** — not C#. Godot 4's C# (.NET) build currently cannot export to Web, and a browser build is a target for this project, so GDScript is a hard requirement here, not a style preference.
- 2D project. Renderer set to **Compatibility** (Project Settings → Rendering → Renderer) from the start — it's the only renderer Web export supports, and switching later can change how sprites/lighting look.

## Folder structure
- `scenes/` — one `.tscn` per major object (Piggy.tscn, Hammer.tscn, Coin.tscn, UI screens)
- `scripts/` — matching `.gd` files, same name as the scene they control
- `assets/sprites/`, `assets/audio/`, `assets/fonts/`
- `builds/web/`, `builds/desktop/` — export output, not source

## Conventions
- snake_case for file/variable names, PascalCase for node/class names.
- Keep scripts small and single-purpose — a Piggy script shouldn't also manage the shop.
- Comment non-obvious logic (damage falloff, spawn weighting, upgrade math); skip comments on self-explanatory code.
- Prefer built-in Godot nodes over plugins/addons unless a step explicitly calls for one. No new dependencies without flagging it first.

## Art & audio for this prototype
- Placeholder-first: simple shapes/primitives or free CC0 packs (e.g. Kenney assets) are fine. This is a feel/mechanics prototype, not a visual showcase — don't spend time on custom art.
- Same logic for audio: free CC0/CC-BY SFX (freesound.org, Kenney audio packs) are fine as placeholders.

## Core loop (do not exceed scope without asking)
Hammer click on a piggy → piggy takes a hit → HP depletes → at 0 HP the piggy is removed and spawns coin(s) → coin total updates in UI. Rarer piggies have higher HP, higher coin value, and a distinct color and sound. Coins are spent in a small shop for permanent upgrades (hit damage, auto-hit tick, crit chance).

## Working style
- Each task is scoped intentionally small. Don't add a later step's features while working on an earlier one, even if it seems convenient.
- If something is ambiguous or not covered here — especially anything touching file structure or export settings — ask rather than assume.
- End each task by stating clearly what was built and what wasn't, so the next task can pick up accurately.
