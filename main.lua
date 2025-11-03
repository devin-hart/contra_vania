local cfg          = require("config")
local dbg          = require("cv_debug")
local Assets       = require("src.assets")
local Input        = require("src.input")
local Audio        = require("src.audio")
local Save         = require("src.save")
local SceneManager = require("src.scenemanager")

function love.load()
  love.window.setTitle("Contra-Vania")
  love.graphics.setDefaultFilter("nearest", "nearest", 1)
  love.graphics.setLineStyle("rough")
  love.window.setMode(
    cfg.RES_W * cfg.SCALE_START, cfg.RES_H * cfg.SCALE_START,
    { resizable = true, minwidth = cfg.RES_W, minheight = cfg.RES_H }
  )

  -- Load all assets
  Assets.loadAll({
    player_idle = cfg.SPRITES.player.idlePath,
    player_run  = cfg.SPRITES.player.runPath,
    player_jump = cfg.SPRITES.player.jumpPath,
    enemy_idle  = "assets/gfx/enemy/idle_strip.png",
    enemy_walk  = "assets/gfx/enemy/walk_strip.png",
    tileset     = cfg.SPRITES.tileset.path,
  })

  -- Initialize systems
  Audio.init()
  Save.load()
  
  local settings = Save.getSettings()
  Audio.setMusicVolume(settings.musicVolume)
  Audio.setSFXVolume(settings.sfxVolume)

  -- Register scenes
  SceneManager.register("title", require("src.scenes.title"))
  SceneManager.register("game", require("src.scenes.game"))

  -- Start with title screen
  SceneManager.switch("title")

  dbg.log("boot", "Step 27: Title Screen + Scene Flow")
  dbg.log("save", "Save directory: " .. Save.getSaveDirectory())
end

function love.resize(w, h)
  -- Notify current scene of resize if it has a resize method
  local currentScene = SceneManager.current()
  if currentScene then
    local scene = require("src.scenemanager")
    -- Scenes handle their own viewport updates
  end
end

function love.update(dt)
  dbg.update(dt)
  
  -- Update input before scene
  Input.update(dt)
  
  -- Update scene
  SceneManager.update(dt)
end

function love.keypressed(key)
  Input.keypressed(key)
  
  -- Global debug keys (work in all scenes)
  if Input.wasPressed("debug") then dbg.toggle() end
  if Input.wasPressed("dump")  then dbg.dump()   end
  
  -- Forward to scene manager
  SceneManager.keypressed(key)
end

function love.keyreleased(key)
  Input.keyreleased(key)
  SceneManager.keyreleased(key)
end

function love.draw()
  -- Scene manager handles all drawing
  SceneManager.draw()
  
  -- Debug overlay always on top
  dbg.draw()
end