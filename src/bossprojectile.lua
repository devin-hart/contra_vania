local cfg = require("config")

local BossProjectile = {}
BossProjectile.__index = BossProjectile

-- opts: { x, y, vx, vy, type }
function BossProjectile.new(opts)
  local self = setmetatable({}, BossProjectile)
  self.x = assert(opts.x, "BossProjectile.new: x required")
  self.y = assert(opts.y, "BossProjectile.new: y required")
  self.vx = opts.vx or 0
  self.vy = opts.vy or 0
  
  self.type = opts.type or "normal"  -- normal, homing, spread
  self.w = opts.w or 8
  self.h = opts.h or 8
  self.life = opts.life or 5.0  -- seconds
  self.damage = opts.damage or 1
  
  -- Homing behavior
  self.homingStrength = opts.homingStrength or 0
  self.speed = opts.speed or math.sqrt(self.vx * self.vx + self.vy * self.vy)
  
  -- Visual
  self.color = opts.color or {0.9, 0.2, 0.3, 1}
  self.rotation = 0
  
  return self
end

function BossProjectile:update(dt, player)
  -- Homing behavior
  if self.homingStrength > 0 and player then
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    
    if dist > 0 then
      -- Steer toward player
      local targetVX = (dx / dist) * self.speed
      local targetVY = (dy / dist) * self.speed
      
      self.vx = self.vx + (targetVX - self.vx) * self.homingStrength * dt
      self.vy = self.vy + (targetVY - self.vy) * self.homingStrength * dt
    end
  end
  
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  self.life = self.life - dt
  
  -- Update rotation based on velocity
  self.rotation = math.atan2(self.vy, self.vx)
  
  return self.life > 0
end

function BossProjectile:getCollider()
  return self.x - self.w * 0.5, self.y - self.h * 0.5, self.w, self.h
end

function BossProjectile:draw()
  love.graphics.push()
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.rotation)
  
  love.graphics.setColor(self.color)
  
  if self.type == "homing" then
    -- Diamond shape for homing projectiles
    love.graphics.polygon("fill", 
      0, -self.h/2,
      self.w/2, 0,
      0, self.h/2,
      -self.w/2, 0
    )
  else
    -- Regular rectangle
    love.graphics.rectangle("fill", -self.w/2, -self.h/2, self.w, self.h)
  end
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.pop()
end

return BossProjectile