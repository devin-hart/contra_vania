local cfg = require("config")
local Audio = require("src.audio")

local Boss = {}
Boss.__index = Boss

-- Base boss class with phase system
function Boss.new(opts)
  local self = setmetatable({}, Boss)
  
  -- Position (center-based like player)
  self.x = opts.x or 640
  self.y = opts.y or 100
  
  -- Visuals
  self.w = opts.w or 48
  self.h = opts.h or 48
  self.color = opts.color or {0.8, 0.2, 0.2, 1}
  
  -- Health and phases
  self.maxHp = opts.maxHp or 20
  self.hp = self.maxHp
  self.phases = opts.phases or {
    { threshold = 0.66, name = "phase1" },  -- Above 66% HP
    { threshold = 0.33, name = "phase2" },  -- Above 33% HP
    { threshold = 0.0,  name = "phase3" },  -- Below 33% HP
  }
  self.currentPhase = 1
  
  -- State machine
  self.state = "intro"  -- intro, idle, attacking, hurt, dead
  self.stateTimer = 0
  
  -- Attack pattern
  self.attackCooldown = 0
  self.attackInterval = opts.attackInterval or 2.0
  
  -- Movement
  self.vx = 0
  self.vy = 0
  self.moveSpeed = opts.moveSpeed or 40
  
  -- Damage feedback
  self.hitFlashTimer = 0
  self.invulnerable = false
  
  -- Intro sequence
  self.introStartX = self.x
  self.introTargetX = self.x
  self.introTargetY = self.y
  self.introDuration = opts.introDuration or 2.0
  
  -- Boss-specific data
  self.data = opts.data or {}
  
  -- Collider
  self.cw = opts.cw or self.w * 0.8
  self.ch = opts.ch or self.h * 0.8
  
  -- Active/visible
  self.active = false
  self.dead = false
  self.deathTimer = 0
  
  return self
end

function Boss:getCollider()
  local x = self.x - self.cw / 2
  local y = self.y - self.ch / 2
  return x, y, self.cw, self.ch
end

function Boss:activate(startX, targetX, targetY)
  self.active = true
  self.state = "intro"
  self.stateTimer = self.introDuration
  self.introStartX = startX or self.x + 200
  self.introTargetX = targetX or self.x
  self.introTargetY = targetY or self.y
  self.x = self.introStartX
  
  -- Start boss music
  Audio.playMusic("boss")
end

function Boss:takeDamage(amount)
  if self.invulnerable or self.dead or self.state == "intro" then
    return false
  end
  
  self.hp = math.max(0, self.hp - (amount or 1))
  self.hitFlashTimer = 0.15
  self.state = "hurt"
  self.stateTimer = 0.2
  
  Audio.playSFX("hit")
  
  -- Check for phase transition
  local hpPercent = self.hp / self.maxHp
  for i = self.currentPhase + 1, #self.phases do
    if hpPercent <= self.phases[i].threshold then
      self.currentPhase = i
      self:onPhaseChange(i)
      break
    end
  end
  
  -- Check for death
  if self.hp <= 0 then
    self.dead = true
    self.state = "dead"
    self.deathTimer = 2.0
    Audio.playSFX("explode")
    self:onDeath()
    return true
  end
  
  return false
end

-- Override these in specific boss implementations
function Boss:onPhaseChange(phase)
  -- Called when entering new phase
  -- Subclasses should override this
end

function Boss:onDeath()
  -- Called when boss dies
  -- Subclasses should override this
end

function Boss:onAttack()
  -- Called when boss attacks
  -- Subclasses should override this
  -- Return attack data or nil
  return nil
end

function Boss:update(dt, player, world)
  if not self.active then return end
  
  self.stateTimer = self.stateTimer - dt
  self.hitFlashTimer = math.max(0, self.hitFlashTimer - dt)
  
  if self.state == "intro" then
    -- Intro animation: slide in from right
    local progress = 1 - (self.stateTimer / self.introDuration)
    self.x = self.introStartX + (self.introTargetX - self.introStartX) * progress
    self.y = self.introTargetY
    
    if self.stateTimer <= 0 then
      self.state = "idle"
      self.stateTimer = 0
    end
    
  elseif self.state == "hurt" then
    -- Brief stun after taking damage
    if self.stateTimer <= 0 then
      self.state = "idle"
    end
    
  elseif self.state == "idle" then
    -- Wait for attack cooldown
    self.attackCooldown = self.attackCooldown - dt
    
    if self.attackCooldown <= 0 then
      self.state = "attacking"
      self.stateTimer = 0.5  -- Attack wind-up
      self.attackCooldown = self.attackInterval
    end
    
    -- Simple hover movement (fix: don't multiply by dt for position)
    local hover = math.sin(love.timer.getTime() * 2) * 10
    self.y = self.introTargetY + hover
    
  elseif self.state == "attacking" then
    if self.stateTimer <= 0 then
      -- Execute attack
      self:onAttack()
      self.state = "idle"
    end
    
  elseif self.state == "dead" then
    self.deathTimer = self.deathTimer - dt
    -- Fade out / death animation
  end
end

function Boss:draw()
  if not self.active then return end
  
  -- Draw boss body
  local flash = self.hitFlashTimer > 0
  local alpha = 1.0
  
  if self.state == "dead" then
    alpha = math.max(0, self.deathTimer / 2.0)
    -- Flicker during death
    if math.floor(love.timer.getTime() * 20) % 2 == 0 then
      alpha = alpha * 0.5
    end
  end
  
  if flash then
    love.graphics.setColor(1, 1, 1, alpha)
  else
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
  end
  
  -- Simple placeholder visual
  local drawX = self.x - self.w / 2
  local drawY = self.y - self.h / 2
  love.graphics.rectangle("fill", drawX, drawY, self.w, self.h)
  
  -- Draw eye or detail
  love.graphics.setColor(1, 1, 1, alpha)
  love.graphics.circle("fill", self.x - 8, self.y - 4, 4)
  love.graphics.circle("fill", self.x + 8, self.y - 4, 4)
  
  love.graphics.setColor(1, 1, 1, 1)
  
  -- Debug: collider
  local dbg = require("cv_debug")
  if dbg.isVisible() then
    local cx, cy, cw, ch = self:getCollider()
    love.graphics.setColor(1, 0, 0, 0.3)
    love.graphics.rectangle("fill", cx, cy, cw, ch)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("line", cx, cy, cw, ch)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

function Boss:isActive()
  return self.active
end

function Boss:isDead()
  return self.dead and self.deathTimer <= 0
end

function Boss:getHealthPercent()
  return self.hp / self.maxHp
end

return Boss