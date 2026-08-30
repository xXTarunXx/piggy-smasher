# Step 2 — Juice pass (the headline feature)

## Goal
Make hitting and breaking a piggy feel genuinely satisfying. This is the core selling point of the project — spend real effort here before adding more content.

## Build this
1. **Layered hit audio**: on each hit, play an impact sound. On piggy destruction, play a distinct "break" sound plus a coin-cascade sound. Randomize pitch slightly (~±10%) on each play so repeated hits don't sound identical.
2. **Particle burst**: a small particle effect (CPUParticles2D or GPUParticles2D) on hit, a bigger/different one on destruction.
3. **Hit-stop**: a brief (~0.03–0.06s) time-scale dip (`Engine.time_scale`) on hit, restored immediately after.
4. **Screen shake**: a small camera shake on hit, larger on destruction. Keep it subtle — punchy, not disorienting.
5. **Coin "physics" feel**: coins should scatter/bounce outward when spawned (a short tween arc, or a lightweight RigidBody2D) rather than appearing instantly in the counter.

## Done when
Hitting a single piggy repeatedly feels noticeably good — sound, particles, shake, and coin scatter all fire together and don't feel repetitive after a dozen hits in a row. If it doesn't feel satisfying yet, flag that rather than moving on.

## Notes
- Use placeholder CC0 sounds per the project rules — don't block this step on finding "perfect" audio.
- Expose shake intensity, hit-stop duration, and particle count as tunable variables rather than hardcoded values — we'll want to adjust these by feel.
