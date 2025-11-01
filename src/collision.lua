local Collision = {}

-- AABB vs AABB check
function Collision.rectsOverlap(ax, ay, aw, ah, bx, by, bw, bh)
  return ax < bx + bw and
         bx < ax + aw and
         ay < by + bh and
         by < ay + ah
end

return Collision
