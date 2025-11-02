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

return P
