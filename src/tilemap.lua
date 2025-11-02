local cfg = require("config")

local Tilemap = {}
Tilemap.__index = Tilemap

local COLORS = {
  [1] = {0.18, 0.28, 0.42, 1.0}, -- near hill color
  [2] = {0.20, 0.36, 0.50, 1.0}, -- far hill color
  [3] = {0.40, 0.75, 0.30, 1.0}, -- accent grass
}

function Tilemap.load(path)
  local ok, data = pcall(require, path:gsub("%.lua$", ""):gsub("/", "."))
  assert(ok and type(data)=="table", ("Tilemap.load: failed to load %s"):format(path))

  local self = setmetatable({}, Tilemap)
  self.tw  = assert(data.w, "level w missing")
  self.th  = assert(data.h, "level h missing")
  self.ts  = assert(data.tileSize, "level tileSize missing")
  self.bg  = assert(data.layers and data.layers.bg, "level bg layer missing")
  self.solids = assert(data.solids, "level solids missing")

  self.worldWidth  = self.tw * self.ts
  self.worldHeight = self.th * self.ts

  return self
end

-- Draw only tiles in the camera’s view
function Tilemap:draw(cameraX, resW, resH)
  local ts = self.ts
  local startX = math.max(1, math.floor(cameraX / ts) + 1)
  local endX   = math.min(self.tw, math.floor((cameraX + resW) / ts) + 1)

  -- 1) Background tiles (decor)
  for y = 1, self.th do
    for x = startX, endX do
      local id = self.bg[y][x]
      if id and id ~= 0 then
        local c = COLORS[id] or {0.5,0.5,0.6,1}
        love.graphics.setColor(c)
        love.graphics.rectangle("fill", (x-1)*ts, (y-1)*ts, ts, ts)
      end
    end
  end

  -- 2) Solids (platforms/ground) — draw as visible blocks for now
  love.graphics.setColor(0.40, 0.85, 0.35, 1.0)  -- platform green
  for y = 1, self.th do
    for x = startX, endX do
      if self.solids[y][x] == true then
        love.graphics.rectangle("fill", (x-1)*ts, (y-1)*ts, ts, ts)
      end
    end
  end

  love.graphics.setColor(1,1,1,1)
end

-- Tile queries (read-only for now)
function Tilemap:isSolidTile(tx, ty)
  if tx < 1 or ty < 1 or tx > self.tw or ty > self.th then return true end
  return self.solids[ty][tx] == true
end

function Tilemap:isSolidAt(px, py)
  local ts = self.ts
  local tx = math.floor(px / ts) + 1
  local ty = math.floor(py / ts) + 1
  return self:isSolidTile(tx, ty)
end

-- AABB vs solids (for future use)
function Tilemap:aabbOverlapsSolid(x, y, w, h)
  local ts = self.ts
  local x0 = math.max(1, math.floor(x       / ts) + 1)
  local y0 = math.max(1, math.floor(y       / ts) + 1)
  local x1 = math.min(self.tw, math.floor((x+w-1) / ts) + 1)
  local y1 = math.min(self.th, math.floor((y+h-1) / ts) + 1)
  for ty = y0, y1 do
    for tx = x0, x1 do
      if self:isSolidTile(tx, ty) then return true end
    end
  end
  return false
end

return Tilemap
