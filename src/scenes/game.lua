local cfg        = require("config")
local dbg        = require("cv_debug")
local Assets     = require("src.assets")
local Input      = require("src.input")
local Player     = require("src.player")
local Enemy      = require("src.enemy")
local Camera     = require("src.camera")
local Viewport   = require("src.viewport")
local Background = require("src.background")
local Layers     = require("src.layers")
local Projectiles= require("src.systems.projectiles")
local BossProjectiles = require("src.systems.bossprojectiles")
local Collisions = require("src.systems.collisions")
local Items      = require("src.systems.items")
local Tilemap    = require("src.tilemap")
local HUD        = require("src.hud")
local Menu       = require("src.menu")
local Audio      = require("src.audio")
local Save       = require("src.save")
local FlyingEye  = require("src.bosses.flyingeye")

local GameScene = {}

local player, camera, viewport, map, boss
local enemies = {}
local paused = false
local currentCheckpoint = 1
local checkpointRadius = 20
local bossActivated = false

-- Game state
local gameState = {
  score = 0,
  gems = 0,
}

local world = {
  width  = cfg.WORLD_WIDTH,
  height = cfg.RES_H,
  floor  = cfg.RES_H - cfg.FLOOR_OFFSET,
}

function GameScene:enter(data)
  -- Load save data
  local saveData = Save.getData()

  -- Load level
  map = Tilemap.load(saveData.progress.currentLevel)
  world.width  = map.worldWidth
  world.height = map.worldHeight
  world.floor  = cfg.RES_H - cfg.FLOOR_OFFSET

  -- Initialize systems
  viewport = Viewport.new(cfg.RES_W, cfg.RES_H, cfg.SCALE_START)
  viewport:updateScale()  -- Ensure proper scaling on scene enter
  player   = Player.new(world)
  camera   = Camera.new()
  Projectiles.init()
  BossProjectiles.init()
  Items.init()
  Menu.init()
  
  gameState.score = saveData.progress.score
  gameState.gems = saveData.progress.gemsCollected
  Items.count = saveData.progress.gemsCollected
  
  player:respawn(saveData.progress.checkpointX, saveData.progress.checkpointY)
  
  -- Reset flags
  paused = false
  bossActivated = false
  currentCheckpoint = 1

  -- Spawn items
  Items.spawn(260, world.floor - 10, "gem")
  Items.spawn(440, world.floor - 10, "gem")

  -- Spawn enemies
  enemies = {
    Enemy.new{ x = 200, y = world.floor, patrolMin = 180, patrolMax = 260, speed = 30 },
    Enemy.new{ x = 380, y = world.floor, patrolMin = 360, patrolMax = 460, speed = 45 },
  }
  
  -- Create boss if level has spawn point
  if map.bossSpawn then
    boss = FlyingEye.new(map.bossSpawn.x, map.bossSpawn.y)
    dbg.log("boss", string.format("Boss created at x=%d, y=%d (trigger at x=%d)", 
      map.bossSpawn.x, map.bossSpawn.y, map.bossSpawn.triggerX))
  end
  
  dbg.log("game", "Game scene loaded")
end

function GameScene:exit()
  -- Save progress
  Save.save()
  dbg.log("game", "Game scene exited")
end

function GameScene:update(dt)
  if paused then
    if Input.wasPressed("menu_up") then
      Menu.navigate("up")
      Audio.playSFX("menu_move")
    elseif Input.wasPressed("menu_down") then
      Menu.navigate("down")
      Audio.playSFX("menu_move")
    elseif Input.wasPressed("menu_left") then
      Menu.adjustValue(-1)
      Audio.playSFX("menu_move")
      local settings = Menu.getSettings()
      Audio.setMusicVolume(settings.musicVolume)
      Audio.setSFXVolume(settings.sfxVolume)
    elseif Input.wasPressed("menu_right") then
      Menu.adjustValue(1)
      Audio.playSFX("menu_move")
      local settings = Menu.getSettings()
      Audio.setMusicVolume(settings.musicVolume)
      Audio.setSFXVolume(settings.sfxVolume)
    elseif Input.wasPressed("menu_select") then
      Audio.playSFX("menu_select")
      local action = Menu.select()
      if action == "resume" then
        paused = false
        Audio.resumeMusic()
      elseif action == "quit" then
        love.event.quit()
      elseif action == "title" then
        -- Return to title screen
        local SceneManager = require("src.scenemanager")
        Save.save()
        SceneManager.switch("title", {
          transition = "fade",
          duration = 0.8
        })
      end
    end
    
    return
  end
  
  if Input.wasPressed("pause") then
    paused = true
    Menu.init()
    Audio.playSFX("pause")
    Audio.pauseMusic()
  end
  
  if player then player:update(dt, Input, map) end
  if camera and player then camera:update(player, world, cfg.RES_W, cfg.RES_H) end
  
  -- Boss activation trigger
  if boss and not bossActivated and map.bossSpawn and player then
    if player.x >= map.bossSpawn.triggerX then
      bossActivated = true
      local bossStartX = map.bossSpawn.x + 300
      boss:activate(bossStartX, map.bossSpawn.x, map.bossSpawn.y)
      dbg.log("boss", string.format("Boss activated! Player at x=%d", player.x))
    end
  end
  
  -- Update boss
  if boss then
    boss:update(dt, player, world)
    
    if boss:isDead() then
      if not boss.victoryLogged then
        Audio.playMusic("stage")
        BossProjectiles.clear()
        dbg.log("boss", "Boss defeated!")
        boss.victoryLogged = true
      end
    end
  end

  -- Check for player death
  if player and player.hp <= 0 then
    local saveData = Save.getData()
    player:respawn(saveData.progress.checkpointX, saveData.progress.checkpointY)
    Save.incrementDeaths()
    Audio.playSFX("explode")
    dbg.log("player", "Died and respawned at checkpoint")
    
    if boss and bossActivated then
      bossActivated = false
      BossProjectiles.clear()
      if map.bossSpawn then
        boss = FlyingEye.new(map.bossSpawn.x, map.bossSpawn.y)
        Audio.playMusic("stage")
      end
    end
  end
  
  -- Check for checkpoint activation
  if player and map.checkpoints then
    for i, cp in ipairs(map.checkpoints) do
      local dx = player.x - cp.x
      local dy = player.y - cp.y
      local dist = math.sqrt(dx*dx + dy*dy)
      
      if dist < checkpointRadius and i > currentCheckpoint then
        currentCheckpoint = i
        Save.setCheckpoint(cp.x, cp.y)
        Save.save()
        Audio.playSFX("collect")
        dbg.log("checkpoint", string.format("Checkpoint %d activated", i))
      end
    end
  end

  if Input.wasPressed("shoot") and player then
    local mx, my, dir = player:getMuzzle()
    Projectiles.spawn(mx, my, dir)
  end

  Projectiles.update(dt, map)
  BossProjectiles.update(dt, player, map)
  Items.update(dt)
  Collisions.update(dt, world, player, enemies, Projectiles, Items, BossProjectiles, boss)
  
  -- Boss collision with player projectiles
  if boss and boss:isActive() and not boss.dead then
    if Projectiles.list and #Projectiles.list > 0 then
      local bx, by, bw, bh = boss:getCollider()
      local b = 1
      while b <= #Projectiles.list do
        local bullet = Projectiles.list[b]
        local px, py, pw, ph = bullet:getCollider()
        
        local Collision = require("src.collision")
        if Collision.rectsOverlap(px, py, pw, ph, bx, by, bw, bh) then
          boss:takeDamage(1)
          table.remove(Projectiles.list, b)
        else
          b = b + 1
        end
      end
    end
  end

  for i = 1, #enemies do
    enemies[i]:update(dt, world, map)
  end
  
  local e = 1
  while e <= #enemies do
    local en = enemies[e]
    if en.dead and (en.deathTime or 0) <= 0 then
      table.remove(enemies, e)
      Save.incrementKills()
    else
      e = e + 1
    end
  end
  
  gameState.gems = Items.count
  Save.setScore(gameState.score)
  Save.setGems(gameState.gems)
  Save.addPlayTime(dt)
  Save.setSettings(Menu.getSettings())
end

function GameScene:draw()
  viewport:begin()
  Layers.begin()

  Layers.add("background", function()
    Background.draw(camera and camera.x or 0, cfg.RES_W, cfg.RES_H)
  end)

  Layers.add("world", function()
    if map then map:draw(camera and camera.x or 0, cfg.RES_W, cfg.RES_H) end

    Projectiles.draw()
    BossProjectiles.draw()
    Items.draw()
    if player then player:draw() end
    for i = 1, #enemies do enemies[i]:draw() end
    if boss then boss:draw() end

    if dbg.isVisible() then
      dbg.drawTilemap(map)
      dbg.drawColliders(player, enemies)
      
      if boss and map.bossSpawn and not bossActivated then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("fill", map.bossSpawn.triggerX, 0, 2, world.height)
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("BOSS TRIGGER", map.bossSpawn.triggerX + 5, 20)
      end
      
      if map.checkpoints then
        for i, cp in ipairs(map.checkpoints) do
          local color = i <= currentCheckpoint and {0, 1, 0, 0.5} or {1, 1, 0, 0.5}
          love.graphics.setColor(color)
          love.graphics.circle("fill", cp.x, cp.y, checkpointRadius)
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.circle("line", cp.x, cp.y, checkpointRadius)
        end
        love.graphics.setColor(1, 1, 1, 1)
      end
    end
  end)

  Layers.add("ui", function()
    local bossName = boss and boss:isActive() and "FLYING EYE" or nil
    HUD.draw(player, gameState, boss, bossName)
    if paused then
      Menu.draw()
    end
  end)

  Layers.draw({ camera = camera })
  viewport:finish()
end

function GameScene:keypressed(key)
  -- Handled in update via Input
end

function GameScene:keyreleased(key)
  -- Handled in update via Input
end

return GameScene