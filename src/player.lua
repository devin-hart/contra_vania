local cfg    = require("config")
local Anim   = require("src.anim")
local Assets = require("src.assets")
local dbg    = require("cv_debug")
local Audio  = require("src.audio")

local Player = {}
Player.__index = Player

function Player.new(world)
  local self = setmetatable({}, Player)

  self.sw = cfg.SPRITES.player.frameW
  self.sh = cfg.SPRITES.player.frameH
  self.jumpSW = cfg.SPRITES.player.jumpFrameW or self.sw
  self.jumpSH = cfg.SPRITES.player.jumpFrameH or self.sh

  self.x = 32
  self.y = world.floor - 15

  self.vx, self.vy = 0, 0
  self.speed   = cfg.PLAYER_SPEED
  self.jumpV   = cfg.PLAYER_JUMPV
  self.gravity = cfg.GRAVITY
  self.onGround = false
  self.facing   = 1
  self.world    = world

  local idleImg = Assets.get("player_idle")
  local runImg  = Assets.get("player_run")
  local jumpImg = Assets.get("player_jump")

  self.animIdle = Anim.new{
    image  = idleImg, frameW = self.sw, frameH = self.sh,
    frames = cfg.SPRITES.player.idleFrames, fps = cfg.ANIM.idle, loop = true
  }
  self.animRun  = Anim.new{
    image  = runImg,  frameW = self.sw, frameH = self.sh,
    frames = cfg.SPRITES.player.runFrames,  fps = cfg.ANIM.run,  loop = true
  }
  self.animJump = Anim.new{
    image   = jumpImg,
    frameW  = self.jumpSW,
    frameH  = self.jumpSH,
    frames  = cfg.SPRITES.player.jumpFrames,
    fps     = cfg.ANIM.jump,
    loop    = false
  }

  self.anim = self.animIdle
  
  self.hp = 3
  self.maxHp = 3
  self.ammo = math.huge
  self.maxAmmo = math.huge
  
  self.invincible = false
  self.invincibleTimer = 0
  self.invincibleDuration = 1.5
  self.damageFlashTimer = 0
  
  self.hitstunTimer = 0
  self.hitstunDuration = 0.3
  self.knockbackVelX = 0
  self.knockbackVelY = 0
  
  return self
end

local function chooseAnim(self)
  if not self.onGround then
    if self.anim ~= self.animJump then self.animJump:reset() end
    self.anim = self.animJump
  else
    if math.abs(self.vx) > 1 then
      self.anim = self.animRun
    else
      self.anim = self.animIdle
    end
  end
end

local function getSpriteSize(self)
  if self.onGround then
    return self.sw, self.sh
  else
    return self.jumpSW, self.jumpSH
  end
end

function Player:getCollider()
  local sw, sh = getSpriteSize(self)
  local w = math.floor(sw * 0.8)
  local h = math.floor(sh * 0.9)
  local x = self.x - math.floor(w / 2)
  local y = self.y - math.floor(h / 2)
  return x, y, w, h
end

local function getFeetY(self)
  local _, sh = getSpriteSize(self)
  return self.y + math.floor(sh / 2)
end

local function getHeadY(self)
  local _, sh = getSpriteSize(self)
  return self.y - math.floor(sh / 2)
end

function Player:update(dt, input, map)
  local inHistun = self.hitstunTimer > 0
  
  -- Update timers
  if self.invincible then
    self.invincibleTimer = self.invincibleTimer - dt
    if self.invincibleTimer <= 0 then
      self.invincible = false
      self.invincibleTimer = 0
    end
  end
  
  if self.damageFlashTimer > 0 then
    self.damageFlashTimer = self.damageFlashTimer - dt
  end
  
  if self.hitstunTimer > 0 then
    self.hitstunTimer = self.hitstunTimer - dt
  end
  
  -- Apply knockback velocity during hitstun
  if inHistun then
    self.vx = self.knockbackVelX
    if self.knockbackVelY ~= 0 then
      self.vy = self.knockbackVelY
      self.knockbackVelY = 0  -- Only apply upward pop once
    end
  else
    -- Normal input (only when not in hitstun)
    local left  = input and input.isDown and input.isDown("left")
    local right = input and input.isDown and input.isDown("right")
    self.vx = 0
    if left  then self.vx = self.vx - self.speed; self.facing = -1 end
    if right then self.vx = self.vx + self.speed; self.facing =  1 end
    
    -- Jump
    if input and input.wasPressed and input.wasPressed("jump") and self.onGround then
      self.vy = self.jumpV
      self.onGround = false
      self.animJump:reset()
      Audio.playSFX("jump")
    end
  end

  -- Gravity
  self.vy = self.vy + self.gravity * dt

  -- HORIZONTAL MOVEMENT
  if self.vx ~= 0 then
    local newX = self.x + self.vx * dt
    local oldX = self.x
    self.x = newX
    
    if map then
      local cx, cy, cw, ch = self:getCollider()
      if map:aabbOverlapsSolid(cx, cy, cw, ch) then
        self.x = oldX
        self.vx = 0
        self.knockbackVelX = 0  -- Stop knockback on wall hit
      end
    end
  end

  -- VERTICAL MOVEMENT
  local newY = self.y + self.vy * dt
  self.y = newY
  
  if map then
    local cx, cy, cw, ch = self:getCollider()
    local ts = map.ts
    
    if self.vy >= 0 then
      local feetY = getFeetY(self)
      local leftX = cx + 2
      local rightX = cx + cw - 2
      
      if map:isSolidAt(leftX, feetY) or map:isSolidAt(rightX, feetY) then
        local tileY = math.floor(feetY / ts)
        local groundY = tileY * ts
        local _, sh = getSpriteSize(self)
        self.y = groundY - math.floor(sh / 2)
        self.vy = 0
        self.onGround = true
      else
        self.onGround = false
      end
      
    elseif self.vy < 0 then
      if map:aabbOverlapsSolid(cx, cy, cw, ch) then
        local headY = getHeadY(self)
        local tileY = math.floor(headY / ts)
        local ceilingY = (tileY + 1) * ts
        local _, sh = getSpriteSize(self)
        self.y = ceilingY + math.floor(sh / 2)
        self.vy = 0
      end
    end
    
    if self.onGround and self.vy == 0 then
      local feetY = getFeetY(self) + 2
      local leftX = cx + 2
      local rightX = cx + cw - 2
      if not (map:isSolidAt(leftX, feetY) or map:isSolidAt(rightX, feetY)) then
        self.onGround = false
      end
    end
  else
    local feetY = getFeetY(self)
    if feetY >= self.world.floor then
      local _, sh = getSpriteSize(self)
      self.y = self.world.floor - math.floor(sh / 2)
      self.vy = 0
      self.onGround = true
    else
      self.onGround = false
    end
  end

  local cx, cy, cw, ch = self:getCollider()
  local minX = math.floor(cw / 2)
  local maxX = (self.world.width or 320) - math.floor(cw / 2)
  if self.x < minX then self.x = minX end
  if self.x > maxX then self.x = maxX end

  chooseAnim(self)
  self.anim:update(dt)
end

function Player:draw()
  local flip = (self.facing < 0)
  local sw, sh = getSpriteSize(self)
  local drawX = self.x - math.floor(sw / 2)
  local drawY = self.y - math.floor(sh / 2)
  
  if self.damageFlashTimer > 0 then
    love.graphics.setColor(1, 0.3, 0.3, 1)
  elseif self.invincible and math.floor(self.invincibleTimer * 10) % 2 == 0 then
    love.graphics.setColor(1, 1, 1, 0.3)
  else
    love.graphics.setColor(1, 1, 1, 1)
  end
  
  self.anim:draw(drawX, drawY, flip)
  love.graphics.setColor(1, 1, 1, 1)

  if dbg.isVisible and dbg.isVisible() then
    local cx, cy, cw, ch = self:getCollider()
    
    local hitboxColor = self.invincible and {0, 1, 1, 0.35} or {1, 1, 0, 0.35}
    love.graphics.setColor(hitboxColor)
    love.graphics.rectangle("fill", cx, cy, cw, ch)
    love.graphics.setColor(self.invincible and {0, 1, 1, 1} or {1, 1, 0, 1})
    love.graphics.rectangle("line", cx, cy, cw, ch)
    
    local sw, sh = getSpriteSize(self)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("line", self.x - sw/2, self.y - sh/2, sw, sh)
    
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.circle("fill", self.x, self.y, 2)
    
    -- Show hitstun status
    if self.hitstunTimer > 0 then
      love.graphics.setColor(1, 0, 0, 1)
      love.graphics.print("HITSTUN", self.x - 20, self.y - 40)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
  end
end

function Player:getMuzzle()
  local mx = self.x + (self.facing >= 0 and cfg.PROJ.muzzleX or -cfg.PROJ.muzzleX)
  local my = self.y + cfg.PROJ.muzzleY
  Audio.playSFX("shoot")
  return mx, my, self.facing
end

function Player:takeDamage(amount, sourceX)
  if self.invincible then return false end
  
  self.hp = math.max(0, self.hp - (amount or 1))
  self.invincible = true
  self.invincibleTimer = self.invincibleDuration
  self.damageFlashTimer = 0.2
  self.hitstunTimer = self.hitstunDuration
  
  -- Apply knockback away from damage source
  if sourceX then
    local knockbackDir = self.x > sourceX and 1 or -1
    self.knockbackVelX = knockbackDir * 150  -- Stronger horizontal push
    if self.onGround then
      self.knockbackVelY = -120  -- Small upward pop
      self.onGround = false
    end
  end
  
  Audio.playSFX("hit")
  
  return self.hp <= 0
end

function Player:heal(amount)
  self.hp = math.min(self.maxHp, self.hp + (amount or 1))
end

function Player:respawn(x, y)
  self.x = x
  self.y = y
  self.vx = 0
  self.vy = 0
  self.onGround = false
  self.hp = self.maxHp
  self.facing = 1
  self.invincible = false
  self.invincibleTimer = 0
  self.damageFlashTimer = 0
  self.hitstunTimer = 0
  self.knockbackVelX = 0
  self.knockbackVelY = 0
end

return Player