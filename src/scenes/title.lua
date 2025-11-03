local cfg = require("config")
local Input = require("src.input")
local Audio = require("src.audio")
local Save = require("src.save")
local Viewport = require("src.viewport")

local TitleScene = {}

local selectedOption = 1
local menuOptions = {}
local logoY = 0
local logoTargetY = 40
local menuY = 0
local menuTargetY = 110
local animTimer = 0
local pulseTimer = 0
local viewport = nil

function TitleScene:enter()
  -- Create viewport for proper scaling
  viewport = Viewport.new(cfg.RES_W, cfg.RES_H, cfg.SCALE_START)
  
  -- Reset animation
  logoY = -50
  menuY = 200
  animTimer = 0
  pulseTimer = 0
  selectedOption = 1
  
  -- Build menu options
  local saveData = Save.getData()
  local hasSave = saveData.progress.score > 0 or saveData.progress.gemsCollected > 0
  
  menuOptions = {
    { text = "NEW GAME", action = "new_game" },
    { text = "CONTINUE", action = "continue", enabled = hasSave },
    { text = "OPTIONS", action = "options" },
    { text = "QUIT", action = "quit" },
  }
  
  -- Find first enabled option
  while not (menuOptions[selectedOption].enabled == nil or menuOptions[selectedOption].enabled) do
    selectedOption = selectedOption + 1
    if selectedOption > #menuOptions then
      selectedOption = 1
      break
    end
  end
  
  -- Play title music
  Audio.playMusic("title")
  
  print("Title screen loaded")
end

function TitleScene:exit()
  -- Nothing to clean up
end

function TitleScene:update(dt)
  -- Animate logo sliding in
  if logoY < logoTargetY then
    logoY = logoY + 300 * dt
    if logoY > logoTargetY then
      logoY = logoTargetY
    end
  end
  
  -- Animate menu sliding in
  if menuY > menuTargetY then
    menuY = menuY - 400 * dt
    if menuY < menuTargetY then
      menuY = menuTargetY
    end
  end
  
  animTimer = animTimer + dt
  pulseTimer = pulseTimer + dt
  
  -- Input handling using menu action names
  if Input.wasPressed("menu_up") then
    Audio.playSFX("menu_move")
    selectedOption = selectedOption - 1
    if selectedOption < 1 then
      selectedOption = #menuOptions
    end
    -- Skip disabled options
    local tries = 0
    while not (menuOptions[selectedOption].enabled == nil or menuOptions[selectedOption].enabled) do
      selectedOption = selectedOption - 1
      if selectedOption < 1 then
        selectedOption = #menuOptions
      end
      tries = tries + 1
      if tries > #menuOptions then break end
    end
  elseif Input.wasPressed("menu_down") then
    Audio.playSFX("menu_move")
    selectedOption = selectedOption + 1
    if selectedOption > #menuOptions then
      selectedOption = 1
    end
    -- Skip disabled options
    local tries = 0
    while not (menuOptions[selectedOption].enabled == nil or menuOptions[selectedOption].enabled) do
      selectedOption = selectedOption + 1
      if selectedOption > #menuOptions then
        selectedOption = 1
      end
      tries = tries + 1
      if tries > #menuOptions then break end
    end
  elseif Input.wasPressed("menu_select") then
    Audio.playSFX("menu_select")
    self:executeOption(menuOptions[selectedOption].action)
  end
end

function TitleScene:executeOption(action)
  local SceneManager = require("src.scenemanager")
  
  if action == "new_game" then
    -- Reset save and start fresh
    Save.delete()
    Save.load()
    SceneManager.switch("game", {
      transition = "fade",
      duration = 0.8,
      callback = function()
        Audio.playMusic("stage")
      end
    })
  elseif action == "continue" then
    -- Load existing save
    Save.load()
    SceneManager.switch("game", {
      transition = "fade",
      duration = 0.8,
      callback = function()
        Audio.playMusic("stage")
      end
    })
  elseif action == "options" then
    -- TODO: Options screen
    print("Options not yet implemented")
  elseif action == "quit" then
    love.event.quit()
  end
end

function TitleScene:draw()
  -- Use viewport for proper scaling
  viewport:begin()
  
  love.graphics.clear(cfg.COLORS.bg)
  
  -- Background gradient effect
  for i = 0, cfg.RES_H, 4 do
    local alpha = (i / cfg.RES_H) * 0.3
    love.graphics.setColor(cfg.COLORS.accent[1], cfg.COLORS.accent[2], cfg.COLORS.accent[3], alpha)
    love.graphics.rectangle("fill", 0, i, cfg.RES_W, 4)
  end
  
  -- Logo / Title
  love.graphics.setColor(cfg.COLORS.accent)
  local title = "CONTRA-VANIA"
  local titleFont = love.graphics.getFont()
  local titleW = titleFont:getWidth(title) * 2
  
  -- Draw with scale for larger text
  love.graphics.push()
  love.graphics.translate(cfg.RES_W / 2, math.floor(logoY))
  love.graphics.scale(2, 2)
  love.graphics.print(title, -titleW / 4, 0)
  love.graphics.pop()
  
  -- Subtitle
  love.graphics.setColor(cfg.COLORS.hud_label)
  local subtitle = "Run. Gun. Explore."
  local subW = titleFont:getWidth(subtitle)
  love.graphics.print(subtitle, (cfg.RES_W - subW) / 2, math.floor(logoY) + 25)
  
  -- Menu options
  local startY = math.floor(menuY)
  local spacing = 20
  
  for i, option in ipairs(menuOptions) do
    local y = startY + (i - 1) * spacing
    local enabled = option.enabled == nil or option.enabled
    
    -- Selection indicator
    if i == selectedOption and enabled then
      love.graphics.setColor(cfg.COLORS.accent)
      local pulse = math.sin(pulseTimer * 5) * 0.3 + 0.7
      love.graphics.setColor(cfg.COLORS.accent[1] * pulse, cfg.COLORS.accent[2] * pulse, cfg.COLORS.accent[3] * pulse, 1)
      love.graphics.print(">", 60, y)
    end
    
    -- Option text
    if enabled then
      if i == selectedOption then
        love.graphics.setColor(cfg.COLORS.white)
      else
        love.graphics.setColor(cfg.COLORS.hud_label)
      end
    else
      love.graphics.setColor(0.3, 0.3, 0.3, 1)
    end
    
    love.graphics.print(option.text, 80, y)
  end
  
  -- Footer - show correct keys
  love.graphics.setColor(cfg.COLORS.hud_label[1], cfg.COLORS.hud_label[2], cfg.COLORS.hud_label[3], 0.5)
  local footer = "W/S or UP/DOWN arrows  SPACE/ENTER to select"
  local footerW = titleFont:getWidth(footer)
  love.graphics.print(footer, (cfg.RES_W - footerW) / 2, cfg.RES_H - 20)
  
  love.graphics.setColor(1, 1, 1, 1)
  
  viewport:finish()
end

function TitleScene:keypressed(key)
  -- Input handled through Input module in update
end

function TitleScene:keyreleased(key)
  -- Nothing needed
end

return TitleScene