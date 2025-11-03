local cfg = require("config")

local BossBar = {}

function BossBar.draw(boss, bossName)
  -- Don't show if boss is dead or not active
  if not boss or not boss:isActive() or boss.dead then return end
  
  local W = cfg.RES_W
  local barW = 280
  local barH = 16
  local barX = (W - barW) / 2
  local barY = 20
  
  -- Boss name
  love.graphics.setColor(cfg.COLORS.white)
  local nameW = love.graphics.getFont():getWidth(bossName or "BOSS")
  love.graphics.print(bossName or "BOSS", (W - nameW) / 2, barY - 14)
  
  -- Background
  love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
  love.graphics.rectangle("fill", barX - 2, barY - 2, barW + 4, barH + 4)
  
  -- Empty bar
  love.graphics.setColor(0.3, 0.1, 0.1, 1)
  love.graphics.rectangle("fill", barX, barY, barW, barH)
  
  -- Health fill
  local healthPercent = boss:getHealthPercent()
  local fillW = math.floor(barW * healthPercent)
  
  -- Color based on health
  local healthColor = {0.9, 0.2, 0.2, 1}  -- Red
  if healthPercent > 0.66 then
    healthColor = {0.9, 0.3, 0.2, 1}  -- Orange-red
  elseif healthPercent <= 0.33 then
    healthColor = {0.95, 0.1, 0.1, 1}  -- Bright red (critical)
  end
  
  love.graphics.setColor(healthColor)
  love.graphics.rectangle("fill", barX, barY, fillW, barH)
  
  -- Segmented bar effect (phase markers)
  love.graphics.setColor(0, 0, 0, 0.5)
  local segments = 4
  for i = 1, segments - 1 do
    local segX = barX + (barW / segments) * i
    love.graphics.rectangle("fill", segX - 1, barY, 2, barH)
  end
  
  -- Border
  love.graphics.setColor(cfg.COLORS.white)
  love.graphics.rectangle("line", barX, barY, barW, barH)
  
  -- HP text
  local hpText = string.format("%d / %d", boss.hp, boss.maxHp)
  local textW = love.graphics.getFont():getWidth(hpText)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(hpText, (W - textW) / 2, barY + 2)
  
  love.graphics.setColor(1, 1, 1, 1)
end

return BossBar