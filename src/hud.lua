local cfg = require("config")

-- Try to load boss bar, fallback if not found
local BossBar = nil
local ok, result = pcall(require, "src.ui.bossbar")
if ok then
  BossBar = result
else
  print("Warning: Could not load boss bar UI: " .. tostring(result))
end

local HUD = {}

-- Draw a simple health bar
local function drawHealthBar(x, y, current, max)
  local barW = 60
  local barH = 8
  
  -- Background
  love.graphics.setColor(0.2, 0.2, 0.2, 1)
  love.graphics.rectangle("fill", x, y, barW, barH)
  
  -- Health fill
  local fillW = math.floor((current / max) * barW)
  local healthColor = cfg.COLORS.hud_health_full
  
  -- Color based on health percentage
  if current / max < 0.3 then
    healthColor = cfg.COLORS.hud_health_low
  elseif current / max < 0.6 then
    healthColor = cfg.COLORS.hud_health_mid
  end
  
  love.graphics.setColor(healthColor)
  love.graphics.rectangle("fill", x, y, fillW, barH)
  
  -- Border
  love.graphics.setColor(cfg.COLORS.white)
  love.graphics.rectangle("line", x, y, barW, barH)
end

-- Draw ammo counter with icon
local function drawAmmo(x, y, current, max)
  love.graphics.setColor(cfg.COLORS.white)
  
  -- Simple bullet icon
  love.graphics.setColor(cfg.COLORS.accent)
  love.graphics.rectangle("fill", x, y + 2, 4, 8)
  love.graphics.setColor(cfg.COLORS.white)
  
  -- Text
  local text = current == math.huge and "∞" or string.format("%d/%d", current, max)
  love.graphics.print(text, x + 8, y)
end

-- Draw score with label
local function drawScore(x, y, score)
  love.graphics.setColor(cfg.COLORS.hud_label)
  love.graphics.print("SCORE", x, y)
  
  love.graphics.setColor(cfg.COLORS.white)
  love.graphics.print(string.format("%06d", score), x, y + 10)
end

-- Draw gems/collectibles counter
local function drawGems(x, y, count)
  love.graphics.setColor(cfg.COLORS.hud_label)
  love.graphics.print("GEMS", x, y)
  
  -- Gem icon
  love.graphics.setColor(0.95, 0.8, 0.2, 1)
  love.graphics.rectangle("fill", x, y + 10, 6, 6)
  
  love.graphics.setColor(cfg.COLORS.white)
  love.graphics.print("×" .. count, x + 10, y + 10)
end

-- Main HUD draw function
function HUD.draw(player, gameState, boss, bossName)
  if not player then return end
  
  local margin = 10
  local lineH = 20
  
  -- Top-left: Health
  love.graphics.setColor(cfg.COLORS.hud_label)
  love.graphics.print("HEALTH", margin, margin)
  drawHealthBar(margin, margin + 12, player.hp or 3, player.maxHp or 3)
  
  -- Top-left: Ammo (below health)
  love.graphics.setColor(cfg.COLORS.hud_label)
  love.graphics.print("AMMO", margin, margin + lineH + 12)
  drawAmmo(margin, margin + lineH + 24, 
           player.ammo or math.huge, 
           player.maxAmmo or math.huge)
  
  -- Top-right: Score
  local scoreX = cfg.RES_W - 70
  drawScore(scoreX, margin, gameState.score or 0)
  
  -- Top-right: Gems (below score)
  drawGems(scoreX, margin + lineH + 12, gameState.gems or 0)
  
  -- Boss health bar (if boss active)
  if boss and boss:isActive() then
    BossBar.draw(boss, bossName)
  end
  
  -- Reset color
  love.graphics.setColor(1, 1, 1, 1)
end

-- Draw pause overlay
function HUD.drawPauseMenu()
  -- Darken background
  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 0, 0, cfg.RES_W, cfg.RES_H)
  
  -- Pause text
  love.graphics.setColor(cfg.COLORS.white)
  local text = "PAUSED"
  local textW = love.graphics.getFont():getWidth(text)
  love.graphics.print(text, (cfg.RES_W - textW) / 2, cfg.RES_H / 2 - 20)
  
  -- Instructions
  love.graphics.setColor(cfg.COLORS.hud_label)
  local help = "Press ESC to resume"
  local helpW = love.graphics.getFont():getWidth(help)
  love.graphics.print(help, (cfg.RES_W - helpW) / 2, cfg.RES_H / 2 + 10)
  
  love.graphics.setColor(1, 1, 1, 1)
end

return HUD