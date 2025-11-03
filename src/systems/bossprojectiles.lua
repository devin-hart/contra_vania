local BossProjectile = require("src.bossprojectile")

local BossProjectiles = {}
local projectiles = {}

function BossProjectiles.init()
  projectiles = {}
  BossProjectiles.list = projectiles
end

-- Spawn a single projectile
function BossProjectiles.spawn(x, y, vx, vy, opts)
  opts = opts or {}
  opts.x = x
  opts.y = y
  opts.vx = vx
  opts.vy = vy
  
  projectiles[#projectiles + 1] = BossProjectile.new(opts)
end

-- Spawn multiple projectiles in a pattern
function BossProjectiles.spawnPattern(pattern, x, y, targetX, targetY, opts)
  opts = opts or {}
  
  if pattern == "single" then
    -- Single projectile toward target
    local dx = targetX - x
    local dy = targetY - y
    local dist = math.sqrt(dx * dx + dy * dy)
    local speed = opts.speed or 120
    
    if dist > 0 then
      BossProjectiles.spawn(x, y, (dx/dist) * speed, (dy/dist) * speed, opts)
    end
    
  elseif pattern == "spread3" then
    -- 3-way spread
    local dx = targetX - x
    local dy = targetY - y
    local baseAngle = math.atan2(dy, dx)
    local speed = opts.speed or 120
    local spreadAngle = opts.spreadAngle or 0.3
    
    for i = -1, 1 do
      local angle = baseAngle + (i * spreadAngle)
      local vx = math.cos(angle) * speed
      local vy = math.sin(angle) * speed
      BossProjectiles.spawn(x, y, vx, vy, opts)
    end
    
  elseif pattern == "spread5" then
    -- 5-way spread
    local dx = targetX - x
    local dy = targetY - y
    local baseAngle = math.atan2(dy, dx)
    local speed = opts.speed or 120
    local spreadAngle = opts.spreadAngle or 0.25
    
    for i = -2, 2 do
      local angle = baseAngle + (i * spreadAngle)
      local vx = math.cos(angle) * speed
      local vy = math.sin(angle) * speed
      BossProjectiles.spawn(x, y, vx, vy, opts)
    end
    
  elseif pattern == "circle8" then
    -- 8 projectiles in a circle
    local speed = opts.speed or 100
    
    for i = 0, 7 do
      local angle = (i / 8) * math.pi * 2
      local vx = math.cos(angle) * speed
      local vy = math.sin(angle) * speed
      BossProjectiles.spawn(x, y, vx, vy, opts)
    end
    
  elseif pattern == "homing" then
    -- Single homing projectile
    local dx = targetX - x
    local dy = targetY - y
    local dist = math.sqrt(dx * dx + dy * dy)
    local speed = opts.speed or 80
    
    if dist > 0 then
      local homingOpts = {
        type = "homing",
        speed = speed,
        homingStrength = opts.homingStrength or 3.0,
        color = {0.9, 0.5, 0.2, 1}
      }
      for k, v in pairs(opts) do
        if k ~= "speed" and k ~= "homingStrength" then
          homingOpts[k] = v
        end
      end
      BossProjectiles.spawn(x, y, (dx/dist) * speed, (dy/dist) * speed, homingOpts)
    end
  end
end

function BossProjectiles.update(dt, player, map)
  if #projectiles == 0 then return end
  
  local i = 1
  while i <= #projectiles do
    local alive = projectiles[i]:update(dt, player)
    
    -- Check terrain collision if map exists
    if alive and map then
      local px, py, pw, ph = projectiles[i]:getCollider()
      local hitTile = map:isSolidAt(px + pw/2, py + ph/2)
      if hitTile then
        alive = false
      end
    end
    
    -- Check if projectile went off screen
    if alive then
      local px = projectiles[i].x
      local py = projectiles[i].y
      if px < -50 or px > 2000 or py < -50 or py > 250 then
        alive = false
      end
    end
    
    if alive then
      i = i + 1
    else
      table.remove(projectiles, i)
    end
  end
end

function BossProjectiles.draw()
  for i = 1, #projectiles do
    projectiles[i]:draw()
  end
end

function BossProjectiles.clear()
  projectiles = {}
  BossProjectiles.list = projectiles
end

return BossProjectiles