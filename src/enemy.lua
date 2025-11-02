local cfg    = require("config")
local Anim   = require("src.anim")
local Assets = require("src.assets")
local dbg    = require("cv_debug")

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(opts)
  local self = setmetatable({}, Enemy)

  self.x = assert(opts.x, "Enemy.new: x required")
  self.y = assert(opts.y, "Enemy.new: y required")

  self.patrolMin = assert(opts.patrolMin, "Enemy.new: patrolMin required")
  self.patrolMax = assert(opts.patrolMax, "Enemy.new: patrolMax required")
  if self.patrolMin > self.patrolMax then
    self.patrolMin, self.patrolMax = self.patrolMax, self.patrolMin
  end

  self.speed = opts.speed or 40
  self.dir   = 1
  self.vy    = 0  -- vertical velocity for gravity

  self.sw = (cfg.ENEMY and cfg.ENEMY.spriteW) or 16
  self.sh = (cfg.ENEMY and cfg.ENEMY.COLLIDER and cfg.ENEMY.COLLIDER.h) or 16

  local ecoll = (cfg.ENEMY and cfg.ENEMY.COLLIDER) or {}
  self.cw  = ecoll.w  or 14
  self.ch  = opts.customH or ecoll.h or 14
  self.cox = ecoll.ox or 0
  self.coy = ecoll.oy or 0

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
  self.hp        = (cfg.ENEMY and cfg.ENEMY.hp) or 1
  self.hitTimer  = 0
  self.deathTime = 0
  self.dead      = false

  return self
end

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

-- Check if there's ground ahead (prevent walking off ledges)
local function hasGroundAhead(self, map, checkX)
  if not map then return true end
  local feetY = self.y + 1
  return map:isSolidAt(checkX, feetY)
end

-- Check if there's a wall ahead
local function hasWallAhead(self, map, checkX)
  if not map then return false end
  local topY = self.y - self.ch
  local midY = self.y - math.floor(self.ch / 2)
  return map:isSolidAt(checkX, topY) or map:isSolidAt(checkX, midY)
end

function Enemy:update(dt, world, map)
  if self.dead then
    self.deathTime = self.deathTime - dt
    return
  end

  if self.hitTimer and self.hitTimer > 0 then
    self.hitTimer = self.hitTimer - dt
    if self.hitTimer < 0 then self.hitTimer = 0 end
  end

  -- Apply gravity if using tilemap
  if map then
    self.vy = self.vy + cfg.GRAVITY * dt
    local newY = self.y + self.vy * dt
    
    -- Check for ground
    local feetY = newY + 1
    local leftX = self.x - math.floor(self.cw / 2)
    local rightX = self.x + math.floor(self.cw / 2) - 1
    
    if map:isSolidAt(leftX, feetY) or map:isSolidAt(rightX, feetY) then
      -- Snap to ground
      local ts = map.ts
      local tileY = math.floor(newY / ts)
      self.y = tileY * ts
      self.vy = 0
    else
      self.y = newY
    end
  else
    -- Legacy floor
    self.y = world.floor
  end

  -- Horizontal patrol movement
  local newX = self.x + self.dir * self.speed * dt
  local halfW = math.floor(self.cw / 2)
  local lookAhead = self.dir > 0 and (newX + halfW + 2) or (newX - halfW - 2)
  
  -- Check for walls or ledges
  local hitWall = map and hasWallAhead(self, map, lookAhead)
  local noGround = map and not hasGroundAhead(self, map, lookAhead)
  local atBounds = newX >= self.patrolMax or newX <= self.patrolMin
  
  if hitWall or noGround or atBounds then
    -- Turn around
    self.dir = -self.dir
    if atBounds then
      self.x = (newX >= self.patrolMax) and self.patrolMax or self.patrolMin
    end
  else
    self.x = newX
  end

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
    if flash then love.graphics.setColor(1, 0.25, 0.25, alpha) else love.graphics.setColor(1, 1, 1, alpha) end
    self.anim:draw(dx, dy, flip)
  else
    local r,g,b = (flash and 1 or 0.4), (flash and 0.25 or 0.9), (flash and 0.25 or 0.4)
    love.graphics.setColor(r, g, b, alpha)
    local x, y, w, h = self:getCollider()
    love.graphics.rectangle("fill", math.floor(x), math.floor(y), w, h)
    love.graphics.setColor(1, 1, 1, 1)
  end

  local lineLen = 6
  local lx1 = self.x
  local ly1 = self.y - self.sh - 2
  local lx2 = lx1 + (self.dir * lineLen)
  love.graphics.setColor(0.8, 0.8, 0.2, 1)
  love.graphics.line(lx1, ly1, lx2, ly1)
  love.graphics.setColor(1, 1, 1, 1)

  if dbg.isVisible and dbg.isVisible() then
    local x, y, w, h = self:getCollider()
    love.graphics.setColor(1, 1, 0, 0.35)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

return Enemy