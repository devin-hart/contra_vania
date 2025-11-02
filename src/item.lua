local cfg = require("config")

local Item = {}
Item.__index = Item

-- opts: { x, y, kind }
function Item.new(opts)
  local self = setmetatable({}, Item)
  self.x = assert(opts.x, "Item.new: x required")
  self.y = assert(opts.y, "Item.new: y required")
  self.kind = opts.kind or "gem"

  self.w = cfg.ITEM.w
  self.h = cfg.ITEM.h
  self.t = 0     -- bob timer
  self.collected = false
  return self
end

function Item:update(dt)
  self.t = self.t + dt
end

function Item:getCollider()
  -- center collider around (x,y), bob visually only in draw()
  return self.x - self.w * 0.5, self.y - self.h * 0.5, self.w, self.h
end

function Item:draw()
  local dy = math.sin(self.t * cfg.ITEM.bobSpeed) * cfg.ITEM.bob
  local x, y, w, h = self:getCollider()
  y = y + dy
  love.graphics.setColor(0.95, 0.8, 0.2, 1) -- gold-ish
  love.graphics.rectangle("fill", math.floor(x), math.floor(y), w, h)
  love.graphics.setColor(1, 1, 1, 1)
end

return Item
