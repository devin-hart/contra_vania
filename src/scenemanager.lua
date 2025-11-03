-- Scene Manager: Handles game state transitions and scene flow
local SceneManager = {}

local currentScene = nil
local scenes = {}
local transitionActive = false
local transitionTimer = 0
local transitionDuration = 0.5
local transitionType = "fade"  -- fade, slide, etc.
local nextScene = nil
local transitionCallback = nil

-- Register a scene
function SceneManager.register(name, scene)
  scenes[name] = scene
end

-- Get current scene name
function SceneManager.current()
  return currentScene
end

-- Switch to a new scene with optional transition
function SceneManager.switch(name, opts)
  opts = opts or {}
  
  if not scenes[name] then
    error("Scene not found: " .. tostring(name))
  end
  
  if opts.transition then
    -- Start transition
    transitionActive = true
    transitionTimer = 0
    transitionDuration = opts.duration or 0.5
    transitionType = opts.transition or "fade"
    nextScene = name
    transitionCallback = opts.callback
    
    -- Call current scene exit
    if currentScene and scenes[currentScene].exit then
      scenes[currentScene]:exit()
    end
  else
    -- Immediate switch
    if currentScene and scenes[currentScene].exit then
      scenes[currentScene]:exit()
    end
    
    currentScene = name
    
    if scenes[currentScene].enter then
      scenes[currentScene]:enter(opts.data)
    end
    
    if opts.callback then
      opts.callback()
    end
  end
end

-- Update current scene and transitions
function SceneManager.update(dt)
  if transitionActive then
    transitionTimer = transitionTimer + dt
    
    -- Halfway through transition, switch scenes
    if transitionTimer >= transitionDuration / 2 and nextScene then
      local oldScene = currentScene
      currentScene = nextScene
      nextScene = nil
      
      if scenes[currentScene].enter then
        scenes[currentScene]:enter()
      end
    end
    
    -- Transition complete
    if transitionTimer >= transitionDuration then
      transitionActive = false
      transitionTimer = 0
      
      if transitionCallback then
        transitionCallback()
        transitionCallback = nil
      end
    end
  end
  
  -- Update current scene
  if currentScene and scenes[currentScene].update then
    scenes[currentScene]:update(dt)
  end
end

-- Draw current scene and transition overlay
function SceneManager.draw()
  -- Draw current scene
  if currentScene and scenes[currentScene].draw then
    scenes[currentScene]:draw()
  end
  
  -- Draw transition overlay
  if transitionActive then
    local alpha = 0
    
    if transitionTimer < transitionDuration / 2 then
      -- Fade out
      alpha = (transitionTimer / (transitionDuration / 2))
    else
      -- Fade in
      alpha = 1 - ((transitionTimer - transitionDuration / 2) / (transitionDuration / 2))
    end
    
    if transitionType == "fade" then
      love.graphics.setColor(0, 0, 0, alpha)
      love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
      love.graphics.setColor(1, 1, 1, 1)
    end
  end
end

-- Forward input events to current scene
function SceneManager.keypressed(key)
  if currentScene and scenes[currentScene].keypressed then
    scenes[currentScene]:keypressed(key)
  end
end

function SceneManager.keyreleased(key)
  if currentScene and scenes[currentScene].keyreleased then
    scenes[currentScene]:keyreleased(key)
  end
end

-- Check if in transition
function SceneManager.isTransitioning()
  return transitionActive
end

return SceneManager