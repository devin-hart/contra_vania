local cfg       = require("config")
local Projectile= require("src.projectile")
local Collision = require("src.collision")

local P = {}
local bullets = {}

function P.init()
    bullets = {}
    P.list = bullets
end

function P.spawn(mx, my, dir)
  bullets[#bullets+1] = Projectile.new{ x = mx, y = my, dir = dir }
end

function P.update(dt, map)
  if #bullets == 0 then return end
  local i = 1
  while i <= #bullets do
    local b = bullets[i]
    local alive = b:update(dt)

    local hitTerrain = false
    if map then
      local x, y, w, h = b:getCollider()
      if map:aabbOverlapsSolid(x, y, w, h) then
        hitTerrain = true
      end
    end

    if hitTerrain or not alive then
      table.remove(bullets, i)   -- do not increment i; next item shifts into i
    else
      i = i + 1
    end
  end
end

function P.draw()
  for i = 1, #bullets do
    bullets[i]:draw()
  end
end

return P
