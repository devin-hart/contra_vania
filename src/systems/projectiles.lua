local cfg       = require("config")
local Projectile= require("src.projectile")

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
    local alive = bullets[i]:update(dt)
    
    -- Check terrain collision if map exists
    if alive and map then
      local bx, by, bw, bh = bullets[i]:getCollider()
      -- Check center and edges of bullet
      local hitTile = map:isSolidAt(bx + bw/2, by + bh/2) or
                      map:isSolidAt(bx, by) or
                      map:isSolidAt(bx + bw, by)
      
      if hitTile then
        alive = false
      end
    end
    
    if alive then
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