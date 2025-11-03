local Boss = require("src.boss")
local Projectiles = require("src.systems.projectiles")

local FlyingEye = {}

function FlyingEye.new(x, y)
  local boss = Boss.new{
    x = x,
    y = y,
    w = 56,
    h = 56,
    maxHp = 30,
    attackInterval = 1.5,
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
  
  -- Add custom behavior
  boss.originalOnPhaseChange = boss.onPhaseChange
  boss.originalOnAttack = boss.onAttack
  
  -- Phase changes = faster attacks
  function boss:onPhaseChange(phase)
    if phase == 2 then
      self.attackInterval = 1.0  -- Faster
    elseif phase == 3 then
      self.attackInterval = 0.7  -- Even faster!
    end
  end
  
  -- Attack pattern: shoot projectiles at player
  function boss:onAttack()
    -- Shoot 3 projectiles in spread pattern
    local angles = {-0.3, 0, 0.3}  -- Spread
    
    for _, angle in ipairs(angles) do
      -- Calculate direction to player (would need player ref)
      local dir = self.x < 160 and 1 or -1  -- Simple: shoot toward center
      
      -- Spawn projectile (reuse projectile system)
      local speed = 120
      local vx = math.cos(angle) * speed * dir
      local vy = math.sin(angle) * speed + 60  -- Downward bias
      
      -- Note: This is simplified - real implementation would 
      -- spawn boss-specific projectiles
      Projectiles.spawn(self.x, self.y + 10, dir)
    end
    
    return true
  end
  
  return boss
end

return FlyingEye