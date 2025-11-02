-- Enhanced Level 1: 16px tiles, W=80 tiles (1280 px), H=12 tiles (192 px)
-- Designed for engaging platforming with varied heights and gaps

local T = {}
T.tileSize = 16
T.w = 80
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
  -- Ground decoration
  if x % 3 == 0 then
    T.layers.bg[T.h-1][x] = 1
  end
  -- Mid-air decoration spots
  if x % 7 == 0 and x > 5 then
    T.layers.bg[6][x] = 3
  end
end

-- SOLIDS: Create an engaging level layout
T.solids = grid(false)

-- === GROUND FLOOR (bottom 2 rows for stability) ===
for x=1, T.w do
  T.solids[T.h][x] = true     -- Very bottom
  T.solids[T.h-1][x] = true   -- Ground level
end

-- === SECTION 1: Starting area (flat ground) ===
-- Already covered by ground floor

-- === SECTION 2: First platform jump (easy) ===
-- Low platform at comfortable jump height
for x=15, 22 do
  T.solids[T.h-3][x] = true
end

-- === SECTION 3: Stepped platforms (ascending) ===
for x=26, 31 do
  T.solids[T.h-4][x] = true
end

for x=33, 38 do
  T.solids[T.h-5][x] = true
end

-- === SECTION 4: High platform with gap ===
for x=42, 50 do
  T.solids[T.h-6][x] = true
end

-- === SECTION 5: Descending back down ===
for x=54, 59 do
  T.solids[T.h-5][x] = true
end

for x=61, 66 do
  T.solids[T.h-4][x] = true
end

-- === SECTION 6: Final area with small platforms ===
-- Small platform
for x=70, 73 do
  T.solids[T.h-3][x] = true
end

-- Another small jump
for x=76, 78 do
  T.solids[T.h-3][x] = true
end

-- === OBSTACLES: Add some single-tile pillars/obstacles ===
-- Pillar in starting area
for y=T.h-4, T.h-2 do
  T.solids[y][8] = true
end

-- Pillar in middle section
for y=T.h-5, T.h-2 do
  T.solids[y][35] = true
end

-- Small barrier
T.solids[T.h-2][52] = true
T.solids[T.h-3][52] = true

return T