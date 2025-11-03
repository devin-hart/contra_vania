local Boss = require("src.boss")
local Audio = require("src.audio")
local BossProjectiles = require("src.systems.bossprojectiles")

local FlyingEye = {}

function FlyingEye.new(x, y)
  local boss = Boss.new{
    x = x,
    y = y,
    w = 56,
    h = 56,
    maxHp = 30,
    attackInterval = 1.8,
    introDuration = 2.5,
    moveSpeed = 50,
    color = {0.7, 0.1, 0.3, 1},
    cw = 44,
    ch = 44,
    phases = {
      { threshold = 0.66, name = "slow" },
      { threshold = 0.33, name = "medium" },
      { threshold = 0.0,  name = "fast" },
    }
  }
  
  -- Store original position for hover pattern
  boss.originY = y
  boss.hoverSpeed = 2.0
  boss.hoverRange = 15
  
  -- Movement pattern
  boss.moveTimer = 0
  boss.moveDuration = 3.0
  boss.moveTargetX = x
  
  -- Attack pattern tracking
  boss.attackCount = 0
  
  -- Add custom behavior
  boss.originalOnPhaseChange = boss.onPhaseChange
  boss.originalOnAttack = boss.onAttack
  boss.originalUpdate = boss.update
  
  -- Phase changes = faster attacks and movement
  function boss:onPhaseChange(phase)
    if phase == 2 then
      self.attackInterval = 1.2  -- Faster
      self.hoverSpeed = 2.5
    elseif phase == 3 then
      self.attackInterval = 0.8  -- Even faster!
      self.hoverSpeed = 3.0
      self.moveSpeed = 70
    end
  end
  
  -- Attack pattern: varies by phase
  function boss:onAttack()
    if not self.active or self.dead then return end
    
    Audio.playSFX("shoot")
    self.attackCount = self.attackCount + 1
    
    -- Get player position for targeting
    local player = self.playerRef
    if not player then return end
    
    local targetX = player.x
    local targetY = player.y
    
    -- Phase 1: Simple single shots and 3-way spreads
    if self.currentPhase == 1 then
      if self.attackCount % 3 == 0 then
        -- Every 3rd attack: spread shot
        BossProjectiles.spawnPattern("spread3", self.x, self.y + 10, targetX, targetY, {
          speed = 100,
          spreadAngle = 0.4
        })
      else
        -- Normal single shot
        BossProjectiles.spawnPattern("single", self.x, self.y + 10, targetX, targetY, {
          speed = 120
        })
      end
      
    -- Phase 2: 5-way spreads and occasional homing
    elseif self.currentPhase == 2 then
      if self.attackCount % 4 == 0 then
        -- Every 4th attack: homing missile
        BossProjectiles.spawnPattern("homing", self.x, self.y + 10, targetX, targetY, {
          speed = 70,
          homingStrength = 2.5
        })
      else
        -- 5-way spread
        BossProjectiles.spawnPattern("spread5", self.x, self.y + 10, targetX, targetY, {
          speed = 110,
          spreadAngle = 0.3
        })
      end
      
    -- Phase 3: Bullet hell - circle patterns + homing
    elseif self.currentPhase == 3 then
      if self.attackCount % 5 == 0 then
        -- Every 5th attack: circle burst
        BossProjectiles.spawnPattern("circle8", self.x, self.y, targetX, targetY, {
          speed = 90
        })
      elseif self.attackCount % 3 == 0 then
        -- Every 3rd: homing missile
        BossProjectiles.spawnPattern("homing", self.x, self.y + 10, targetX, targetY, {
          speed = 80,
          homingStrength = 3.5
        })
      else
        -- Fast spread
        BossProjectiles.spawnPattern("spread5", self.x, self.y + 10, targetX, targetY, {
          speed = 130,
          spreadAngle = 0.35
        })
      end
    end
    
    return true
  end
  
  -- Enhanced update with movement pattern
  function boss:update(dt, player, world)
    -- Store player reference for attacks
    self.playerRef = player
    
    -- Call base update
    self.originalUpdate(self, dt, player, world)
    
    if not self.active or self.state == "intro" or self.state == "dead" then
      return
    end
    
    -- Hovering motion (vertical)
    local baseHover = math.sin(love.timer.getTime() * self.hoverSpeed) * self.hoverRange
    self.y = self.originY + baseHover
    
    -- Horizontal movement pattern (phase 2+)
    if self.currentPhase >= 2 and self.state == "idle" then
      self.moveTimer = self.moveTimer + dt
      
      if self.moveTimer >= self.moveDuration then
        -- Pick new target position
        self.moveTimer = 0
        local arenaLeft = 1500
        local arenaRight = 1850
        self.moveTargetX = arenaLeft + math.random() * (arenaRight - arenaLeft)
      end
      
      -- Move toward target
      local dx = self.moveTargetX - self.x
      if math.abs(dx) > 5 then
        local moveDir = dx > 0 and 1 or -1
        self.x = self.x + moveDir * self.moveSpeed * dt
      end
    end
    
    -- Aggressive movement during phase 3
    if self.currentPhase >= 3 and self.state == "idle" and player then
      -- Occasional quick dash toward player
      if math.random() < 0.01 then  -- 1% chance per frame
        local toPlayerX = player.x - self.x
        if math.abs(toPlayerX) < 300 then  -- Only if somewhat close
          self.moveTargetX = player.x + (toPlayerX > 0 and -80 or 80)
        end
      end
    end
  end
  
  return boss
end

return FlyingEye