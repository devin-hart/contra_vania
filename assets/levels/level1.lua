-- Simple Lua level: 16px tiles, W=80 tiles (1280 px), H=12 tiles (192 px)
-- layers.bg: visual indices (0 = empty).
-- solids: boolean grid (true blocks movement; read-only for now).

local T = {}
T.tileSize = 16
T.w = 80
T.h = 12

-- quick helper
local function grid(fill)
  local g = {}
  for y=1,T.h do
    g[y] = {}
    for x=1,T.w do g[y][x] = fill end
  end
  return g
end

-- Background visuals (0 = empty). Keep sparse for performance.
T.layers = {
  bg = grid(0),
}

-- Paint some simple scenery (indices 1..3 just color codes in our renderer)
for x=1, T.w do
  T.layers.bg[T.h-3][x] = 1
  T.layers.bg[T.h-4][x] = (x % 2 == 0) and 2 or 0
end
for x=10, 20 do T.layers.bg[T.h-6][x] = 3 end

-- Solids: flat ground + a couple platforms.
T.solids = grid(false)
for x=1,T.w do T.solids[T.h][x] = true end                         -- bottom row ground
for x=18,26 do T.solids[T.h-5][x] = true end                       -- small platform
for x=40,55 do T.solids[T.h-7][x] = true end                       -- longer platform

return T
