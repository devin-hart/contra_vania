-- Super-lightweight camera that follows a target and clamps to world bounds
local Camera = {}
Camera.__index = Camera

function Camera.new()
  return setmetatable({ x = 0, y = 0 }, Camera)
end

local function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

-- target: expects pivot at feet (x,y). Falls back if w/h exist.
function Camera:update(target, world, viewW, viewH)
  -- derive target size (prefer collider, then sprite, then old w/h)
  local tw = target.cw or target.sw or target.w or 0
  local th = target.ch or target.sh or target.h or 0

  -- pivot model: center on X by pivot; for Y, center around body (feet minus half height)
  local centerX = target.x
  local centerY = (th > 0) and (target.y - th * 0.5) or target.y

  local desiredX = centerX - viewW * 0.5
  local desiredY = centerY - viewH * 0.5

  local maxX = math.max(0, (world.width or viewW)  - viewW)
  local maxY = math.max(0, (world.height or viewH) - viewH)

  self.x = math.max(0, math.min(desiredX, maxX))
  self.y = math.max(0, math.min(desiredY, maxY))
  return self.x, self.y
end

function Camera:apply()
  love.graphics.push()
  love.graphics.translate(-math.floor(self.x), -math.floor(self.y))
end

function Camera:clear()
  love.graphics.pop()
end

return Camera
