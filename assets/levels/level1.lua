-- Extended Level 1: 16px tiles, W=120 tiles (1920 px), H=12 tiles (192 px)
-- Designed with boss arena at the end

local T = {}
T.tileSize = 16
T.w = 120  -- Extended from 80 to 120 tiles
T.h = 12

-- Quick helper to create empty grid
local function grid(fill)
  local g = {}
  for y=1,T.h do
    g[y] = {}
    for x=1,T.w do g[y][x] = fill end
  end
  return g
end

-- Background visuals (decorative elements)
T.layers = {
  bg = grid(0),
}

-- Add some decorative background elements
for x=1, T.w do
  if x % 3 == 0 then
    T.layers.bg[T.h-1][x] = 1
  end
  if x % 7 == 0 and x > 5 then
    T.layers.bg[6][x] = 3
  end
end

-- SOLIDS: Create an engaging level layout
T.solids = grid(false)

-- === GROUND FLOOR (bottom 2 rows) ===
for x=1, T.w do
  T.solids[T.h][x] = true
  T.solids[T.h-1][x] = true
end

-- === SECTION 1: Starting area ===
-- (Ground floor continues)

-- === SECTION 2: First platform jump ===
for x=15, 22 do
  T.solids[T.h-3][x] = true
end

-- === SECTION 3: Stepped platforms ===
for x=26, 31 do
  T.solids[T.h-4][x] = true
end

for x=33, 38 do
  T.solids[T.h-5][x] = true
end

-- === SECTION 4: High platform ===
for x=42, 50 do
  T.solids[T.h-6][x] = true
end

-- === SECTION 5: Descending ===
for x=54, 59 do
  T.solids[T.h-5][x] = true
end

for x=61, 66 do
  T.solids[T.h-4][x] = true
end

-- === SECTION 6: Small platforms ===
for x=70, 73 do
  T.solids[T.h-3][x] = true
end

for x=76, 78 do
  T.solids[T.h-3][x] = true
end

-- === NEW: SECTION 7: Bridge to boss arena ===
for x=82, 90 do
  T.solids[T.h-2][x] = true
end

-- === NEW: SECTION 8: Boss Arena (flat, wide space) ===
-- Wide flat platform for boss fight
for x=95, 118 do
  T.solids[T.h-2][x] = true
end

-- Small raised platforms in boss arena for cover
for x=98, 100 do
  T.solids[T.h-4][x] = true
end

for x=113, 115 do
  T.solids[T.h-4][x] = true
end

-- === OBSTACLES ===
-- Short pillar in starting area
T.solids[T.h-2][8] = true
T.solids[T.h-3][8] = true

-- Medium pillar in middle section
for y=T.h-5, T.h-2 do
  T.solids[y][35] = true
end

-- Small barrier
T.solids[T.h-2][52] = true
T.solids[T.h-3][52] = true

-- === CHECKPOINTS ===
T.checkpoints = {
  { x = 32,   y = 160 },   -- Start
  { x = 320,  y = 96 },    -- Mid-level (on high platform)
  { x = 640,  y = 160 },   -- Near end
  { x = 1100, y = 160 },   -- Boss arena entrance
}

-- === BOSS SPAWN ===
T.bossSpawn = {
  x = 1750,   -- Far right of boss arena
  y = 80,     -- High in the air
  triggerX = 1000,  -- Player must reach this X to trigger boss
}

return T