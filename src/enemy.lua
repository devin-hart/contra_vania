local cfg    = require("config")
local Anim   = require("src.anim")
local Assets = require("src.assets")
local dbg    = require("cv_debug")

-- Patrolling enemy with pivot-at-feet and fixed collider.
local Enemy = {}
Enemy.__index = Enemy

-- opts: { x, y, patrolMin, patrolMax, speed }
function Enemy.new(opts)
  local self = setmetatable({}, Enemy)

  -- PIVOT (feet-center). If y not given, caller should pass world.floor.
  self.x = assert(opts.x, "Enemy.new: x required")
  self.y = assert(opts.y, "Enemy.new: y required")

  -- Patrol bounds (inclusive)
  self.patrolMin = assert(opts.patrolMin, "Enemy.new: patrolMin required")
  self.patrolMax = assert(opts.patrolMax, "Enemy.new: patrolMax required")
  if self.patrolMin > self.patrolMax then
    self.patrolMin, self.patrolMax = self.patrolMax, self.patrolMin
  end

  self.speed = opts.speed or 40
  self.dir   = 1  -- 1:right, -1:left

  -- SPRITE dimensions (use config if present, else fallback)
  self.sw = (cfg.ENEMY and cfg.ENEMY.spriteW) or 16
  self.sh = (cfg.ENEMY and cfg.ENEMY.COLLIDER and cfg.ENEMY.COLLIDER.h) or 16

  -- COLLIDER (hurtbox) independent of sprite size
  local ecoll = (cfg.ENEMY and cfg.ENEMY.COLLIDER) or {}
  self.cw  = ecoll.w  or 14
  self.ch  = opts.customH or ecoll.h or 14
  self.cox = ecoll.ox or 0
  self.coy = ecoll.oy or 0

  -- Try to load sprites (optional). Fallback: procedural anim.
  local idleImg = Assets.get("enemy_idle") or Assets.loadOptional("enemy_idle", "assets/gfx/enemy/idle_strip.png")
  local walkImg = Assets.get("enemy_walk") or Assets.loadOptional("enemy_walk", "assets/gfx/enemy/walk_strip.png")

  self.animIdle = Anim.new{
    image  = idleImg,
    frameW = self.sw, frameH = self.sh,
    frames = (cfg.ENEMY and cfg.ENEMY.idleFrames) or 2,
    fps    = (cfg.ENEMY and cfg.ENEMY.animIdleFPS) or 3,
    loop   = true
  }
  self.animWalk = Anim.new{
    image  = walkImg,
    frameW = self.sw, frameH = self.sh,
    frames = (cfg.ENEMY and cfg.ENEMY.walkFrames) or 4,
    fps    = (cfg.ENEMY and cfg.ENEMY.animWalkFPS) or 8,
    loop   = true
  }

  self.anim = self.animWalk
    -- Health / hit feedback
  self.hp        = (cfg.ENEMY and cfg.ENEMY.hp) or 1
  self.hitTimer  = 0
  self.deathTime = 0
  self.dead      = false

  return self
end

-- Collider rectangle (from pivot)
function Enemy:getCollider()
  local x = self.x - math.floor(self.cw / 2) + self.cox
  local y = self.y - self.ch + self.coy
  return x, y, self.cw, self.ch
end

function Enemy:takeDamage(dmg)
  if self.dead then return end
  self.hp = math.max(0, self.hp - (dmg or 1))
  self.hitTimer = (cfg.ENEMY and cfg.ENEMY.hitFlash) or 0.1
  if self.hp <= 0 then
    self.dead = true
    self.deathTime = (cfg.ENEMY and cfg.ENEMY.deathTime) or 0.2
  end
end

function Enemy:update(dt, world)
      -- death countdown
  if self.dead then
    self.deathTime = self.deathTime - dt
    return
  end

  -- tick hit flash
  if self.hitTimer and self.hitTimer > 0 then
    self.hitTimer = self.hitTimer - dt
    if self.hitTimer < 0 then self.hitTimer = 0 end
  end
  -- Patrol movement
  self.x = self.x + self.dir * self.speed * dt

  if self.x >= self.patrolMax then
    self.x = self.patrolMax
    self.dir = -1
  elseif self.x <= self.patrolMin then
    self.x = self.patrolMin
    self.dir = 1
  end

  -- Keep feet on floor (pivot = feet-center)
  self.y = world.floor

  -- Choose anim
  self.anim = self.dir ~= 0 and self.animWalk or self.animIdle
  self.anim:update(dt)
end

function Enemy:draw()
  local flash = self.hitTimer and self.hitTimer > 0
  local alpha = 1.0
  if self.dead then
    alpha = math.max(0, self.deathTime / ((cfg.ENEMY and cfg.ENEMY.deathTime) or 0.2))
  end

  local flip = (self.dir < 0)
  local ax, ay = math.floor(self.sw / 2), self.sh
  local dx = self.x - ax
  local dy = self.y - ay

  if self.anim and self.anim.image then
    -- Sprite sheet exists: tint the image
    if flash then love.graphics.setColor(1, 0.25, 0.25, alpha) else love.graphics.setColor(1, 1, 1, alpha) end
    self.anim:draw(dx, dy, flip)
  else
    -- Procedural fallback: draw our own rectangle so flash color isn't overridden
    local r,g,b = (flash and 1 or 0.4), (flash and 0.25 or 0.9), (flash and 0.25 or 0.4)
    love.graphics.setColor(r, g, b, alpha)
    local x, y, w, h = self:getCollider()
    love.graphics.rectangle("fill", math.floor(x), math.floor(y), w, h)
    love.graphics.setColor(1, 1, 1, 1)
  end

    -- Facing direction indicator (small line above head)
  local lineLen = 6
  local lx1 = self.x
  local ly1 = self.y - self.sh - 2
  local lx2 = lx1 + (self.dir * lineLen)
  love.graphics.setColor(0.8, 0.8, 0.2, 1)
  love.graphics.line(lx1, ly1, lx2, ly1)
  love.graphics.setColor(1, 1, 1, 1)

  -- Debug collider overlay
  if dbg.isVisible and dbg.isVisible() then
    local x, y, w, h = self:getCollider()
    love.graphics.setColor(1, 1, 0, 0.35); love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 0, 1);    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
  end
end



return Enemy
