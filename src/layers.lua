-- Minimal draw-layer manager
-- Usage each frame:
--   Layers.begin()
--   Layers.add("background", fn)
--   Layers.add("world", fn)
--   Layers.add("ui", fn)
--   Layers.draw({ camera = camera })

local Layers = {}
Layers.__index = Layers

local order = { "background", "world", "ui" }
local buckets = { background = {}, world = {}, ui = {} }

local function resetBuckets()
  buckets.background = {}
  buckets.world = {}
  buckets.ui = {}
end

function Layers.begin()
  resetBuckets()
end

function Layers.add(layer, fn)
  local b = buckets[layer]
  if not b then error("Unknown layer: " .. tostring(layer)) end
  b[#b + 1] = fn
end

-- ctx.camera is optional; if present we apply it for "world" layer
function Layers.draw(ctx)
  ctx = ctx or {}
  for _, layer in ipairs(order) do
    local list = buckets[layer]
    if #list > 0 then
      if layer == "world" and ctx.camera and ctx.camera.apply then
        ctx.camera:apply()
        for i = 1, #list do list[i]() end
        if ctx.camera.clear then ctx.camera:clear() end
      else
        for i = 1, #list do list[i]() end
      end
    end
  end
end

return Layers
