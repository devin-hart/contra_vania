-- Centralized tuning + palette
local C = {}

-- Logical render size (Genesis vibe)
C.RES_W = 320
C.RES_H = 180
C.SCALE_START = 3

-- World settings
C.WORLD_WIDTH  = 1024
C.FLOOR_OFFSET = 20

-- Player physics
C.PLAYER_SPEED = 80
C.PLAYER_JUMPV = -180
C.GRAVITY      = 420

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

-- Sprite sheet configuration
C.SPRITES = {
  player = {
    idlePath = "assets/gfx/player/idle_strip.png",
    runPath  = "assets/gfx/player/run_strip.png",
    jumpPath = "assets/gfx/player/jump_strip.png",

    frameW = 24,
    frameH = 35,

    idleFrames = 2,
    runFrames  = 6,

    jumpFrames = 4,
    jumpFrameW = 22,
    jumpFrameH = 20,
  },
  
  -- NEW: Tileset configuration
  tileset = {
    path = "assets/gfx/tiles/tileset.png",
    tileSize = 16,  -- must match level tile size
  }
}

-- Colors (RGBA 0..1)
C.COLORS = {
  sky       = {0.22, 0.62, 0.92, 1.0},
  hill_far  = {0.20, 0.36, 0.50, 1.0},
  hill_near = {0.18, 0.28, 0.42, 1.0},

  bg     = {0.08, 0.08, 0.10, 1.0},
  floor  = {0.50, 0.50, 0.60, 1.0},
  accent = {0.20, 0.80, 0.30, 1.0},
  player = {0.20, 0.90, 0.30, 1.0},
  white  = {1, 1, 1, 1},
}

-- Gameplay collider (independent of sprite size)
C.COLLIDER = {
  player = {
    w = 20,
    h = 30,
    ox = 0,
    oy = 0,
  }
}

-- Player projectile
C.PROJ = {
  w = 6,
  h = 2,
  speed = 260,
  life  = 0.9,
  muzzleX = 8,
  muzzleY = -18,
  dmg = 1,
}

-- Enemy configuration
C.ENEMY = {
  spriteW = 16,
  spriteH = 16,

  COLLIDER = {
    w = 18,
    h = 36,
    ox = 0,
    oy = 0,
  },

  idleFrames    = 2,
  walkFrames    = 4,
  animIdleFPS   = 3,
  animWalkFPS   = 8,
  
  hp          = 2,
  hitFlash    = 0.12,
  deathTime   = 0.25,
}

-- Collectible defaults
C.ITEM = {
  w = 8,
  h = 8,
  bob = 6,
  bobSpeed = 3,
}

return C