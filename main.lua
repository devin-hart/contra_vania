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
local Collisions = require("src.systems.collisions")
local Items      = require("src.systems.items")
local Tilemap    = require("src.tilemap")

local player, camera, viewport, map
local enemies = {}

-- World definition
local world = {
  width  = cfg.WORLD_WIDTH,
  height = cfg.RES_H,
  floor  = cfg.RES_H - cfg.FLOOR_OFFSET,
}

function love.load()
  love.window.setTitle("Contra-Vania")
  love.graphics.setDefaultFilter("nearest", "nearest", 1)
  love.graphics.setLineStyle("rough")
  love.window.setMode(
    cfg.RES_W * cfg.SCALE_START, cfg.RES_H * cfg.SCALE_START,
    { resizable = true, minwidth = cfg.RES_W, minheight = cfg.RES_H }
  )

  -- Preload optional sprites (safe if missing)
  Assets.loadAll({
    player_idle = cfg.SPRITES.player.idlePath,
    player_run  = cfg.SPRITES.player.runPath,
    player_jump = cfg.SPRITES.player.jumpPath,
    enemy_idle  = "assets/gfx/enemy/idle_strip.png",
    enemy_walk  = "assets/gfx/enemy/walk_strip.png",
  })

  -- Load level
  map = Tilemap.load("assets.levels.level1")
  world.width  = map.worldWidth
  world.height = map.worldHeight
  world.floor  = cfg.RES_H - cfg.FLOOR_OFFSET   -- legacy floor still active

  viewport = Viewport.new(cfg.RES_W, cfg.RES_H, cfg.SCALE_START)
  player   = Player.new(world)
  camera   = Camera.new()
  Projectiles.init()
  Items.init()

  -- sample items
  Items.spawn(260, world.floor - 10, "gem")
  Items.spawn(440, world.floor - 10, "gem")

  -- sample enemies
  enemies = {
    Enemy.new{ x = 200, y = world.floor, patrolMin = 180, patrolMax = 260, speed = 30 },
    Enemy.new{ x = 380, y = world.floor, patrolMin = 360, patrolMax = 460, speed = 45 },
  }

  dbg.log("boot", "initialized viewport, assets, map, player, enemies, camera")
end

function love.resize()
  if viewport then viewport:updateScale() end
end

function love.update(dt)
  dbg.update(dt)

  -- Player + camera
  if player then player:update(dt, Input, map) end
  if camera and player then camera:update(player, world, cfg.RES_W, cfg.RES_H) end

  -- Fire
  if Input.wasPressed("shoot") and player then
    local mx, my, dir = player:getMuzzle()
    Projectiles.spawn(mx, my, dir)
  end

  -- Update systems
  Projectiles.update(dt, map)
  Items.update(dt)
  Collisions.update(dt, world, player, enemies, Projectiles, Items)

  -- Enemy logic + cleanup
  for i = 1, #enemies do
    enemies[i]:update(dt, world)
  end
  local e = 1
  while e <= #enemies do
    local en = enemies[e]
    if en.dead and (en.deathTime or 0) <= 0 then
      table.remove(enemies, e)
    else
      e = e + 1
    end
  end

  Input.update(dt)
end

function love.keypressed(key)
  Input.keypressed(key)
  if Input.wasPressed("debug") then dbg.toggle() end   -- F1
  if Input.wasPressed("dump")  then dbg.dump()   end   -- F2
  if Input.wasPressed("quit")  then love.event.quit() end
end

function love.keyreleased(key)
  Input.keyreleased(key)
end

function love.draw()
  viewport:begin()
  Layers.begin()

  -- Background (static)
  Layers.add("background", function()
    Background.draw(camera and camera.x or 0, cfg.RES_W, cfg.RES_H)
  end)

  -- World (camera)
  Layers.add("world", function()
    -- MAP (draw behind everything else)
    if map then map:draw(camera and camera.x or 0, cfg.RES_W, cfg.RES_H) end

    -- Entities
    Projectiles.draw()
    Items.draw()
    if player then player:draw() end
    for i = 1, #enemies do enemies[i]:draw() end

    -- Debug: world-space overlays (solids + colliders)
    if dbg.isVisible() then
      dbg.drawTilemap(map)
      dbg.drawColliders(player, enemies)
    end

    -- (optional) floor line for legacy reference
    love.graphics.setColor(cfg.COLORS.floor)
    love.graphics.line(0, world.floor, world.width, world.floor)
    love.graphics.setColor(1,1,1,1)
  end)

  -- UI
  Layers.add("ui", function()
    love.graphics.setColor(cfg.COLORS.accent)
    love.graphics.rectangle("line", 8, 8, cfg.RES_W - 16, cfg.RES_H - 16)
    love.graphics.setColor(cfg.COLORS.white)
    love.graphics.print("Contra-Vania — Step 20 (debug overlays)", 10, 10)
  end)

  Layers.draw({ camera = camera })
  viewport:finish()

  -- Screen-space debug HUD
  dbg.draw()
end
