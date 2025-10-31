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

11. **Jump + Land Polish**
    - Add apex detection, landing states, and coyote time.  
    - Integrate jump and landing sound effects.

12. **Enemy Framework**
    - Create base `enemy.lua` class and simple patrol AI.  
    - Introduce collision logic with player projectiles.

13. **Projectile System**
    - Implement player shooting and basic bullet entities.  
    - Add cooldowns, hit detection, and effects.

14. **Player Health + Damage System**
    - Add player health and death conditions.  
    - Introduce visual feedback for damage.

15. **Enemy AI + Attack Patterns**
    - Expand enemy behavior logic and animation states.  
    - Add attack projectiles and melee variants.

16. **Collision + Hit Detection**
    - Build a collision manager for entities, projectiles, and tiles.  
    - Support basic hitboxes and response callbacks.

17. **Collectibles + Powerups**
    - Implement pickups for health, ammo, and temporary boosts.  
    - Add particle feedback for item collection.

18. **Level Loader (Tilemap System)**
    - Load stages from Lua/JSON tilemaps.  
    - Separate foreground and background layers.

19. **Environment Layers Expansion**
    - Add extra parallax depth and animated environment details.  
    - Include scrolling clouds, torches, and ambient motion.

20. **Boss Logic Framework**
    - Create reusable structure for multi-phase bosses.  
    - Add basic boss intro and health bar UI.

21. **UI + HUD Elements**
    - Display health, score, and weapon info.  
    - Add animated icons and energy bars.

22. **Pause + Options Menu**
    - Implement pause screen and settings (audio, controls).  
    - Add return-to-title flow.

23. **Sound + Music Integration**
    - Load and manage background tracks and SFX.  
    - Implement volume controls and playback management.

24. **Save System + Checkpoints**
    - Add checkpoint respawn logic and save slots.  
    - Store player progress and inventory.

25. **Title Screen + Scene Flow**
    - Implement title menu, transitions, and scene switching.  
    - Add simple “New Game” and “Continue” options.

26. **Final Balancing + Polish**
    - Fine-tune movement, physics, and pacing.  
    - Clean up visuals, audio, and transitions.

27. **Packaging + Distribution**
    - Prepare release build for Windows/Linux/macOS.  
    - Add icons, metadata, and optional web export.
