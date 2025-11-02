# CONTRA-VANIA ROADMAP

**Engine:** LOVE2D  
**Style:** 2D side-scroller (Contra × Castlevania, 80s action aesthetic)  
**Resolution:** 320×180 (Sega Genesis inspired)

---

## Development Steps

1. **Project Initialization**
   - Create base folder structure and initial files.  
   - Set up live reload system for rapid iteration.

2. **Minimal Loop + Debug Overlay**
   - Implement LOVE2D window and integer scaling.  
   - Add FPS, memory, and logging overlay toggled by F1/F2.

3. **Player Stub**
   - Introduce player rectangle and basic input for movement and jump.  
   - Add simple collision with a flat floor.

4. **Config + Camera Integration**
   - Centralize constants (resolution, colors, physics).  
   - Implement simple scrolling camera with horizontal clamping.

5. **Viewport Module**
   - Move canvas and scaling logic into a dedicated `viewport.lua`.  
   - Simplify main loop and drawing structure.

6. **Parallax Background**
   - Add procedural dual-layer hills for parallax depth.  
   - Integrate background rendering before world draw.

7. **Draw Layer System**
   - Create `layers.lua` to manage draw order (background → world → UI).  
   - Standardize layer-based rendering pipeline.

8. **Input System**
   - Centralize key handling (`input.lua`) with pressed, held, and released states.  
   - Simplify input logic across modules.

9. **Animated Player System**
   - Add `anim.lua` for idle/run/jump animation control.  
   - Replace static rectangle with procedural color-frame animations.  

10. **Sprite Integration**
    - Load sprite sheets from `assets/gfx/player/`.  
    - Replace procedural animations with real frames.  
    - Verify frame alignment with collider visualization.

11. **Jump + Land Polish**
    - Add apex detection, landing states, and coyote time.  
    - Integrate jump and landing sound effects for tactile feedback.  
    - Smooth out transitions between air and ground animations.

12. **Enemy Framework**
    - Create base `enemy.lua` class and simple patrol AI.  
    - Introduce collision logic with player projectiles.  
    - Add idle/run state machine for enemies.

13. **Projectile System**
    - Implement player shooting and basic bullet entities.  
    - Add cooldowns, hit detection, and effects.  
    - Spawn bullets relative to player muzzle offset.

14. **Collision + Hit Detection**
    - Centralize all collisions in `collisions.lua`.  
    - Support entity, projectile, and tilemap hit responses.  
    - Introduce small knockback effect for enemy hits.

15. **Enemy AI + Damage Feedback**
    - Add visual hit feedback for enemies on damage (red flash).  
    - Preserve direction markers for debugging and orientation.  
    - Implement simple death/despawn behavior.

16. **Tilemap + Terrain Collision**
    - Add basic tilemap system (`tilemap.lua`) with solid detection.  
    - Integrate vertical collision logic with fallback to flat floor.  
    - Player can now land and move across tile-based surfaces.

17. **Collectibles + Item System**
    - Create `items.lua` for pickups (gems, health, etc.).  
    - Add item collection feedback and particle placeholder.  
    - Tie collection into debug log for tracking.

18. **Tilemap Expansion (Platforms + Scrolling Map)**
    - Add platforms and raised terrain to `level1.lua`.  
    - Enable scrolling map support in camera.  
    - Player can traverse elevated terrain and mid-air platforms.

19. **WIP: Environment Layers + Tile Rendering**
    - Visible green solids represent collision platforms.  
    - Player and enemies fully interact with map surfaces.  
    - Will later include tileset-based visual rendering and art polish.

20. **Debug Overlay Expansion**
    - Added `cv_debug.drawTilemap()` and `cv_debug.drawColliders()`.  
    - Visualize solid tiles and entity colliders with F1 toggle.  
    - Essential for collision alignment and debugging.

21. **Tileset Graphics + Environment Rendering**
    - Replace placeholder solids with real tileset art.  
    - Add multiple background parallax layers for depth.  
    - Prepare environment for thematic visual polish.

22. **HUD + UI Elements**
    - Implement player health, score, and ammo display.  
    - Add pause overlay and basic font assets.  
    - Hook into gameplay data for live updates.

23. **Pause + Options Menu**
    - Create pause menu with resume/quit options.  
    - Include toggles for music, sound, and debug mode.  
    - Add scene management for state transitions.

24. **Sound + Music Integration**
    - Integrate retro-inspired SFX for player, enemies, and items.  
    - Add background music system with looping and transitions.  
    - Volume controls tied into options menu.

25. **Save System + Checkpoints**
    - Add save points and checkpoint respawn logic.  
    - Persist progress (level, score, collectibles).  
    - Write basic serialization for save data.

26. **Boss Framework + Encounter Logic**
    - Create dedicated `boss.lua` class with intro/attack patterns.  
    - Add health bar, hit phases, and damage thresholds.  
    - Integrate event-based transition on boss defeat.

27. **Title Screen + Scene Flow**
    - Implement title menu and scene transitions.  
    - Add logo animation, start prompt, and fade effects.  
    - Include level select and credits placeholder.

28. **Final Polish + Packaging**
    - Optimize assets, clean up code, and finalize build structure.  
    - Add splash screen and final audio mastering.  
    - Package for release with README + credits.
