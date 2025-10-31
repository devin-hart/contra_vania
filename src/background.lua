local cfg = require("config")

local B = {}

local function px(v)           -- snap to nearest pixel
  return math.floor(v + 0.5)
end

local function hillY(baseY, amp, x, wavelength)
  return baseY + math.sin(x / wavelength) * amp
end

local function drawHills(yBase, amp, wavelength, phase, color, parallax, camx, W, H)
  love.graphics.setColor(color)

  -- snap the parallax offset to whole pixels to prevent shimmer
  local off = px(camx * parallax + phase)

  local verts = {}
  local step = 12      -- a bit denser than 16 to reduce faceting

  local startX = -64
  local endX   = W + 64

  for x = startX, endX, step do
    local sx = px(x - off)                 -- screen x, snapped
    local y  = px(hillY(yBase, amp, sx, wavelength))
    verts[#verts+1] = sx
    verts[#verts+1] = y
  end

  -- close polygon to bottom
  verts[#verts+1] = endX
  verts[#verts+1] = H
  verts[#verts+1] = startX
  verts[#verts+1] = H

  love.graphics.polygon("fill", verts)
end

function B.draw(camx, W, H)
  love.graphics.clear(cfg.COLORS.sky)
  drawHills(H * 0.70, 8,  90, 0, cfg.COLORS.hill_far,  cfg.PARALLAX.far,  camx, W, H)
  drawHills(H * 0.78, 12, 70, 0, cfg.COLORS.hill_near, cfg.PARALLAX.near, camx, W, H)
end

return B
