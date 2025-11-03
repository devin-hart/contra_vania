local Item = require("src.item")
local Audio = require("src.audio")

local Items = {}
Items.list = {}
Items.count = 0

function Items.init()
  for i=#Items.list,1,-1 do Items.list[i]=nil end
  Items.count = 0
end

function Items.spawn(x, y, kind)
  Items.list[#Items.list+1] = Item.new{ x=x, y=y, kind=kind }
end

function Items.update(dt)
  for i=1,#Items.list do
    Items.list[i]:update(dt)
  end
end

function Items.draw()
  for i=1,#Items.list do
    Items.list[i]:draw()
  end
end

function Items.collect(index, player)
  local it = Items.list[index]
  if not it then return end
  it.collected = true
  Items.count = Items.count + 1
  Audio.playSFX("collect")
  -- Simple effect hook / player gains could go here (HP, score, etc.)
  table.remove(Items.list, index)
end

return Items