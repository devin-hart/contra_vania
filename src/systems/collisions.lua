local Collision = require("src.collision")
local cfg = require("config")

local Collisions = {}

-- Handles all collision checks each frame.
function Collisions.update(dt, world, player, enemies, projectiles, items, bossProjectiles, boss)
  if #enemies == 0 and not player then return end

  -- PLAYER PROJECTILES → ENEMY
  if projectiles and projectiles.list and #projectiles.list > 0 and #enemies > 0 then
    local b = 1
    while b <= #projectiles.list do
      local bullet = projectiles.list[b]
      local bx, by, bw, bh = bullet:getCollider()
      local hit = false

      for e = 1, #enemies do
        local enemy = enemies[e]
        if not enemy.dead then
          local ex, ey, ew, eh = enemy:getCollider()
          if Collision.rectsOverlap(bx, by, bw, bh, ex, ey, ew, eh) then
            if enemy.takeDamage then
              enemy:takeDamage(cfg.PROJ.dmg or 1)
            end
            hit = true
            break
          end
        end
      end

      if hit then
        table.remove(projectiles.list, b)
      else
        b = b + 1
      end
    end
  end

  -- PLAYER ↔ ITEMS
  if player and player.getCollider and items and items.list and #items.list > 0 then
    local px, py, pw, ph = player:getCollider()
    local i = 1
    while i <= #items.list do
      local ix, iy, iw, ih = items.list[i]:getCollider()
      if Collision.rectsOverlap(px, py, pw, ph, ix, iy, iw, ih) then
        if items.collect then items.collect(i, player) end
      else
        i = i + 1
      end
    end
  end

  -- PLAYER ↔ ENEMY (contact damage)
  if player and player.getCollider and #enemies > 0 then
    local px, py, pw, ph = player:getCollider()
    
    for e = 1, #enemies do
      local enemy = enemies[e]
      if not enemy.dead then
        local ex, ey, ew, eh = enemy:getCollider()
        if Collision.rectsOverlap(px, py, pw, ph, ex, ey, ew, eh) then
          if player.takeDamage then
            -- Pass enemy X position for knockback direction
            player:takeDamage(1, enemy.x)
          end
        end
      end
    end
  end
  
  -- BOSS PROJECTILES → PLAYER
  if player and player.getCollider and bossProjectiles and bossProjectiles.list and #bossProjectiles.list > 0 then
    local px, py, pw, ph = player:getCollider()
    
    local b = 1
    while b <= #bossProjectiles.list do
      local proj = bossProjectiles.list[b]
      local bx, by, bw, bh = proj:getCollider()
      
      if Collision.rectsOverlap(px, py, pw, ph, bx, by, bw, bh) then
        -- Player takes damage
        if player.takeDamage then
          player:takeDamage(proj.damage or 1, proj.x)
        end
        table.remove(bossProjectiles.list, b)
      else
        b = b + 1
      end
    end
  end
  
  -- PLAYER ↔ BOSS (contact damage)
  if player and player.getCollider and boss and boss:isActive() and not boss.dead then
    local px, py, pw, ph = player:getCollider()
    local bx, by, bw, bh = boss:getCollider()
    
    if Collision.rectsOverlap(px, py, pw, ph, bx, by, bw, bh) then
      if player.takeDamage then
        player:takeDamage(1, boss.x)
      end
    end
  end
end

return Collisions