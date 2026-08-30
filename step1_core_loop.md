# Step 1 — Build the bare loop

## Goal
Prove out the core click-to-currency loop. No art polish, no sound, no rarity — just one piggy type and the mechanic working end to end.

## Build this
1. A `Piggy` scene: a clickable 2D node (Sprite2D + Area2D/CollisionShape2D is fine) with an `hp` value (start at 3).
2. Clicking the piggy reduces `hp` by 1. At `hp <= 0`, the piggy is removed from the scene and triggers a coin reward.
3. A basic click-on-the-piggy interaction is enough for this step; a cursor-following hammer sprite can come later and isn't required to call this step done.
4. A currency system (autoload/global script) holding the current coin total, incremented when a piggy is destroyed.
5. A UI `Label` showing the current coin total, updating live.
6. A basic spawner: when a piggy is destroyed, spawn a new one after a short delay so play can continue.

## Done when
- Clicking a piggy repeatedly reduces its HP and it disappears after 3 hits.
- Coin count visibly increases each time a piggy is destroyed.
- A new piggy appears after the old one is gone.

## Explicitly out of scope for this step
Sound, particles, screen shake, multiple piggy tiers, a shop, a title screen. The next step is entirely about feel — it's easier to layer that onto a working loop than build both at once.
