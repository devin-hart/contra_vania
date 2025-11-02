-- Centralized tuning + palette
local C = {}

-- Logical render size (Genesis vibe)
C.RES_W = 320
C.RES_H = 180
C.SCALE_START = 3

-- World settings
C.WORLD_WIDTH  = 1024         -- simple scrollable width
C.FLOOR_OFFSET = 20           -- distance from bottom to ground line

-- Player physics
C.PLAYER_SPEED = 80           -- px/s
C.PLAYER_JUMPV = -180         -- px/s impulse (upward)
C.GRAVITY      = 420          -- px/s^2

-- Parallax factors (0 = static sky, 1 = world speed)
C.PARALLAX = {
  far  = 0.30,
  near = 0.60,
}

-- Animation rates (frames per second)
C.ANIM = {
  idle = 4,
  run  = 10,
  jump = 6,
}

-- Sprite sheet configuration (optional)
-- Put your strips here if/when you add them. If these files are missing,
-- the game falls back to procedural frames.
C.SPRITES = {
  player = {
    idlePath = "assets/gfx/player/idle_strip.png",
    runPath  = "assets/gfx/player/run_strip.png",
    jumpPath = "assets/gfx/player/jump_strip.png",

    -- Frame dimensions
    frameW = 24,  -- used for idle & run
    frameH = 35,

    idleFrames = 2,
    runFrames  = 6,

    -- Jump animation uses its own frame size (22×20)
    jumpFrames = 4,
    jumpFrameW = 22,
    jumpFrameH = 20,
  }
}


-- Colors (RGBA 0..1)
C.COLORS = {
  sky       = {0.22, 0.62, 0.92, 1.0},  -- bright blue sky
  hill_far  = {0.20, 0.36, 0.50, 1.0},
  hill_near = {0.18, 0.28, 0.42, 1.0},

  bg     = {0.08, 0.08, 0.10, 1.0},   -- legacy background (kept for UI clears)
  floor  = {0.50, 0.50, 0.60, 1.0},
  accent = {0.20, 0.80, 0.30, 1.0},
  player = {0.20, 0.90, 0.30, 1.0},
  white  = {1, 1, 1, 1},
}

-- Gameplay collider (independent of sprite size)
C.COLLIDER = {
  player = {
    w = 20,   -- collider width (tune 18–22)
    h = 30,   -- collider height (tune 28–32)
    ox = 0,   -- optional fine offset X (pixels)
    oy = 0,   -- optional fine offset Y (pixels)
  }
}

-- Player projectile (single bullet)
C.PROJ = {
  w = 6,           -- width in pixels
  h = 2,           -- height in pixels
  speed = 260,     -- px/s
  life  = 0.9,     -- seconds
  muzzleX = 8,     -- offset from pivot X in facing direction
  muzzleY = -18,   -- offset from pivot Y (negative = above feet)
}

C.ENEMY = {
  spriteW = 16,
  spriteH = 16,

  COLLIDER = {
    w = 18,
    h = 36,   -- ← increased from 28 (or so) to 36 px tall
    ox = 0,
    oy = 0,
  },

  idleFrames    = 2,
  walkFrames    = 4,
  animIdleFPS   = 3,
  animWalkFPS   = 8,
}

-- Bullet damage
C.PROJ.dmg = 1

-- Enemy defaults
C.ENEMY = C.ENEMY or {}
C.ENEMY.hp          = 2      -- hits to kill
C.ENEMY.hitFlash    = 0.12   -- seconds of red flash
C.ENEMY.deathTime   = 0.25   -- seconds before removal once hp <= 0

-- Collectible defaults
C.ITEM = {
  w = 8,        -- collider width
  h = 8,        -- collider height
  bob = 6,      -- bobbing amplitude (px)
  bobSpeed = 3, -- bobbing speed (Hz-ish)
}


return C
