---@diagnostic disable: undefined-global
local cfg        = require("config")
local dbg        = require("cv_debug")
local Player     = require("src.player")
local Camera     = require("src.camera")
local Viewport   = require("src.viewport")
local Background = require("src.background")
local Layers    = require("src.layers")
local Input     = require("src.input")
local Assets    = require("src.assets")   -- NEW
local Enemy    = require("src.enemy")   -- NEW


local player, camera, viewport
local world = {
  width  = cfg.WORLD_WIDTH,
  height = cfg.RES_H,
  floor  = cfg.RES_H - cfg.FLOOR_OFFSET,
}
local enemies = {}                      -- NEW

function love.load()
  love.window.setTitle("Contra-Vania (Step 6: parallax)")
  love.graphics.setDefaultFilter("nearest", "nearest", 1)
  love.graphics.setLineStyle("rough")  -- avoid smoothing on lines
  love.window.setMode(
    cfg.RES_W * cfg.SCALE_START, cfg.RES_H * cfg.SCALE_START,
    { resizable = true, minwidth = cfg.RES_W, minheight = cfg.RES_H }
  )

  Assets.loadAll({
    player_idle = cfg.SPRITES.player.idlePath,
    player_run  = cfg.SPRITES.player.runPath,
    player_jump = cfg.SPRITES.player.jumpPath,
  })

  viewport   = Viewport.new(cfg.RES_W, cfg.RES_H, cfg.SCALE_START)
  player     = Player.new(world)
  camera     = Camera.new()

    -- Example enemies (pivot at feet; y = world.floor)
  enemies = {
    Enemy.new{ x = 200, y = world.floor, patrolMin = 180, patrolMax = 260, speed = 30 },
    Enemy.new{ x = 380, y = world.floor, patrolMin = 360, patrolMax = 460, speed = 45 },
  }



  dbg.log("assets", ("run_strip: %s"):format(Assets.get("player_run") and "LOADED" or "MISSING"))

  dbg.log("boot", "initialized viewport, background, player, camera, debug")
end

function love.resize()
  if viewport then viewport:updateScale() end
end

function love.update(dt)
  dbg.update(dt)

  -- player uses input state
  if player then player:update(dt, Input) end

  if camera and player then camera:update(player, world, cfg.RES_W, cfg.RES_H) end
  
  for i = 1, #enemies do
    enemies[i]:update(dt, world)
  end

  -- clear pressed/released edges for next frame
  Input.update(dt)   -- NEW
end


function love.keypressed(key)
  Input.keypressed(key)              -- NEW
  if Input.wasPressed("debug") then dbg.toggle() end
  if Input.wasPressed("dump")  then dbg.dump()   end
  if Input.wasPressed("quit")  then love.event.quit() end
end

function love.keyreleased(key)
  Input.keyreleased(key)             -- NEW
end


function love.draw()
  viewport:begin()

  Layers.begin()

  -- Background layer (no camera)
  Layers.add("background", function()
    Background.draw(camera and camera.x or 0, cfg.RES_W, cfg.RES_H)
  end)

  -- World layer (camera applied automatically by Layers.draw)
  Layers.add("world", function()
    -- floor
    love.graphics.setColor(cfg.COLORS.floor)
    love.graphics.line(0, world.floor, world.width, world.floor)
    -- player
    if player then player:draw() end
    
    -- enemies
    for i = 1, #enemies do
    enemies[i]:draw()
    end
  end)

  -- UI layer (screen space)
  Layers.add("ui", function()
    love.graphics.setColor(cfg.COLORS.accent)
    love.graphics.rectangle("line", 8, 8, cfg.RES_W - 16, cfg.RES_H - 16)
    love.graphics.setColor(cfg.COLORS.white)
  end)

  Layers.draw({ camera = camera })

  viewport:finish()
  dbg.draw()
end

