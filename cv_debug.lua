local M = {}

local MAX = 200                   -- ring buffer size
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
  local mem = collectgarbage("count") / 1024.0 -- MB
  local info = string.format("FPS:%3d   dt:%.3f   mem:%.2f MB", fps, last_dt, mem)

  -- panel
  love.graphics.setColor(0, 0, 0, 0.65)
  love.graphics.rectangle("fill", 8, 8, 304, 100)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle("line", 8, 8, 304, 100)
  love.graphics.print(info, 14, 12)

  -- show last 5 log lines
  local n = #logs
  local row = 0
  for i = math.max(1, n - 4), n do
    love.graphics.print(logs[i], 14, 28 + row * 16)
    row = row + 1
  end
end

return M
