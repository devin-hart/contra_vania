local cfg = require("config")

local B = {}

local function px(v)
  return math.floor(v + 0.5)
end

local function hillY(baseY, amp, x, wavelength)
  return baseY + math.sin(x / wavelength) * amp
end

-- Draw mountain silhouettes (distant layer)
local function drawMountains(camx, W, H)
  love.graphics.setColor(0.12, 0.22, 0.35, 1.0)
  
  local off = px(camx * 0.15)  -- very slow parallax (0.15x)
  local verts = {}
  local step = 16
  local baseY = H * 0.55
  
  for x = -64, W + 64, step do
    local sx = px(x - off)
    local peak1 = math.sin((sx + 100) / 180) * 35
    local peak2 = math.sin((sx + 300) / 220) * 45
    local y = baseY - peak1 - peak2
    verts[#verts+1] = sx
    verts[#verts+1] = px(y)
  end
  
  verts[#verts+1] = W + 64
  verts[#verts+1] = H
  verts[#verts+1] = -64
  verts[#verts+1] = H
  
  love.graphics.polygon("fill", verts)
end

-- Draw rolling hills (mid-distance)
local function drawHills(yBase, amp, wavelength, phase, color, parallax, camx, W, H)
  love.graphics.setColor(color)
  local off = px(camx * parallax + phase)
  local verts = {}
  local step = 12
  
  for x = -64, W + 64, step do
    local sx = px(x - off)
    local y = px(hillY(yBase, amp, sx, wavelength))
    verts[#verts+1] = sx
    verts[#verts+1] = y
  end
  
  verts[#verts+1] = W + 64
  verts[#verts+1] = H
  verts[#verts+1] = -64
  verts[#verts+1] = H
  
  love.graphics.polygon("fill", verts)
end

-- Draw floating clouds (atmospheric layer)
local function drawClouds(camx, W, H)
  love.graphics.setColor(1, 1, 1, 0.15)
  
  local off = px(camx * 0.08)  -- super slow (0.08x)
  local cloudY = {H * 0.15, H * 0.25, H * 0.35}
  
  for i = 1, 3 do
    local cx = ((i * 200) - off) % (W + 400) - 200
    local cy = cloudY[i]
    
    -- Simple cloud shape (3 overlapping circles)
    love.graphics.ellipse("fill", cx, cy, 40, 18)
    love.graphics.ellipse("fill", cx - 25, cy + 5, 30, 15)
    love.graphics.ellipse("fill", cx + 25, cy + 5, 30, 15)
  end
end

-- Draw distant trees/foliage (foreground parallax)
local function drawFoliage(camx, W, H)
  love.graphics.setColor(0.15, 0.25, 0.20, 0.6)
  
  local off = px(camx * 0.75)  -- fast parallax (0.75x)
  local groundY = H * 0.82
  
  -- Simple tree silhouettes
  for i = 0, 8 do
    local tx = ((i * 140) - off) % (W + 280) - 140
    local th = 25 + (i % 3) * 8
    
    -- Tree trunk
    love.graphics.rectangle("fill", tx - 3, groundY - th, 6, th)
    
    -- Tree foliage (triangle)
    love.graphics.polygon("fill",
      tx, groundY - th - 15,
      tx - 12, groundY - th,
      tx + 12, groundY - th
    )
  end
end

function B.draw(camx, W, H)
  -- Sky gradient background
  love.graphics.clear(cfg.COLORS.sky)
  
  -- Layer ordering (back to front)
  drawClouds(camx, W, H)
  drawMountains(camx, W, H)
  drawHills(H * 0.70, 8, 90, 0, cfg.COLORS.hill_far, cfg.PARALLAX.far, camx, W, H)
  drawHills(H * 0.78, 12, 70, 0, cfg.COLORS.hill_near, cfg.PARALLAX.near, camx, W, H)
  drawFoliage(camx, W, H)
end

return B