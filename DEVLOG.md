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

### [2025-10-31] — Step 12: Enemy Framework

**Summary**

Introduced a modular enemy system with pivot-based positioning and fixed colliders.  
Enemies can patrol between two X points, reversing direction automatically, and render within the existing layer and debug systems.  
The framework is built to scale — future enemies can inherit and extend this class.

**Changes**

- Added `src/enemy.lua`
  - Supports pivot-at-feet model identical to the player.
  - Includes fixed hurtbox collider (`cw/ch`) independent of sprite art.
  - Handles patrol logic with speed and direction switching.
  - Uses animation fallback if sprites are missing.
  - Displays debug collider boxes when the overlay (F1) is active.

- Updated `main.lua`
  - Added enemy management (`enemies` table).
  - Spawned two sample patrolling enemies in `love.load()`.
  - Integrated updates and rendering through the `world` layer (after player draw).

**Notes**

- Enemies currently move horizontally along the floor; physics is not yet applied.  
- Sprite paths: `assets/gfx/enemy/idle_strip.png` and `assets/gfx/enemy/walk_strip.png` (optional).  
- Default collider: 14×14 px; configurable through `cfg.ENEMY.COLLIDER`.  
- Procedural color fallback displays if no sprite sheet is found.

**Next Steps**

1. Implement player–enemy collision detection (basic hit/hurt interactions).  
2. Add projectile and damage responses.  
3. Create distinct enemy archetypes (stationary, airborne, melee).  
4. Add idle and attack animation strips for enemy sprites.

### [2025-10-31] — Step 13: Projectile System

**Summary**

Implemented a modular projectile system for player firing.  
Pressing the **Shoot** key (default: `J`, `K`, or `Left Ctrl`) spawns a fast-moving bullet that travels in the facing direction, auto-expiring after a short lifespan.  
The system is lightweight, modular, and fully integrated with the update/draw loop and debug overlay.

**Changes**

- Added `src/projectile.lua`
  - Defines a standalone `Projectile` class with position, direction, velocity, and lifetime.
  - Handles its own update and draw logic.
  - Uses a simple rectangle visual (6×2 px) tinted `accent` color.

- Updated `config.lua`
  - Added new `C.PROJ` block defining projectile properties:
    - `w`, `h`, `speed`, `life`, `muzzleX`, `muzzleY`.

- Updated `src/input.lua`
  - Added a new `shoot` action binding (`j`, `k`, `lctrl`).

- Updated `src/player.lua`
  - Added `getMuzzle()` helper to calculate the bullet’s spawn offset from the player’s current pivot and facing direction.

- Updated `main.lua`
  - Added `bullets` table.
  - Spawn bullets on `Input.wasPressed("shoot")`.
  - Updated bullets each frame and removed expired ones.
  - Drew bullets in the world layer before the player and enemies.

**Notes**

- Bullets inherit facing direction and travel horizontally at a constant velocity (`speed = 260 px/s`).  
- Each projectile self-destructs after `life = 0.9s`.  
- Collider size (`6×2`) defined in `C.PROJ` — ready for collision detection next step.  
- Fully compatible with the debug overlay and live reload workflow.

**Next Steps**

1. Implement basic player–enemy projectile collision detection.  
2. Add simple explosion / impact animation on hit.  
3. Introduce firing cooldown or weapon variants (spread, laser, etc.) later.

### [2025-10-31] — Step 14.1: Enemy Collider + Visual Alignment

**Summary**

Synced enemy visuals with their updated collider height to ensure bullets visibly connect with enemies.  
Previously, the hitboxes were taller but the procedural sprite rectangles remained short, causing bullets to appear to fly over enemies.  
This update brings the visual body and collider into alignment.

**Changes**

- **`config.lua`**
  - Increased enemy collider height (`C.ENEMY.COLLIDER.h`) from ~28 px → 36 px for better projectile intersection.

- **`src/enemy.lua`**
  - Updated `self.sh` (sprite height) to reference the collider height:
    ```lua
    self.sh = (cfg.ENEMY and cfg.ENEMY.COLLIDER and cfg.ENEMY.COLLIDER.h) or 16
    ```
    ensuring the visual placeholder matches the actual hurtbox.
  - (Optional) Added fallback draw logic to render a collider-sized rectangle if sprite art is missing.

**Notes**

- Collider and visible body now share consistent height, improving the sense of impact and hit feedback.
- No gameplay physics or movement changed; only the visual scale and collision alignment.
- Custom per-enemy heights can still be defined via `Enemy.new{ customH = value }`.

**Next Steps**

1. Add basic explosion / impact visual on bullet-enemy collision.  
2. Replace procedural enemy rectangles with real sprite strips.  
3. Implement enemy health and delayed death animation.

### [2025-10-31] — Step 15: Enemy Health, Death Handling & Facing Indicator

**Summary**

Expanded the enemy framework to support health, damage handling, hit flash, death fade, and restored the facing-direction indicator.  
Enemies now take multiple hits to kill, flash red when damaged, fade out upon death, and remove themselves after a short delay.  
Also re-added the small directional line that shows which way an enemy is facing.

**Changes**

- **`config.lua`**
  - Added new tunables:
    ```lua
    C.PROJ.dmg = 1
    C.ENEMY.hp        = 2
    C.ENEMY.hitFlash  = 0.12
    C.ENEMY.deathTime = 0.25
    ```
  - These define bullet damage, enemy health, flash duration, and fade-out time.

- **`src/enemy.lua`**
  - Added new fields: `hp`, `hitTimer`, `deathTime`, and `dead`.
  - Implemented `Enemy:takeDamage(dmg)` to handle incoming projectile hits.
  - Updated `Enemy:update(dt)`:
    - Processes hit flash and death countdown timers.
    - Skips movement once an enemy has died.
  - Updated `Enemy:draw()`:
    - Applies red flash color while `hitTimer` is active.
    - Fades sprite opacity as `deathTime` counts down.
    - Draws procedural fallback rectangle if no sprite is loaded.
    - Restored **facing-direction indicator**:
      ```lua
      local lineLen = 6
      local lx1 = self.x
      local ly1 = self.y - self.sh - 2
      local lx2 = lx1 + (self.dir * lineLen)
      love.graphics.setColor(0.8, 0.8, 0.2, 1)
      love.graphics.line(lx1, ly1, lx2, ly1)
      love.graphics.setColor(1, 1, 1, 1)
      ```

- **`src/systems/projectiles.lua`**
  - Changed collision behavior to call `enemies[e]:takeDamage(cfg.PROJ.dmg)` instead of killing instantly.

- **`main.lua`**
  - Adjusted cleanup logic:
    ```lua
    if en.dead and (en.deathTime or 0) <= 0 then
        table.remove(enemies, e)
    end
    ```
    ensuring enemies persist briefly for death fade.

**Notes**

- Each enemy starts with 2 HP and takes 1 damage per bullet.  
- Hit flash is visible for 0.12 s, then fades smoothly over 0.25 s before removal.  
- Works with both sprite and fallback rendering.  
- The facing line provides continuous orientation feedback, independent of the debug overlay.  

**Next Steps**

1. Add a simple explosion / impact animation on bullet hits.  
2. Introduce basic enemy attack behavior (projectile or melee).  
3. Begin centralizing death / impact effects into a reusable visual system.

### [2025-10-31] — Step 16: Centralized Collision System

**Summary**

Moved all hit detection into a dedicated collision manager, reducing clutter in `main.lua` and improving modularity.  
The system now handles all collision logic through a single module, preparing the groundwork for future interactions (e.g., player ↔ enemy or pickups).  
Also fixed an aliasing issue in the projectile system that prevented bullets from registering hits.

**Changes**

- **Added `src/systems/collisions.lua`**
  - Centralizes all game collision logic.
  - Handles projectile → enemy detection using shared AABB checks (`Collision.rectsOverlap`).
  - Calls `enemy:takeDamage(cfg.PROJ.dmg)` for each confirmed hit.

- **Updated `src/systems/projectiles.lua`**
  - Exposed `P.list` (the active bullet table) for external systems.
  - Fixed aliasing bug:
    ```lua
    function P.init()
      bullets = {}
      P.list = bullets  -- reassign pointer to keep synced
    end
    ```
    This ensures that when bullets are reinitialized, the collision system sees the live table instead of a stale reference.

- **Added `local Collisions = require("src.systems.collisions")` to `main.lua`**
  - Replaced inline collision code with:
    ```lua
    Collisions.update(dt, world, player, enemies, Projectiles)
    ```
  - Keeps `love.update()` focused solely on high-level flow (input, updates, rendering).

**Notes**

- Collisions now operate entirely through `src/systems/collisions.lua`.  
- `src/collision.lua` (geometry helper) and `src/projectile.lua` (bullet class) remain required and unchanged.  
- Fixing the pointer alias ensures projectiles properly damage enemies again.  
- The new structure cleanly separates concerns:
  - `collision.lua` → math utility  
  - `systems/collisions.lua` → logic coordination  
  - `systems/projectiles.lua` → projectile management  

**Next Steps**

1. Add player ↔ enemy collision detection (contact damage).  
2. Implement projectile ↔ terrain collisions once map tiles are introduced.  
3. Create a debug toggle to visualize hitboxes for all collision participants.

### [2025-10-31] — Step 17: Collectibles / Powerups (Scaffold)

**Summary**

Added a lightweight Items system with a simple collectible (“gem”).  
Items bob visually, have their own colliders, can be spawned anywhere, and are collected on player overlap.  
Collision handling is centralized (Step 16) and now includes player ↔ item checks. A running count is tracked.

**Changes**

- **`config.lua`**
  - Added item tunables:
    - `C.ITEM = { w = 8, h = 8, bob = 6, bobSpeed = 3 }`

- **`src/item.lua`** (new)
  - Item entity with: position, kind, collider (`w/h`), bobbing timer, `update`, `draw`, `getCollider`.

- **`src/systems/items.lua`** (new)
  - Items manager with: `init`, `spawn(x,y,kind)`, `update`, `draw`, `collect(index, player)`.
  - Exposes `Items.list` and `Items.count` (total collected).

- **`src/systems/collisions.lua`**
  - Expanded API: `Collisions.update(dt, world, player, enemies, projectiles, items)`.
  - Added **PLAYER ↔ ITEMS** AABB overlap; invokes `items.collect(i, player)` on contact.

- **`src/player.lua`**
  - Added `Player:getCollider()` returning the fixed hurtbox rect (pivot-based).

- **`main.lua`**
  - Required `src/systems/items.lua`.
  - `Items.init()` in `love.load()`.
  - Spawned example gems near the floor (e.g., X=260 and 440).
  - Called `Items.update(dt)` each frame.
  - Passed `Items` into `Collisions.update(...)`.
  - Drew items in the world layer **before** player/enemies.

**Notes**

- Items are currently simple gold squares (placeholder art); bobbing is visual only and does not affect the pickup collider.
- `Items.count` increments on collection; no HUD yet (to be added in a later step).
- System follows our existing architecture (pivot-at-feet, fixed colliders, Layers, centralized collisions).

**Next Steps**

1. HUD counter to display `Items.count`.  
2. Add item types (health, ammo, weapon powerup) with per-kind effects in `Items.collect`.  
3. Optional SFX and sparkle animation on pickup.

### [2025-10-31] — Step 18: Tilemap / Level Loader (Read-Only)

**Summary**

Introduced a basic tilemap system and Lua-based level files.  
The map now renders visually with color-coded tiles and defines solid terrain for later collision logic.  
This marks the transition from a static floor to data-driven levels.

**Changes**

- **`assets/levels/level1.lua`** (new)
  - Defines a test map (80×12 tiles, 16 px each).
  - Includes simple background layer and solid ground/platform rows.
  - Returns a Lua table with:
    - `tileSize`, `w`, `h`
    - `layers.bg`
    - `solids` grid (boolean).

- **`src/tilemap.lua`** (new)
  - Handles map loading, drawing, and tile queries.
  - Provides methods:
    - `Tilemap.load(path)` – loads Lua map data.
    - `Tilemap:draw(cameraX, resW, resH)` – draws visible tile range.
    - `Tilemap:isSolidAt(px, py)` – per-pixel solidity check.
    - `Tilemap:aabbOverlapsSolid(x, y, w, h)` – AABB test for future collisions.

- **`main.lua`**
  - Added `local Tilemap = require("src.tilemap")`.
  - Loaded the test level in `love.load()`:
    ```lua
    map = Tilemap.load("assets.levels.level1")
    world.width  = map.worldWidth
    world.height = map.worldHeight
    ```
  - Drew the map before entities in the world layer:
    ```lua
    if map then map:draw(camera and camera.x or 0, cfg.RES_W, cfg.RES_H) end
    ```
  - Updated UI header to indicate Step 18.

**Notes**

- The map currently serves as background only; solids are not yet used by physics.  
- Camera and world width now scale to the level’s defined width.  
- `Tilemap` queries (`isSolidAt`, `aabbOverlapsSolid`) will be used in Step 19 to handle terrain collisions for player and projectiles.

**Next Steps**

1. Add terrain collisions for player feet and bullets (use `isSolidAt` checks).  
2. Create a simple tile-based renderer for visual variety (grass, rock, etc.).  
3. Add a lightweight map editor or loader for multiple levels.

### [2025-11-02] — Step 19: Terrain Collision

**Summary**
Implemented full tilemap collision for player, enemies, and projectiles.
The game now uses level geometry instead of the flat floor system.

**Changes**
- **`src/player.lua`**
  - Added terrain collision for feet, walls, and ceilings
  - Player now walks on platforms and can't phase through walls
  - Gravity applied properly with ground snapping
  
- **`src/enemy.lua`**
  - Enemies respect terrain and won't walk off ledges
  - Added gravity system for enemies
  - Turn around at walls or patrol bounds
  
- **`src/systems/projectiles.lua`**
  - Bullets now despawn on tile collision
  - Multi-point collision check for accuracy
  
- **`cv_debug.lua`**
  - Added `drawTilemap()` to visualize solid tiles (red overlay)
  - Added `drawColliders()` to show all entity hitboxes
  
- **`main.lua`**
  - Pass `map` to all systems that need collision
  - Removed legacy floor line rendering
  - Added gem counter to UI

**Next Steps**
1. Spawn items on terrain (auto-find ground below spawn point)
2. Add camera improvements (smoothing, look-ahead)
3. Player movement polish (coyote time, jump buffering)

### [2025-10-31] — Step 20: Debug Overlay (Tile Solids + Colliders)

**Summary:**
Implemented a comprehensive debug overlay for visualizing tilemap solids and entity colliders.  
This system ties into the existing `cv_debug` overlay (toggled with F1), allowing developers to inspect physics alignment and collision regions in real time.

**Changes**
- Expanded `cv_debug.lua`:
  - Added `drawTilemap(map)` to outline all solid tiles (red boxes).
  - Added `drawColliders(player, enemies)` to render translucent collider boxes for all active entities.
  - Integrated new draw helpers into existing debug toggle system.
- Updated `main.lua`:
  - Hooked both functions into the main world draw phase.
  - Overlays now follow camera position (world-space accurate).
  - Retained screen-space FPS/memory HUD as before.
- Confirmed no interference with normal rendering pipeline or live reload.

**Notes**
- Toggle with **F1** for real-time inspection.
- Solids outlined in **red**; player collider in **yellow**, enemies in **magenta**.
- Works across all levels and scales correctly with camera movement.
- Useful for aligning tile collision data and sprite hitboxes before switching to final tileset art.

### [2025-11-02] — Step 21: Tileset Graphics + Environment Rendering

**Summary**
Replaced placeholder solid tiles with enhanced procedural rendering and optional tileset support.
Added multiple parallax background layers for atmospheric depth and visual polish.

**Changes**

- **`src/tilemap.lua`**
  - Added tileset image loading with quad-based rendering
  - Implemented smart autotiling based on neighbor detection
  - Created detailed procedural platform rendering:
    - Grass/moss on exposed top surfaces
    - Stone texture with noise patterns
    - Depth shading and visual detail
  - Graceful fallback when no tileset image exists

- **`src/background.lua`**
  - Expanded from 2 to 5 parallax layers:
    - Clouds (slowest, 0.08×)
    - Distant mountains (0.15×)
    - Far hills (0.30×)
    - Near hills (0.60×)
    - Foreground foliage (0.75×)
  - All layers procedurally generated
  - Creates sense of depth and atmosphere

- **`config.lua`**
  - Added tileset configuration section
  - Optional tileset path support

- **`main.lua`**
  - Integrated tileset loading
  - Updated UI text for Step 21

- **`assets/levels/level1.lua`**
  - Redesigned level layout with proper platforming progression
  - Added jumpable platforms at varied heights
  - Included obstacles and pillars for gameplay variety

**Notes**
- No image assets required - procedural art looks polished
- Tileset support ready when assets are created
- Platform rendering automatically adjusts based on tile neighbors
- All layers respect camera position and parallax factors

**Next Steps**
1. UI + HUD elements (Step 22)
2. Add health bar, score display, weapon indicator

---

### [2025-11-02] — Step 22: UI + HUD Elements

**Summary**
Implemented complete HUD system with health bar, ammo counter, score display, and gems tracker.
Added pause functionality with overlay menu.

**Changes**

- **`src/hud.lua`** (new)
  - Health bar with dynamic color (green → yellow → red)
  - Ammo counter with bullet icon
  - Score display (6-digit format)
  - Gems counter with visual icon
  - Pause menu overlay with darkened background

- **`src/player.lua`**
  - Added health tracking (`hp`, `maxHp`)
  - Added ammo tracking (`ammo`, `maxAmmo`)
  - Implemented `takeDamage(amount)` method
  - Implemented `heal(amount)` method
  - Fixed collision system to use center-based hitbox
  - Dynamic hitbox sizing (changes with sprite state)

- **`config.lua`**
  - Added HUD color definitions
  - Simplified collider config (now dynamic)

- **`src/input.lua`**
  - Added pause key binding (P, Enter)

- **`main.lua`**
  - Integrated HUD rendering in UI layer
  - Added pause state management
  - Game freezes during pause
  - Added game state tracking (score, gems)

**Notes**
- HUD positioned in corners to avoid gameplay area
- Health bar color changes based on remaining HP
- Pause works with P or Enter keys
- Infinite ammo for now (can be limited later)
- Score system ready for implementation

**Next Steps**
1. Pause + Options Menu (Step 23)
2. Add menu navigation and settings

### [2025-11-02] — Step 23: Pause + Options Menu

**Summary**
Expanded the basic pause overlay into a full menu system with navigation, settings, and multiple screens.
Added options menu with volume controls and debug mode toggle.

**Changes**

- **`src/menu.lua`** (new)
  - Complete menu system with navigation
  - Main pause menu (Resume, Options, Quit to Title, Quit Game)
  - Options submenu with settings:
    - Music volume slider (0-100%)
    - SFX volume slider (0-100%)
    - Debug mode toggle (ON/OFF)
  - Visual sliders and toggles
  - Menu navigation with keyboard
  - Settings storage system (ready for persistence)

- **`src/input.lua`**
  - Added menu navigation bindings:
    - `menu_up` / `menu_down` - Navigate items
    - `menu_left` / `menu_right` - Adjust values
    - `menu_select` - Confirm selection
    - `menu_back` - Return/cancel
  - Menu keys use same WASD/Arrow keys as gameplay

- **`main.lua`**
  - Integrated menu system into pause state
  - Menu input handling in paused mode
  - Menu actions (resume, quit, options navigation)
  - Settings applied from menu selections
  - Placeholder for "Quit to Title" (Step 27)

**Controls**
- **P or Enter** - Pause game
- **↑↓ / W/S** - Navigate menu
- **←→ / A/D** - Adjust sliders
- **Enter / Space** - Select
- **ESC** - Back/Resume

**Notes**
- Menu uses dark overlay with semi-transparent box
- Selection indicated with `>` symbol
- Visual feedback for all interactions
- Settings stored in memory (persistence in future step)
- Menu system scales easily for additional options

**Next Steps**
1. Sound + Music Integration (Step 24)
2. Use volume settings from options menu
3. Add SFX for menu navigation and gameplay events

### [2025-11-02] — Step 24: Sound + Music Integration

**Summary**
Implemented complete audio system with background music, sound effects, and volume controls.
Audio manager automatically detects and loads .ogg, .mp3, or .wav formats with graceful fallbacks.

**Changes**

- **`src/audio.lua`** (new)
  - Complete audio management system
  - Music playback with looping and pause/resume
  - Sound effect system with multi-instance playback
  - Separate volume controls for music and SFX
  - Auto-detects audio format (.ogg, .mp3, .wav)
  - Graceful fallback if audio files missing (silent operation)
  - Volume changes apply in real-time

- **`src/player.lua`**
  - Added jump sound effect trigger
  - Added shoot sound effect in `getMuzzle()`

- **`src/enemy.lua`**
  - Added hit sound when damaged
  - Added explosion sound on death

- **`src/systems/items.lua`**
  - Added collect sound on item pickup

- **`main.lua`**
  - Initialize audio system on startup
  - Start stage music in `love.load()`
  - Pause/resume music with game pause
  - Menu navigation sounds (move/select)
  - Apply volume changes from options menu in real-time

- **`src/menu.lua`**
  - Volume settings now affect audio playback immediately

**Audio Files Structure (all optional):**
```
assets/audio/
  music/
    title.{ogg|mp3|wav}    - Title screen music
    stage.{ogg|mp3|wav}    - Level/gameplay music
    boss.{ogg|mp3|wav}     - Boss battle music
  sfx/
    jump.{ogg|mp3|wav}     - Player jump
    shoot.{ogg|mp3|wav}    - Player shoot
    hit.{ogg|mp3|wav}      - Enemy hit
    explode.{ogg|mp3|wav}  - Enemy death
    collect.{ogg|mp3|wav}  - Item pickup
    pause.{ogg|mp3|wav}    - Pause menu
    menu_move.{ogg|mp3|wav}    - Menu navigation
    menu_select.{ogg|mp3|wav}  - Menu selection
```

**Sound Effects Triggered:**
- Jump - When player leaves ground
- Shoot - When player fires weapon
- Hit - Enemy takes non-lethal damage
- Explode - Enemy dies
- Collect - Player picks up gem/item
- Pause - Pause menu opens
- Menu Move - Navigate menu options
- Menu Select - Confirm menu selection

**Notes**
- Music uses streaming (memory efficient for long tracks)
- SFX uses static sources (instant playback, no latency)
- Multi-format support allows mixing .ogg, .mp3, .wav files
- Volume sliders in options menu work immediately
- Music pauses with game, resumes on unpause
- All audio is optional - game works silently if files missing
- SFX instances can overlap (multiple sounds play simultaneously)

**Recommended Resources for Audio:**
- jsfxr.me - Generate retro sound effects
- ChipTone - Advanced 8-bit sound generator
- OpenGameArt.org - Free game audio assets
- BeepBox.co - Create chiptune music in browser

**Next Steps**
1. Save System + Checkpoints (Step 25)
2. Persist player progress and settings
3. Add checkpoint respawn logic

### [2025-11-02] — Step 25: Save System + Checkpoints + Enemy Damage

**Summary**
Implemented persistent save system with checkpoints, respawn mechanics, and player death handling.
Added enemy contact damage with knockback, hitstun, and invincibility frames for clear hit feedback.

**Changes**

- **`src/save.lua`** (new)
  - Complete save/load system with Lua serialization
  - Persistent data structure:
    - Progress (current level, checkpoint position, score, gems)
    - Settings (music/SFX volume, debug mode)
    - Statistics (total deaths, kills, playtime)
  - Auto-save functionality
  - Version compatibility with default value merging
  - Save file management (load, save, delete)

- **`src/player.lua`**
  - Added `respawn(x, y)` method for checkpoint revival
  - Implemented invincibility frames (1.5s after damage)
  - Added damage flash effect (red tint for 0.2s)
  - Visual blinking during invincibility period
  - Knockback system:
    - Pushes player away from damage source (150 px/s)
    - Small upward pop if grounded (-120 velocity)
    - Direction based on enemy position
  - Hitstun implementation:
    - 0.3 second control lockout on hit
    - Knockback velocity applied during hitstun
    - Input completely disabled until hitstun expires
  - Debug visualization shows hitstun status (F1)

- **`src/systems/collisions.lua`**
  - Added PLAYER ↔ ENEMY contact damage
  - Only living enemies deal damage
  - Passes enemy position to player for knockback direction
  - 1 HP damage per enemy contact
  - Respects invincibility frames (can't be hit repeatedly)

- **`assets/levels/level1.lua`**
  - Added checkpoint array with positions:
    - Start (x=32, y=160)
    - Mid-level (x=320, y=96)
    - Near end (x=640, y=160)

- **`main.lua`**
  - Save system initialization on startup
  - Load saved progress and settings
  - Apply audio volumes from saved settings
  - Checkpoint activation detection (20px radius)
  - Death handling with respawn at last checkpoint
  - Death and kill stat tracking
  - Continuous playtime tracking
  - Auto-save settings and progress
  - Debug visualization of checkpoints (F1)
    - Green = activated, Yellow = available

**Save File Location:**
- Windows: `C:\Users\[user]\AppData\Roaming\LOVE\contra_vania\`
- macOS: `~/Library/Application Support/LOVE/contra_vania/`
- Linux: `~/.local/share/love/contra_vania/`
- Filename: `contra_vania_save.lua`

**Damage System Features:**
- Contact with enemy → 1 HP damage
- Red flash effect on hit
- Knocked back away from enemy
- 0.3s control lockout (hitstun)
- 1.5s invincibility (can't be hit again)
- Visual blinking during invincibility
- Sound effect on hit
- Explosion sound on death

**Checkpoint System:**
- Walk within 20px radius to activate
- Collect sound plays on activation
- Progress auto-saved when checkpoint reached
- Respawn at last checkpoint on death
- Visual indicators in debug mode

**Statistics Tracked:**
- Total player deaths
- Total enemy kills
- Total playtime (seconds)
- Gems collected
- Current score

**Notes**
- Settings persist between sessions
- Progress auto-saves continuously
- Knockback values tuned for good feel without being punishing
- Hitstun brief enough to not feel frustrating
- Debug mode shows checkpoint circles and hitstun status

**Next Steps**
1. Boss Logic Framework (Step 26)
2. Multi-phase boss encounters
3. Boss health bar UI
4. Boss intro/outro sequences

### [2025-11-03] — Step 26: Boss Logic Framework + Projectile System

**Summary**
Implemented complete boss encounter system with multi-phase AI, projectile patterns, and contact damage.
The FlyingEye boss features three difficulty phases, varied attack patterns, and proper collision handling.

**Changes**

- **`src/tilemap.lua`**
  - Fixed critical bug: now properly loads `checkpoints` and `bossSpawn` from level data.
  - Added debug logging for boss spawn verification.
  - These fields were defined in level files but weren't being copied to the tilemap object.

- **`src/bossprojectile.lua`** (new)
  - Boss-specific projectile class with multiple types.
  - Normal projectiles (rectangular).
  - Homing projectiles (diamond-shaped, track player).
  - Rotation based on velocity direction.
  - Configurable size, speed, damage, and lifetime.

- **`src/systems/bossprojectiles.lua`** (new)
  - Manager for boss projectile spawning and updates.
  - Pattern system with multiple attack types:
    - `single` - Single aimed shot
    - `spread3` - 3-way spread
    - `spread5` - 5-way spread
    - `circle8` - 360-degree burst (8 projectiles)
    - `homing` - Tracking missile
  - Terrain collision detection.
  - Off-screen cleanup.

- **`src/bosses/flyingeye.lua`**
  - Complete boss implementation with 3 phases.
  - Phase 1 (>66% HP): Single shots + 3-way spreads, slow attacks (1.8s interval).
  - Phase 2 (33-66% HP): 5-way spreads + homing missiles, faster (1.2s interval).
  - Phase 3 (<33% HP): Circle bursts + aggressive homing, fastest (0.8s interval).
  - Smooth hovering motion (sine wave vertical movement).
  - Horizontal movement pattern (picks random positions in arena).
  - Aggressive positioning in phase 3.
  - Attack counter tracks pattern variations.

- **`src/systems/collisions.lua`**
  - Added boss projectile → player collision.
  - Added boss → player contact damage.
  - Boss projectiles respect player invincibility frames.
  - Knockback direction based on projectile/boss position.

- **`main.lua`**
  - Integrated `BossProjectiles` system initialization and updates.
  - Boss projectiles clear on player death.
  - Boss projectiles clear on boss defeat.
  - Boss resets properly when player dies during fight.
  - Victory music transition when boss defeated.
  - Boss trigger system uses level data properly.

**Boss Fight Flow**
1. Player reaches trigger point (x=1000 in level1).
2. Boss slides in from off-screen with intro animation.
3. Music switches to boss theme.
4. Boss begins attacking with phase-appropriate patterns.
5. Phase transitions at 66% and 33% HP.
6. On defeat: projectiles clear, music returns to stage theme.
7. On player death: boss resets, returns to inactive state.

**Attack Pattern Details**
- Phase 1: Every 3rd attack is spread, otherwise single.
- Phase 2: Every 4th attack is homing, otherwise 5-way spread.
- Phase 3: Every 5th is circle burst, every 3rd is homing, otherwise fast spread.

**Projectile Properties**
- Normal: 8×8 px, speed 100-130 px/s, 1 damage.
- Homing: 8×8 px, speed 70-80 px/s, homing strength 2.5-3.5, 1 damage.
- All projectiles: 5 second lifetime, auto-destroy on terrain hit.

**Notes**
- Boss contact damage implemented but arena boundaries not yet added.
- Player can still leave arena during fight (will fix in future).
- Boss visual is still placeholder rectangle (sprites planned).
- No screen shake or particle effects yet (polish phase).
- Boss health bar displays during active fight.
- Full integration with existing save system and checkpoints.

**Next Steps**
1. Title Screen + Scene Flow (Step 27)
2. Boss arena boundaries/camera lock
3. Victory rewards and powerup drops
4. Boss sprite animations