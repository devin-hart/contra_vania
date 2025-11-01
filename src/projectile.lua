local cfg = require("config")

local Projectile = {}
Projectile.__index = Projectile

-- opts: { x, y, dir }
function Projectile.new(opts)
  local self = setmetatable({}, Projectile)
  self.x   = assert(opts.x, "Projectile.new: x required")
  self.y   = assert(opts.y, "Projectile.new: y required")
  self.dir = (opts.dir and opts.dir >= 0) and 1 or -1

  self.w   = cfg.PROJ.w
  self.h   = cfg.PROJ.h
  self.vx  = self.dir * cfg.PROJ.speed
  self.life = cfg.PROJ.life -- seconds

  return self
end

function Projectile:update(dt)
  self.x = self.x + self.vx * dt
  self.life = self.life - dt
  return self.life > 0
end

function Projectile:getCollider()
  return self.x - self.w * 0.5, self.y - self.h * 0.5, self.w, self.h
end

function Projectile:draw()
  love.graphics.setColor(cfg.COLORS.accent)
  local x, y, w, h = self:getCollider()
  love.graphics.rectangle("fill", math.floor(x), math.floor(y), w, h)
  love.graphics.setColor(1, 1, 1, 1)
end

return Projectile
