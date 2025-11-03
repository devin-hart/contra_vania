local Audio = {}

-- Audio storage
local music = {}
local sfx = {}
local currentMusic = nil

-- Volume settings (0.0 to 1.0)
local musicVolume = 0.7
local sfxVolume = 0.8

-- Try to load an audio file safely, checking multiple formats
local function tryLoad(basePath, type)
  -- Try different extensions in order of preference
  local extensions = {".ogg", ".mp3", ".wav"}
  
  for _, ext in ipairs(extensions) do
    local path = basePath .. ext
    local ok, result = pcall(function()
      return love.audio.newSource(path, type)
    end)
    if ok and result then
      return result
    end
  end
  
  -- None found
  return nil
end

-- Initialize audio system
function Audio.init()
  -- Load music tracks (streamed for memory efficiency)
  -- Will auto-detect .ogg, .mp3, or .wav
  music.title = tryLoad("assets/audio/music/title", "stream")
  music.stage = tryLoad("assets/audio/music/stage", "stream")
  music.boss = tryLoad("assets/audio/music/boss", "stream")
  
  -- Set music to loop
  for _, track in pairs(music) do
    if track then track:setLooping(true) end
  end
  
  -- Load sound effects (static for instant playback)
  -- Will auto-detect .ogg, .mp3, or .wav
  sfx.jump = tryLoad("assets/audio/sfx/jump", "static")
  sfx.shoot = tryLoad("assets/audio/sfx/shoot", "static")
  sfx.hit = tryLoad("assets/audio/sfx/hit", "static")
  sfx.explode = tryLoad("assets/audio/sfx/explode", "static")
  sfx.collect = tryLoad("assets/audio/sfx/collect", "static")
  sfx.pause = tryLoad("assets/audio/sfx/pause", "static")
  sfx.menu_move = tryLoad("assets/audio/sfx/menu_move", "static")
  sfx.menu_select = tryLoad("assets/audio/sfx/menu_select", "static")
  
  Audio.applyVolume()
end

-- Play music track
function Audio.playMusic(name)
  if currentMusic then
    currentMusic:stop()
  end
  
  local track = music[name]
  if track then
    currentMusic = track
    track:play()
  end
end

-- Stop current music
function Audio.stopMusic()
  if currentMusic then
    currentMusic:stop()
    currentMusic = nil
  end
end

-- Play sound effect
function Audio.playSFX(name)
  local sound = sfx[name]
  if sound then
    -- Clone the source so multiple instances can play simultaneously
    local instance = sound:clone()
    instance:setVolume(sfxVolume)
    instance:play()
  end
end

-- Set volumes
function Audio.setMusicVolume(vol)
  musicVolume = math.max(0, math.min(1, vol))
  if currentMusic then
    currentMusic:setVolume(musicVolume)
  end
end

function Audio.setSFXVolume(vol)
  sfxVolume = math.max(0, math.min(1, vol))
end

-- Apply volume to all sources
function Audio.applyVolume()
  for _, track in pairs(music) do
    if track then track:setVolume(musicVolume) end
  end
  
  -- SFX volume applied per-instance when playing
end

-- Get current volumes
function Audio.getMusicVolume()
  return musicVolume
end

function Audio.getSFXVolume()
  return sfxVolume
end

-- Pause/resume music
function Audio.pauseMusic()
  if currentMusic and currentMusic:isPlaying() then
    currentMusic:pause()
  end
end

function Audio.resumeMusic()
  if currentMusic then
    currentMusic:play()
  end
end

return Audio