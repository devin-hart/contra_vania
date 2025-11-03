local cfg = require("config")

local Menu = {}

-- Menu state
local currentMenu = "main"  -- "main", "options", "controls"
local selectedIndex = 1
local menuItems = {}

-- Settings (will be saved/loaded later)
local settings = {
  musicVolume = 0.7,
  sfxVolume = 0.8,
  debugMode = false,
}

-- Define menu structures
local menus = {
  main = {
    title = "PAUSED",
    items = {
      { label = "Resume", action = "resume" },
      { label = "Options", action = "options" },
      { label = "Quit to Title", action = "title" },
      { label = "Quit Game", action = "quit" },
    }
  },
  options = {
    title = "OPTIONS",
    items = {
      { label = "Music Volume", action = "music_volume", type = "slider", value = function() return settings.musicVolume end },
      { label = "SFX Volume", action = "sfx_volume", type = "slider", value = function() return settings.sfxVolume end },
      { label = "Debug Mode", action = "debug_toggle", type = "toggle", value = function() return settings.debugMode end },
      { label = "Back", action = "back" },
    }
  },
}

function Menu.init()
  currentMenu = "main"
  selectedIndex = 1
  menuItems = menus[currentMenu].items
end

function Menu.navigate(direction)
  if direction == "up" then
    selectedIndex = selectedIndex - 1
    if selectedIndex < 1 then selectedIndex = #menuItems end
  elseif direction == "down" then
    selectedIndex = selectedIndex + 1
    if selectedIndex > #menuItems then selectedIndex = 1 end
  end
end

function Menu.adjustValue(direction)
  local item = menuItems[selectedIndex]
  if not item or item.type ~= "slider" then return end
  
  local step = 0.1
  if item.action == "music_volume" then
    settings.musicVolume = math.max(0, math.min(1, settings.musicVolume + direction * step))
  elseif item.action == "sfx_volume" then
    settings.sfxVolume = math.max(0, math.min(1, settings.sfxVolume + direction * step))
  end
end

function Menu.select()
  local item = menuItems[selectedIndex]
  if not item then return nil end
  
  if item.action == "resume" then
    return "resume"
  elseif item.action == "options" then
    currentMenu = "options"
    selectedIndex = 1
    menuItems = menus[currentMenu].items
    return nil
  elseif item.action == "back" then
    currentMenu = "main"
    selectedIndex = 1
    menuItems = menus[currentMenu].items
    return nil
  elseif item.action == "title" then
    -- Reset menu state before returning
    currentMenu = "main"
    selectedIndex = 1
    menuItems = menus[currentMenu].items
    return "title"
  elseif item.action == "quit" then
    return "quit"
  elseif item.action == "debug_toggle" then
    settings.debugMode = not settings.debugMode
    return nil
  end
  
  return nil
end

function Menu.draw()
  local W, H = cfg.RES_W, cfg.RES_H
  
  -- Dark overlay
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", 0, 0, W, H)
  
  -- Menu box
  local boxW, boxH = 200, 140
  local boxX, boxY = (W - boxW) / 2, (H - boxH) / 2 - 20
  
  love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
  love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
  love.graphics.setColor(cfg.COLORS.accent)
  love.graphics.rectangle("line", boxX, boxY, boxW, boxH)
  
  -- Title
  local menuData = menus[currentMenu]
  love.graphics.setColor(cfg.COLORS.white)
  local titleW = love.graphics.getFont():getWidth(menuData.title)
  love.graphics.print(menuData.title, (W - titleW) / 2, boxY + 10)
  
  -- Menu items
  local itemY = boxY + 35
  local itemH = 20
  
  for i, item in ipairs(menuItems) do
    local x = boxX + 15
    local y = itemY + (i - 1) * itemH
    
    -- Selection indicator
    if i == selectedIndex then
      love.graphics.setColor(cfg.COLORS.accent)
      love.graphics.print(">", x - 10, y)
    end
    
    -- Item label
    love.graphics.setColor(i == selectedIndex and cfg.COLORS.white or cfg.COLORS.hud_label)
    love.graphics.print(item.label, x, y)
    
    -- Draw value for sliders/toggles
    if item.type == "slider" then
      local value = item.value()
      local barX = x + 120
      local barW = 50
      local barH = 6
      
      -- Background
      love.graphics.setColor(0.2, 0.2, 0.2, 1)
      love.graphics.rectangle("fill", barX, y + 5, barW, barH)
      
      -- Fill
      love.graphics.setColor(cfg.COLORS.accent)
      love.graphics.rectangle("fill", barX, y + 5, barW * value, barH)
      
      -- Border
      love.graphics.setColor(cfg.COLORS.white)
      love.graphics.rectangle("line", barX, y + 5, barW, barH)
      
    elseif item.type == "toggle" then
      local value = item.value()
      local toggleX = x + 130
      love.graphics.setColor(value and cfg.COLORS.accent or cfg.COLORS.hud_label)
      love.graphics.print(value and "ON" or "OFF", toggleX, y)
    end
  end
  
  -- Controls hint
  love.graphics.setColor(cfg.COLORS.hud_label)
  local hint = currentMenu == "options" and 
               "↑↓ Navigate  ←→ Adjust  Enter Select" or
               "↑↓ Navigate  Enter Select"
  local hintW = love.graphics.getFont():getWidth(hint)
  love.graphics.print(hint, (W - hintW) / 2, boxY + boxH + 10)
  
  love.graphics.setColor(1, 1, 1, 1)
end

function Menu.getSettings()
  return settings
end

function Menu.setSettings(newSettings)
  settings = newSettings
end

return Menu