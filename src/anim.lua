-- Tiny animation helper with optional procedural fallback frames.
local Anim = {}
Anim.__index = Anim

-- opts:
--   image        = love Image (optional; if nil, uses procedural)
--   frameW/H     = frame dimensions
--   frames       = number of frames
--   fps          = playback speed
--   loop         = boolean
--   colors       = { {r,g,b,a}, ... } used if no image provided
function Anim.new(opts)
  local self = setmetatable({}, Anim)
  self.image  = opts.image
  self.fw     = assert(opts.frameW, "frameW required")
  self.fh     = assert(opts.frameH, "frameH required")
  self.frames = assert(opts.frames, "frames required")
  self.fps    = opts.fps or 8
  self.loop   = (opts.loop ~= false)
  self.time   = 0
  self.index  = 1

  if self.image then
    -- build quads from a horizontal strip; extend if you need grids later
    self.quads = {}
    for i = 1, self.frames do
      self.quads[i] = love.graphics.newQuad(
        (i - 1) * self.fw, 0, self.fw, self.fh,
        self.image:getWidth(), self.image:getHeight()
      )
    end
  else
    -- procedural colors per frame (fallback)
    self.colors = opts.colors or {
      {0.20, 0.90, 0.30, 1.0},
      {0.18, 0.82, 0.28, 1.0},
      {0.22, 0.96, 0.34, 1.0},
    }
  end
  return self
end

function Anim:reset()
  self.time = 0
  self.index = 1
end

function Anim:update(dt)
  self.time = self.time + dt
  local step = 1 / self.fps
  if self.time >= step then
    self.time = self.time - step
    -- advance at most ONE frame per update to avoid visible skipping
    self.index = self.index + 1
    if self.index > self.frames then
      if self.loop then
        self.index = 1
      else
        self.index = self.frames
      end
    end
  end
end


function Anim:draw(x, y, flip)
  if self.image then
    local q = self.quads[self.index]
    if flip then
      -- draw flipped horizontally
      love.graphics.draw(self.image, q, math.floor(x) + self.fw, math.floor(y), 0, -1, 1)
    else
      love.graphics.draw(self.image, q, math.floor(x), math.floor(y))
    end
  else
    -- procedural: draw a simple body + accent that changes per frame
    local c = self.colors[((self.index - 1) % #self.colors) + 1]
    love.graphics.setColor(c)
    love.graphics.rectangle("fill", math.floor(x), math.floor(y), self.fw, self.fh)

    -- accent stripe to suggest motion; flip mirrors it
    love.graphics.setColor(0, 0, 0, 0.25)
    local stripeX = flip and (x + 2) or (x + self.fw - 4)
    love.graphics.rectangle("fill", math.floor(stripeX), math.floor(y + 2), 2, self.fh - 4)

    love.graphics.setColor(1, 1, 1, 1)
  end
end

return Anim
