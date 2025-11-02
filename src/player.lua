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
  self.cw  = (cfg.COLLIDER and cfg.COLLIDER.player.w)  or self.sw
  self.ch  = (cfg.COLLIDER and cfg.COLLIDER.player.h)  or self.sh
  self.cox = (cfg.COLLIDER and cfg.COLLIDER.player.ox) or 0
  self.coy = (cfg.COLLIDER and cfg.COLLIDER.player.oy) or 0

  -- PIVOT: feet-center in world space
  self.x = 32
  self.y = world.floor

  self.vx, self.vy = 0, 0
  self.speed   = cfg.PLAYER_SPEED
  self.jumpV   = cfg.PLAYER_JUMPV
  self.gravity = cfg.GRAVITY
  self.onGround = true
  self.facing   = 1
  self.world    = world

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

-- Helper to get collider rect from pivot
local function colliderRect(self)
  local x = self.x - math.floor(self.cw / 2) + self.cox
  local y = self.y - self.ch + self.coy
  return x, y, self.cw, self.ch
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

  -- integrate motion (pivot-based)
  self.x = self.x + self.vx * dt
  self.vy = self.vy + self.gravity * dt
  self.y  = self.y + self.vy * dt

  -- vertical resolve: prefer map tiles; fall back to legacy flat floor if no solids
  local landedViaMap = false
  if map then
    local x, y, w, h = colliderRect(self)
    local ts = map.ts

    if self.vy > 0 then
      -- falling: if overlapping a solid, snap feet to tile top
      if map:aabbOverlapsSolid(x, y, w, h) then
        local bottom     = y + h
        local topOfSolid = math.floor(bottom / ts) * ts
        self.y  = topOfSolid
        self.vy = 0
        self.onGround = true
        landedViaMap = true
      else
        self.onGround = false
      end

    elseif self.vy < 0 then
      -- jumping upward: bonk head and push just below solid
      if map:aabbOverlapsSolid(x, y, w, h) then
        local headTop        = y
        local bottomOfSolid  = (math.floor(headTop / ts) + 1) * ts
        self.y  = bottomOfSolid + self.ch
        self.vy = 0
      end

    else
      -- idle vertical: probe 1px below feet to maintain grounded flag
      local px, py = x, y + 1
      self.onGround = map:aabbOverlapsSolid(px, py, w, h)
    end
  end

  -- legacy flat-floor fallback (keeps left side playable when no solids)
  if (not landedViaMap) and self.y >= self.world.floor then
    self.y = self.world.floor
    self.vy = 0
    self.onGround = true
  end

  -- clamp horizontally using collider width
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
    love.graphics.setColor(1, 1, 0, 0.35)
    love.graphics.rectangle("fill", math.floor(x), math.floor(y), w, h)
    love.graphics.setColor(1, 1, 0, 1)
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
