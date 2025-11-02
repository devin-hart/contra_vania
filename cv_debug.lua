local M = {}

local MAX = 200
local logs = {}
local visible = false
local last_dt = 0

local function push(line)
  logs[#logs + 1] = line
  if #logs > MAX then table.remove(logs, 1) end
end

function M.log(tag, msg)
  local t = string.format("[%.3f]", love.timer.getTime())
  push(string.format("%s %-8s %s", t, tag or "", tostring(msg)))
end

function M.toggle()
  visible = not visible
  M.log("debug", "overlay " .. (visible and "on" or "off"))
end

function M.dump(path)
  path = path or "debug_log.txt"
  local ok, err = pcall(function()
    local f = assert(love.filesystem.newFile(path, "w"))
    for i = 1, #logs do f:write(logs[i] .. "\n") end
    f:close()
  end)
  if ok then
    M.log("dump", "wrote " .. path)
  else
    M.log("dump", "error: " .. tostring(err))
  end
end

function M.isVisible()
  return visible
end

function M.update(dt)
  last_dt = dt
end

function M.draw()
  if not visible then return end
  local fps = love.timer.getFPS()
  local mem = collectgarbage("count") / 1024.0
  local info = string.format("FPS:%3d   dt:%.3f   mem:%.2f MB", fps, last_dt, mem)

  love.graphics.setColor(0, 0, 0, 0.65)
  love.graphics.rectangle("fill", 8, 8, 304, 100)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle("line", 8, 8, 304, 100)
  love.graphics.print(info, 14, 12)

  local n = #logs
  local row = 0
  for i = math.max(1, n - 4), n do
    love.graphics.print(logs[i], 14, 28 + row * 16)
    row = row + 1
  end
end

-- Draw tilemap solid tiles overlay (call in world layer)
function M.drawTilemap(map)
  if not visible or not map then return end
  
  local ts = map.ts
  love.graphics.setColor(1, 0, 0, 0.25)
  
  -- Only draw visible tiles
  for y = 1, map.th do
    for x = 1, map.tw do
      if map:isSolidTile(x, y) then
        love.graphics.rectangle("fill", (x-1)*ts, (y-1)*ts, ts, ts)
      end
    end
  end
  
  love.graphics.setColor(1, 1, 1, 1)
end

-- Draw all entity colliders (call in world layer after entities)
function M.drawColliders(player, enemies)
  if not visible then return end
  
  -- Player collider (yellow)
  if player and player.getCollider then
    local x, y, w, h = player:getCollider()
    love.graphics.setColor(1, 1, 0, 0.35)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.rectangle("line", x, y, w, h)
  end
  
  -- Enemy colliders (orange)
  if enemies then
    for i = 1, #enemies do
      if enemies[i].getCollider then
        local x, y, w, h = enemies[i]:getCollider()
        love.graphics.setColor(1, 0.5, 0, 0.35)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(1, 0.5, 0, 1)
        love.graphics.rectangle("line", x, y, w, h)
      end
    end
  end
  
  love.graphics.setColor(1, 1, 1, 1)
end

return M