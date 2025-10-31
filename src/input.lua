-- Simple input system with actions, pressed/held/released states
local Input = {}

local bindings = {
  left   = { "left",  "a" },
  right  = { "right", "d" },
  jump   = { "space", "w", "up" },
  debug  = { "f1" },
  dump   = { "f2" },
  quit   = { "escape" },
}

local down = {}       -- key -> boolean (held)
local pressed = {}    -- key -> boolean (edge this frame)
local released = {}   -- key -> boolean (edge this frame)

-- Helpers
local function anyBound(action, predicate)
  local keys = bindings[action]
  if not keys then return false end
  for i = 1, #keys do
    if predicate(keys[i]) then return true end
  end
  return false
end

-- Public API
function Input.bind(action, keys)
  -- keys: string or { ... }
  if type(keys) == "string" then keys = { keys } end
  bindings[action] = keys
end

function Input.setBindings(map)  -- replace all bindings at once
  bindings = {}
  for action, keys in pairs(map or {}) do
    Input.bind(action, keys)
  end
end

function Input.keypressed(key)
  down[key] = true
  pressed[key] = true
end

function Input.keyreleased(key)
  down[key] = false
  released[key] = true
end

-- Call once per frame in love.update(dt)
function Input.update(dt)
  -- clear pressed/released edges at end of frame
  pressed = {}
  released = {}
end

-- Queries (by action or raw key)
function Input.isDown(actionOrKey)
  if bindings[actionOrKey] then
    return anyBound(actionOrKey, function(k) return down[k] end)
  else
    return down[actionOrKey] or false
  end
end

function Input.wasPressed(actionOrKey)
  if bindings[actionOrKey] then
    return anyBound(actionOrKey, function(k) return pressed[k] end)
  else
    return pressed[actionOrKey] or false
  end
end

function Input.wasReleased(actionOrKey)
  if bindings[actionOrKey] then
    return anyBound(actionOrKey, function(k) return released[k] end)
  else
    return released[actionOrKey] or false
  end
end

function Input.getBindings()
  return bindings
end

return Input
