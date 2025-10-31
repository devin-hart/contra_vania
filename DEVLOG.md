# Contra-Vania DEVLOG

## PROJECT OVERVIEW
**Engine:** LOVE2D  
**Style:** 2D side-scroller — a fusion of *Contra* and *Castlevania* with an 80s action-movie tone.  
**Visual Target:** Sega Genesis-era graphics (low resolution, sharp pixels, limited palette).  
**Goal:** Build a modular, clean codebase focused on speed, clarity, and quick iteration.  

**Design Principles**
- Build one feature at a time — no boilerplate, no premature structure.  
- Keep every file focused and replaceable.  
- Maintain exhaustive documentation here so another session (or developer) can continue seamlessly.  
- Integrate debugging and live feedback from day one.  

**How to run**

    love .

**Live reload**

    find . -type f -name '*.lua' | entr -cdr sh -c 'love "$(pwd)"'

---

## CHANGELOG

### [2025-10-31] — Project Initialization
**Summary**  
Created base folder and empty files to start the project cleanly.

**Details**

    mkdir contra_vania && cd contra_vania && touch main.lua cv_debug.lua DEVLOG.md

**Files created**
- `main.lua` — will contain the base LOVE2D loop.  
- `cv_debug.lua` — will handle overlays, logging, and safe error handling.  
- `DEVLOG.md` — this file, serving as a long-form gitlog and session record.  

**Development Tools**  
Live reload set up using `entr`:

    find . -type f -name '*.lua' | entr -cdr sh -c 'love "$(pwd)"'

This allows real-time refresh on file save without touching in-game code yet.

**Next Steps**
1. Build the minimal `main.lua`: window, resolution (320×180), integer scaling.  
2. Implement `cv_debug.lua` overlay and logger.  
3. Verify reload command works smoothly.  
4. Add player stub in next phase.  

---

### [2025-10-31] — Step 2: Minimal Loop + Debug Overlay
**Summary**  
Created a functional LOVE2D skeleton with a 320×180 logical resolution, integer scaling, and a toggleable debug overlay.

**Files Added / Modified**
- `main.lua` — initializes window, canvas, draw loop, and input handling.  
- `cv_debug.lua` — handles FPS/memory overlay, logging, and file dump.  

**Changes**
- Integer scaling preserves Genesis-style pixel sharpness.  
- `F1` toggles overlay visibility, `F2` dumps logs, `ESC` quits.  
- Overlay shows FPS, frame time, memory usage, recent logs.  
- Log ring buffer size 200; writes to `debug_log.txt` on dump.  

**Controls**
- F1 — toggle debug overlay  
- F2 — dump log  
- ESC — quit  

**Notes**
- Overlay renders in window space, not scaled canvas.  
- Nearest-neighbor filter keeps crisp pixels.  



**Next Steps**
1. Add `player.lua` stub (movement + jump).  
2. Integrate with `main.lua`.  
3. Document player step in next entry.  

---

### [2025-10-31] — Step 3: Player Stub (Move + Jump)
**Summary**  
Added a minimal `player.lua` with left/right movement, jump, gravity, and a flat floor; hooked into the main loop.

**Changes**
- New file: `player.lua` (`Player.new(world)`, `:update(dt)`, `:keypressed(key)`, `:draw()`).  
- `main.lua`: required `player`, created `world = { W, H, floor }`, spawned `player`, forwarded `keypressed`, drew floor and player.  
- Debug log now notes player init on boot.  

**Controls**
- Left/Right or A/D — move  
- Up/W/Space — jump  
- F1 — toggle overlay  
- F2 — dump log  
- ESC — quit  

**Notes**
- Simple physics (no acceleration or coyote time yet).  
- Flat floor at `H − 20`.  
- Horizontal movement clamped to screen bounds.  



**Next Steps**
1. Add `config.lua` to centralize constants (keys, speeds, colors).  
2. Add a camera stub + parallax background placeholder.  
3. Replace rectangle player with a 2–3 frame sprite (keep nearest filter).  

### [2025-10-31] — Step 4: Config + Camera Integration

**Summary**

Introduced `config.lua` for centralized tuning and `camera.lua` for simple world scrolling.  
Game now scrolls horizontally as the player moves; scaling, physics, and color palettes are unified.

**Changes**

- Added `config.lua` containing constants for resolution, world bounds, physics, and palette.  
- Added `camera.lua` to track player position and clamp view to world width.  
- Updated `player.lua` to use config constants instead of hard-coded values.  
- Updated `main.lua` to require new modules, initialize camera, and draw world with scrolling floor.

**Controls**

- Left/Right or A/D — move  
- Up/W/Space — jump  
- F1 — toggle debug overlay  
- F2 — dump log  
- ESC — quit  

**Notes**

- Camera tracks player horizontally and clamps to `WORLD_WIDTH`.  
- Colors and physics can be tuned entirely from `config.lua`.  
- Debug overlay remains global, unchanged from Step 2.  



**Next Steps**

1. Add `config.lua` constants for inputs and UI colors.  
2. Introduce `src/viewport.lua` to modularize canvas and scaling logic.  
3. Add background parallax layer to test camera motion.

### [2025-10-31] — Step 5: Viewport Module

**Summary**

Moved all rendering-scale logic into `src/viewport.lua`.  
`main.lua` now delegates canvas creation, scaling, and centering to the new module, simplifying further visual work.

**Changes**
- Added `src/viewport.lua` with `begin()`, `finish()`, `updateScale()` functions.  
- Removed canvas, scale, and integer-scaling math from `main.lua`.  
- `main.lua` now only calls `viewport:begin()` and `viewport:finish()` around draw code.

**Notes**
- The viewport manages its own canvas and handles window resizing.  
- All color clears now occur inside `Viewport:begin()`.  
- Future additions (parallax, UI overlays, post-processing) will hook in cleanly here.

**Next Steps**
1. Add background parallax layer using camera offset.  
2. Implement `src/input.lua` for unified input handling.  
3. Begin rough UI/HUD mock-ups to test scaling and font clarity.

### [2025-10-31] — Step 6: Parallax Background

**Summary**

Added a procedural parallax background with layered hill geometry to give depth and motion to the world.  
This marks the first visual environment feature beyond flat colors.

**Changes**

- Added `src/background.lua` — draws sky and two hill layers with sine-based geometry.  
- Updated `config.lua` — added sky, hill, and parallax color definitions; defined parallax speed factors.  
- Updated `main.lua` — renders background before camera draw calls.  
- Integrated background into existing viewport system for proper scaling.  

**Notes**

- The sky is now the clear color; far and near hill layers scroll at 0.3× and 0.6× camera speed respectively.  
- The parallax effect is achieved purely through procedural vertex generation (no textures yet).  
- Player, floor, and UI remain unaffected by the new background draw order.  
- All colors and speeds are configurable from `config.lua`.



**Next Steps**

1. Add `src/layers.lua` to centralize draw ordering for background, entities, and UI.  
2. Replace the player rectangle with a small animated sprite (3–4 frames).  
3. Add subtle gradient animation to the sky to test color interpolation.

### [2025-10-31] — Step 7: Draw Layer System

**Summary**

Implemented a lightweight draw-layer manager to centralize render order and simplify future expansion.  
This ensures that background, world, and UI elements render consistently without direct ordering in `main.lua`.

**Changes**

- Added `src/layers.lua` — manages ordered draw calls through `Layers.begin()`, `Layers.add()`, and `Layers.draw()`.  
- Updated `main.lua` — replaced direct draw calls with layer-based registration for background, world, and UI.  
- Retained existing debug overlay and viewport integration.  

**Notes**

- Layers are executed in fixed order: `background → world → ui`.  
- The world layer automatically applies and clears the active camera.  
- System is designed to scale easily (add `effects`, `projectiles`, `hud`, etc. as new layers).  
- No visible change in rendering — purely structural for clarity and maintainability.  



**Next Steps**

1. Add `src/input.lua` to manage key states (pressed, held, released).  
2. Replace the player rectangle with a small animated sprite.  
3. Begin integrating sound and texture assets under `assets/`.

### [2025-10-31] — Step 8: Input System

**Summary**

Introduced a centralized input manager to replace direct keyboard polling.  
This provides clean, consistent handling for pressed, held, and released keys, and allows for easy future remapping.

**Changes**

- Added `src/input.lua` — manages key states, bindings, and edge detection.  
- Updated `main.lua` — removed direct key polling; forwards all key events through `Input`.  
- Updated `player.lua` — player logic now receives input context via `player:update(dt, Input)`.  
- Simplified jump handling to edge-triggered (`wasPressed("jump")`).  

**Notes**

- Default bindings include `left/right/jump/debug/dump/quit`.  
- Input state is refreshed each frame in `love.update()`.  
- Actions can be rebound easily using `Input.bind()` or `Input.setBindings()`.  
- Debug overlay and quit handling are now action-based rather than raw key checks.



**Next Steps**

1. Replace placeholder player rectangle with sprite animation (idle, run, jump).  
2. Expand input system with controller/gamepad support.  
3. Begin adding placeholder sound effects for jump and land events.

### [2025-10-31] — Step 9: Animated Player System

**Summary**

Replaced the static player rectangle with a lightweight animation system.  
The player now has distinct idle, run, and jump states represented through color-cycling placeholder frames.  
This establishes the core animation framework for future sprite integration.

**Changes**

- Added `src/anim.lua` — self-contained animation module supporting both image-based and procedural frame cycling.  
- Updated `player.lua` — added state handling (`idle`, `run`, `jump`) and directional facing.  
- Integrated procedural fallback frames for visual feedback without external assets.  
- Updated `config.lua` — added animation speed constants (`C.ANIM.idle`, `C.ANIM.run`, `C.ANIM.jump`).  

**Notes**

- Animation cycles through placeholder colors for each state:
  - Idle: slow color shift.
  - Run: fast color cycling to simulate movement.
  - Jump: quick color flash (non-looping).
- A thin stripe indicates facing direction (mirrors horizontally when turning).  
- System supports sprite sheets (horizontal strips) with frame slicing via `love.graphics.newQuad`.



**Next Steps**

1. Add sprite loading from `assets/gfx/player/` and integrate with `anim.lua`.  
2. Implement landing and jump apex detection for smoother transitions.  
3. Begin sound hooks for jump and land events.

### [2025-10-31] — Step 10: Sprite Integration

**Summary**

Replaced the procedural color-block player with a modular sprite system.  
The game now supports external sprite sheets for idle, run, and jump states while maintaining a fixed gameplay collider.  
If no sprite is found, it safely falls back to the old procedural visuals.

**Changes**

- Added `src/assets.lua` — lightweight asset loader with caching and optional image loading.  
- Updated `player.lua` — now builds animations from loaded sprite sheets; procedural mode remains for missing assets.  
- Updated `config.lua` — introduced `C.SPRITES` definitions for file paths, frame sizes, and frame counts.  
- Adjusted `camera.lua` — made compatible with the new pivot-and-collider player model.  
- Added optional `dbg.log("assets")` call in `love.load()` for verifying successful sprite loads.

**Notes**

- Sprite strips must be horizontal (1 row).  
- Each animation’s frames must share identical width/height and total width = `frameW × frames`.  
- Default player sprite size now: `24 × 35 px`.  
- Gameplay collider is fixed (`20 × 30 px`) and independent of art.  
- Live reload automatically re-reads changed sprite sheets.

**Next Steps**

1. Add idle and jump animations using the same strip format.  
2. Implement a pivot-based anchor system to handle varying frame widths.  
3. Add a visible debug toggle for hitboxes and pivot alignment.

### [2025-10-31] — Step 11: Idle/Jump Sprite Adjustments

**Summary**

Adjusted animation frame counts and dimensions to match Contra art.  
Idle now uses 2 frames, Run remains 6, and Jump uses 4 frames at a smaller per-frame size (22×20) while keeping the fixed gameplay collider.

**Changes**

- `config.lua`
  - `C.SPRITES.player.idleFrames = 2`
  - `C.SPRITES.player.runFrames  = 6` (unchanged)
  - `C.SPRITES.player.jumpFrames = 4`
  - Added per-animation sizing for jump:
    - `C.SPRITES.player.jumpFrameW = 22`
    - `C.SPRITES.player.jumpFrameH = 20`

- `player.lua`
  - Jump animation now reads dedicated dimensions:
    - `frameW = cfg.SPRITES.player.jumpFrameW or cfg.SPRITES.player.frameW`
    - `frameH = cfg.SPRITES.player.jumpFrameH or cfg.SPRITES.player.frameH`
  - Idle/Run continue to use the default `frameW=24`, `frameH=35`.

**Notes**

- Expected strip sizes:
  - `assets/gfx/player/idle_strip.png` → 48×35 (24×35 × 2)
  - `assets/gfx/player/run_strip.png`  → 144×35 (24×35 × 6)
  - `assets/gfx/player/jump_strip.png` → 88×20 (22×20 × 4)
- Feet/pivot alignment unchanged; the fixed collider (`20×30`) remains independent of sprite size.
- Optional pacing (tunable in `C.ANIM`):
  - `idle = 3`, `run = 8–10`, `jump = 8`

**Next Steps**

1. Export/verify `idle_strip.png` (2 frames, 24×35) and `jump_strip.png` (4 frames, 22×20).  
2. (Optional) Add F3 toggle to show/hide hurtbox independently from the debug overlay.  
3. Begin apex/landing polish (coyote time, landing state, SFX hooks).

