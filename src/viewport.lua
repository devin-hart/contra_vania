local cfg = require("config")

local Viewport = {}
Viewport.__index = Viewport

function Viewport.new(w, h, scaleStart)
  local self = setmetatable({}, Viewport)
  self.W = w
  self.H = h
  self.scale = scaleStart or 3
  self.canvas = love.graphics.newCanvas(w, h)
  self:updateScale()  -- FIX: use the instance, not the class
  return self
end

function Viewport:updateScale()
  local gw, gh = love.graphics.getWidth(), love.graphics.getHeight()
  local sx = math.floor(gw / self.W)
  local sy = math.floor(gh / self.H)
  self.scale = math.max(1, math.min(sx, sy))
end

function Viewport:begin()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear(cfg.COLORS.bg)
end

function Viewport:finish()
  love.graphics.setCanvas()
  local gw, gh = love.graphics.getWidth(), love.graphics.getHeight()
  self:updateScale()
  local dx = math.floor((gw - self.W * self.scale) / 2)
  local dy = math.floor((gh - self.H * self.scale) / 2)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canvas, dx, dy, 0, self.scale, self.scale)
end

return Viewport
