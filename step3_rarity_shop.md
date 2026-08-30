# Step 3 — Add 2–3 piggy tiers and a tiny shop

## Goal
Turn the single-piggy loop into the actual game concept: rarity and a reason to spend coins.

## Build this
1. **Piggy tiers** (2–3, e.g. Common / Rare, optionally Epic): each with its own HP, coin value on death, color/tint, and a distinct destruction sound so rarity is felt, not just numeric.
2. **Weighted spawner**: update the Step 1 spawner to pick a tier at random using weights, so common piggies appear far more often than rare ones.
3. **Shop UI**: a simple toggleable panel with 2–3 upgrades purchasable with coins:
   - Hit damage +1 per purchase
   - Auto-hit: deals passive damage to the nearest piggy every X seconds
   - Crit chance: % chance a hit deals double damage
4. Each upgrade should cost more per purchase and actually change gameplay when bought, not just look decorative.

## Done when
At least two visibly and audibly distinct piggy tiers spawn and can be defeated, coins can be spent in the shop, and purchased upgrades measurably change how fast piggies go down.

## Explicitly out of scope
More than 3 upgrade types, save/load between sessions, a fourth+ rarity tier. Keep this small — the goal is a complete loop, not a deep one.
