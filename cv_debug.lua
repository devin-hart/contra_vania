-- cv_debug.lua : simple in-game debug overlay
local M = {}

local visible = false
local logbuf  = {}
local maxlogs = 120
local t       = 0
local fps     = 0
local memkb   = 0

-- API
function M.toggle() visible = not visible end
function M.isVisible() return visible end

function M.dump()
  print(("---- DEBUG DUMP (%d lines) ----"):format(#logbuf))
  for i=1,#logbuf do print(logbuf[i]) end
end

function M.log(tag, msg)
  local line = ("[%s] %s"):format(tag, msg)
  logbuf[#logbuf+1] = line
  if #logbuf > maxlogs then table.remove(logbuf, 1) end
end

function M.update(dt)
  t = t + dt
  if t > 0.25 then
    t = 0
    fps   = love.timer.getFPS()
    memkb = collectgarbage("count")
  end
end

-- World-space debug: draw tilemap solids as outlines
function M.drawTilemap(map)
  if not visible or not map then return end
  local ts = map.ts
  love.graphics.setLineStyle("rough")
  love.graphics.setColor(1, 0.2, 0.2, 0.8) -- red outlines
  for y = 1, map.th do
    for x = 1, map.tw do
      if map.solids[y][x] == true then
        love.graphics.rectangle("line", (x-1)*ts, (y-1)*ts, ts, ts)
      end
    end
  end
  love.graphics.setColor(1,1,1,1)
end

-- World-space debug: draw colliders for player and enemies
function M.drawColliders(player, enemies)
  if not visible then return end

  -- player
  if player and player.getCollider then
    local x,y,w,h = player:getCollider()
    love.graphics.setColor(1, 1, 0, 0.35)
    love.graphics.rectangle("fill", math.floor(x), math.floor(y), w, h)
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.rectangle("line", math.floor(x), math.floor(y), w, h)
  end

  -- enemies
  if enemies then
    for i=1,#enemies do
      local e = enemies[i]
      if e.getCollider then
        local x,y,w,h = e:getCollider()
        love.graphics.setColor(1, 0, 1, 0.25)
        love.graphics.rectangle("fill", math.floor(x), math.floor(y), w, h)
        love.graphics.setColor(1, 0, 1, 1)
        love.graphics.rectangle("line", math.floor(x), math.floor(y), w, h)
      end
    end
  end

  love.graphics.setColor(1,1,1,1)
end

-- Screen-space overlay (after viewport)
function M.draw()
  if not visible then return end
  local sx, sy = 10, 10
  love.graphics.setColor(0,0,0,0.5)
  love.graphics.rectangle("fill", sx-6, sy-6, 230, 90)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(("FPS: %d"):format(fps), sx, sy)
  love.graphics.print(("Mem: %d KB"):format(memkb), sx, sy+16)
  love.graphics.print(("Logs: %d"):format(#logbuf), sx, sy+32)
  love.graphics.print("[F1] toggle overlay  [F2] dump logs", sx, sy+48)
end

return M
