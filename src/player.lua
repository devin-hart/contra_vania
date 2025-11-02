local cfg    = require("config")
local Anim   = require("src.anim")
local Assets = require("src.assets")
local dbg    = require("cv_debug")

local Player = {}
Player.__index = Player

function Player.new(world)
  local self = setmetatable({}, Player)

  -- SPRITE size from sheet (used only for drawing)
  self.sw = cfg.SPRITES.player.frameW
  self.sh = cfg.SPRITES.player.frameH

  -- COLLIDER (gameplay) size, independent of sprite
  self.cw = (cfg.COLLIDER and cfg.COLLIDER.player.w) or self.sw
  self.ch = (cfg.COLLIDER and cfg.COLLIDER.player.h) or self.sh
  self.cox = (cfg.COLLIDER and cfg.COLLIDER.player.ox) or 0
  self.coy = (cfg.COLLIDER and cfg.COLLIDER.player.oy) or 0

  -- PIVOT: feet-center in world space
  self.x = 32                   -- pivot X (feet center)
  self.y = world.floor          -- pivot Y (on the floor)

  self.vx, self.vy = 0, 0
  self.speed   = cfg.PLAYER_SPEED
  self.jumpV   = cfg.PLAYER_JUMPV
  self.gravity = cfg.GRAVITY
  self.onGround = false
  self.facing = 1
  self.world = world

  -- Try to fetch images (may be nil -> procedural fallback)
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
    frameW  = cfg.SPRITES.player.jumpFrameW or cfg.SPRITES.player.frameW,
    frameH  = cfg.SPRITES.player.jumpFrameH or cfg.SPRITES.player.frameH,
    frames  = cfg.SPRITES.player.jumpFrames,
    fps     = cfg.ANIM.jump,
    loop    = false
  }

  self.anim = self.animIdle
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

-- Helpers: collider rectangle from pivot
local function colliderRect(self)
  local x = self.x - math.floor(self.cw / 2) + self.cox
  local y = self.y - self.ch + self.coy
  return x, y, self.cw, self.ch
end

-- Check if player's feet would be on solid ground at given position
local function isGrounded(self, map, testY)
  if not map then return testY >= self.world.floor end
  
  local cx, cy, cw, ch = colliderRect(self)
  -- Check bottom edge (feet) + 1 pixel below
  local feetY = testY
  local leftX = self.x - math.floor(self.cw / 2)
  local rightX = self.x + math.floor(self.cw / 2) - 1
  
  return map:isSolidAt(leftX, feetY + 1) or map:isSolidAt(rightX, feetY + 1)
end

function Player:update(dt, input, map)
  -- horizontal input
  local left  = input and input.isDown and input.isDown("left")
  local right = input and input.isDown and input.isDown("right")
  self.vx = 0
  if left  then self.vx = self.vx - self.speed; self.facing = -1 end
  if right then self.vx = self.vx + self.speed; self.facing =  1 end

  -- jump (edge-triggered)
  if input and input.wasPressed and input.wasPressed("jump") and self.onGround then
    self.vy = self.jumpV
    self.onGround = false
    self.animJump:reset()
  end

  -- Apply gravity
  self.vy = self.vy + self.gravity * dt

  -- HORIZONTAL MOVEMENT with wall collision
  if self.vx ~= 0 then
    local newX = self.x + self.vx * dt
    local cx, cy, cw, ch = colliderRect(self)
    cy = self.y - self.ch
    
    -- Check left/right walls
    if map then
      local checkX = (self.vx > 0) and (newX + math.floor(cw/2)) or (newX - math.floor(cw/2))
      local topY = cy
      local botY = cy + ch - 1
      
      local hitWall = map:isSolidAt(checkX, topY) or 
                      map:isSolidAt(checkX, topY + math.floor(ch/2)) or
                      map:isSolidAt(checkX, botY)
      
      if not hitWall then
        self.x = newX
      end
    else
      self.x = newX
    end
  end

  -- VERTICAL MOVEMENT with ceiling/floor collision
  local newY = self.y + self.vy * dt
  local cx, cy, cw, ch = colliderRect(self)
  
  if map then
    if self.vy > 0 then
      -- Falling - check for ground
      if isGrounded(self, map, newY) then
        -- Snap to ground
        local ts = map.ts
        local tileY = math.floor(newY / ts)
        self.y = tileY * ts
        self.vy = 0
        self.onGround = true
      else
        self.y = newY
        self.onGround = false
      end
    elseif self.vy < 0 then
      -- Rising - check for ceiling
      local headY = newY - self.ch
      local leftX = self.x - math.floor(self.cw / 2)
      local rightX = self.x + math.floor(self.cw / 2) - 1
      
      if map:isSolidAt(leftX, headY) or map:isSolidAt(rightX, headY) then
        -- Hit ceiling
        self.vy = 0
        local ts = map.ts
        local tileY = math.floor(headY / ts) + 1
        self.y = tileY * ts + self.ch
      else
        self.y = newY
        self.onGround = false
      end
    end
  else
    -- Legacy floor collision
    self.y = newY
    if self.y >= self.world.floor then
      self.y = self.world.floor
      self.vy = 0
      self.onGround = true
    end
  end

  -- Clamp horizontally to world bounds
  local half = math.floor(self.cw / 2)
  local maxX = (self.world.width or self.world.W) - half
  if self.x < half then self.x = half end
  if self.x > maxX then self.x = maxX end

  -- state → animation
  chooseAnim(self)
  self.anim:update(dt)
end

function Player:draw()
  -- Draw sprite aligned to pivot using a default anchor: (sw/2, sh) i.e., feet-center
  local flip = (self.facing < 0)
  local ax, ay = math.floor(self.sw / 2), self.sh
  local drawX = self.x - ax
  local drawY = self.y - ay
  self.anim:draw(drawX, drawY, flip)

  -- Debug: draw collider box when overlay is visible
  if dbg.isVisible and dbg.isVisible() then
    local x, y, w, h = colliderRect(self)
    love.graphics.setColor(1, 1, 0, 0.35)   -- translucent fill
    love.graphics.rectangle("fill", math.floor(x), math.floor(y), w, h)
    love.graphics.setColor(1, 1, 0, 1)      -- outline
    love.graphics.rectangle("line", math.floor(x), math.floor(y), w, h)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

function Player:getMuzzle()
  local mx = self.x + (self.facing >= 0 and cfg.PROJ.muzzleX or -cfg.PROJ.muzzleX)
  local my = self.y + cfg.PROJ.muzzleY
  return mx, my, self.facing
end

function Player:getCollider()
  local x = self.x - math.floor(self.cw / 2) + self.cox
  local y = self.y - self.ch + self.coy
  return x, y, self.cw, self.ch
end

return Player