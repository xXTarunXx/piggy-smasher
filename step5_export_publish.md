# Step 5 — Export and publish

## Goal
Get a working build out of the editor and ready for itch.io.

## Build this
1. Confirm Project Settings → Rendering → Renderer is set to **Compatibility** (required for Web export).
2. Install the Web export template if not already present, and configure a Web export preset.
3. Export a Web (HTML5) build into `builds/web/`. Verify it runs correctly when served from a local server (Web exports generally won't run correctly from a plain `file://` path — flag this if it comes up), with no console errors, and confirm audio plays after the first click (browsers block autoplay before user interaction, which should already be satisfied by the title screen's click-to-start).
4. Optionally, also configure a native Desktop export preset into `builds/desktop/` as a stretch goal, since the same GDScript project can target both.

## Done when
The Web build runs cleanly end-to-end (title screen → play → shop → upgrade) when served locally, with no errors in the browser console.

## Not part of this step
Actually uploading to itch.io, writing store page copy, or recording promotional material — those are manual steps outside the editor.
