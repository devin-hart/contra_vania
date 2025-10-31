-- Minimal asset loader with caching and safe fallbacks.
local Assets = {}
Assets.__index = Assets

local cache = {}

local function tryLoadImage(path)
  local ok, img = pcall(function()
    local image = love.graphics.newImage(path)
    image:setFilter("nearest", "nearest", 1)
    return image
  end)
  if ok then return img end
  return nil
end

-- Load an image if it exists; store under a key (returns image or nil)
function Assets.loadOptional(key, path)
  if not path or path == "" then
    cache[key] = nil
    return nil
  end
  local img = tryLoadImage(path)
  cache[key] = img or false  -- false = attempted but missing
  return img
end

-- Get a previously loaded image (or nil)
function Assets.get(key)
  local v = cache[key]
  if v == false then return nil end
  return v
end

-- Convenience for bulk loads: Assets.loadAll({ key=path, ... })
function Assets.loadAll(map)
  for k, p in pairs(map or {}) do
    Assets.loadOptional(k, p)
  end
end

return Assets
