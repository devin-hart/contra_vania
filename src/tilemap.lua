local cfg = require("config")
local Assets = require("src.assets")

local Tilemap = {}
Tilemap.__index = Tilemap

-- Fallback procedural colors for tiles (used when no tileset image loaded)
local FALLBACK_COLORS = {
  [0] = {0, 0, 0, 0},                    -- empty/transparent
  [1] = {0.18, 0.28, 0.42, 1.0},        -- dark blue (decor)
  [2] = {0.20, 0.36, 0.50, 1.0},        -- medium blue (decor)
  [3] = {0.40, 0.75, 0.30, 1.0},        -- grass green (decor)
  
  -- Platform tiles (solids)
  [10] = {0.35, 0.25, 0.20, 1.0},       -- brown stone
  [11] = {0.45, 0.35, 0.25, 1.0},       -- lighter stone
  [12] = {0.30, 0.22, 0.18, 1.0},       -- darker stone
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

  -- IMPORTANT: Copy over optional level data
  self.checkpoints = data.checkpoints or {}
  self.bossSpawn = data.bossSpawn  -- This was missing!
  
  -- Debug log
  if self.bossSpawn then
    print("Tilemap: Boss spawn loaded at", self.bossSpawn.x, self.bossSpawn.y, "trigger:", self.bossSpawn.triggerX)
  else
    print("Tilemap: No boss spawn defined in level")
  end

  -- Try to load tileset image (optional)
  self.tileset = Assets.get("tileset") or Assets.loadOptional("tileset", "assets/gfx/tiles/tileset.png")
  
  -- If tileset exists, build quads for each tile ID
  if self.tileset then
    self.quads = {}
    local imgW, imgH = self.tileset:getWidth(), self.tileset:getHeight()
    local tilesX = math.floor(imgW / self.ts)
    local tilesY = math.floor(imgH / self.ts)
    
    -- Build quad lookup: tileID -> quad
    local id = 0
    for ty = 0, tilesY - 1 do
      for tx = 0, tilesX - 1 do
        self.quads[id] = love.graphics.newQuad(
          tx * self.ts, ty * self.ts, self.ts, self.ts,
          imgW, imgH
        )
        id = id + 1
      end
    end
  end

  return self
end

-- Draw tiles in camera view
function Tilemap:draw(cameraX, resW, resH)
  local ts = self.ts
  local startX = math.max(1, math.floor(cameraX / ts) + 1)
  local endX   = math.min(self.tw, math.floor((cameraX + resW) / ts) + 1)

  -- BACKGROUND DECOR LAYER
  for y = 1, self.th do
    for x = startX, endX do
      local id = self.bg[y][x]
      if id and id ~= 0 then
        local px, py = (x-1)*ts, (y-1)*ts
        
        if self.tileset and self.quads[id] then
          -- Draw from tileset
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.draw(self.tileset, self.quads[id], px, py)
        else
          -- Procedural fallback
          local c = FALLBACK_COLORS[id] or {0.5, 0.5, 0.6, 1}
          love.graphics.setColor(c)
          love.graphics.rectangle("fill", px, py, ts, ts)
        end
      end
    end
  end

  -- SOLID PLATFORM LAYER (enhanced visuals)
  for y = 1, self.th do
    for x = startX, endX do
      if self.solids[y][x] then
        local px, py = (x-1)*ts, (y-1)*ts
        
        -- Choose tile appearance based on neighbors for variety
        local tileID = self:getSolidTileID(x, y)
        
        if self.tileset and self.quads[tileID] then
          -- Draw from tileset
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.draw(self.tileset, self.quads[tileID], px, py)
        else
          -- Enhanced procedural platform rendering
          self:drawProceduralPlatform(px, py, ts, x, y)
        end
      end
    end
  end

  love.graphics.setColor(1, 1, 1, 1)
end

-- Determine tile ID based on neighboring solids (for autotiling)
function Tilemap:getSolidTileID(x, y)
  local hasTop    = self:isSolidTile(x, y - 1)
  local hasBottom = self:isSolidTile(x, y + 1)
  local hasLeft   = self:isSolidTile(x - 1, y)
  local hasRight  = self:isSolidTile(x + 1, y)
  
  -- Simple tile selection (extend this for full autotiling)
  if not hasTop and hasBottom then
    return 10  -- top surface
  elseif hasTop and hasBottom then
    return 11  -- middle/filler
  else
    return 12  -- standalone/bottom
  end
end

-- Procedural platform rendering with texture-like detail
function Tilemap:drawProceduralPlatform(px, py, ts, tx, ty)
  -- Base platform color
  love.graphics.setColor(0.40, 0.30, 0.25, 1.0)
  love.graphics.rectangle("fill", px, py, ts, ts)
  
  -- Top edge highlight (grass/moss on top surface)
  if not self:isSolidTile(tx, ty - 1) then
    love.graphics.setColor(0.35, 0.70, 0.30, 1.0)
    love.graphics.rectangle("fill", px, py, ts, 3)
    
    -- Grass tufts
    love.graphics.setColor(0.30, 0.60, 0.25, 1.0)
    for i = 0, 2 do
      local gx = px + (i * 6) + ((tx + ty) % 3)
      love.graphics.rectangle("fill", gx, py, 2, 4)
    end
  end
  
  -- Side shading for depth
  love.graphics.setColor(0.25, 0.18, 0.15, 0.3)
  love.graphics.rectangle("fill", px + ts - 2, py, 2, ts)
  
  -- Stone texture detail (simple noise pattern)
  love.graphics.setColor(0.35, 0.25, 0.20, 0.5)
  local seed = tx * 7 + ty * 13
  for i = 0, 3 do
    local nx = px + ((seed * i * 3) % (ts - 2)) + 1
    local ny = py + ((seed * i * 5) % (ts - 2)) + 1
    love.graphics.rectangle("fill", nx, ny, 2, 2)
  end
  
  love.graphics.setColor(1, 1, 1, 1)
end

-- Tile query methods
function Tilemap:isSolidTile(tx, ty)
  if tx < 1 or ty < 1 or tx > self.tw or ty > self.th then return false end
  return self.solids[ty][tx] == true
end

function Tilemap:isSolidAt(px, py)
  local ts = self.ts
  local tx = math.floor(px / ts) + 1
  local ty = math.floor(py / ts) + 1
  return self:isSolidTile(tx, ty)
end

function Tilemap:aabbOverlapsSolid(x, y, w, h)
  local ts = self.ts
  local x0 = math.max(1, math.floor(x / ts) + 1)
  local y0 = math.max(1, math.floor(y / ts) + 1)
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