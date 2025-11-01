local cfg       = require("config")
local Projectile= require("src.projectile")
local Collision = require("src.collision")

local P = {}
local bullets = {}

function P.init()
  bullets = {}
end

function P.spawn(mx, my, dir)
  bullets[#bullets+1] = Projectile.new{ x = mx, y = my, dir = dir }
end

function P.update(dt)
  if #bullets == 0 then return end
  local i = 1
  while i <= #bullets do
    if bullets[i]:update(dt) then
      i = i + 1
    else
      table.remove(bullets, i)
    end
  end
end

function P.draw()
  for i = 1, #bullets do
    bullets[i]:draw()
  end
end

-- Returns true if any enemy was hit; deletes that bullet immediately.
function P.hitEnemies(enemies)
  if #bullets == 0 or #enemies == 0 then return false end
  local anyHit = false
  local b = 1
  while b <= #bullets do
    local bx, by, bw, bh = bullets[b]:getCollider()
    local hit = false
    for e = 1, #enemies do
      local ex, ey, ew, eh = enemies[e]:getCollider()
      if Collision.rectsOverlap(bx, by, bw, bh, ex, ey, ew, eh) then
        enemies[e].hitTimer = 0.12
        enemies[e].dead = true
        hit = true
        anyHit = true
        break
      end
    end
    if hit then
      table.remove(bullets, b)
    else
      b = b + 1
    end
  end
  return anyHit
end

return P
