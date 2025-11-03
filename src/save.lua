local Save = {}

-- Save file name
local SAVE_FILE = "contra_vania_save.lua"

-- Default save data structure
local defaultData = {
  version = 1,
  
  -- Player progress
  progress = {
    currentLevel = "assets.levels.level1",
    checkpointX = 32,
    checkpointY = 160,
    score = 0,
    gemsCollected = 0,
  },
  
  -- Settings
  settings = {
    musicVolume = 0.7,
    sfxVolume = 0.8,
    debugMode = false,
  },
  
  -- Stats
  stats = {
    totalDeaths = 0,
    totalKills = 0,
    playTime = 0,
  }
}

-- Current save data (in memory)
local data = nil

-- Initialize with default data
function Save.init()
  data = {}
  for k, v in pairs(defaultData) do
    if type(v) == "table" then
      data[k] = {}
      for k2, v2 in pairs(v) do
        data[k][k2] = v2
      end
    else
      data[k] = v
    end
  end
end

-- Serialize table to string
local function serialize(tbl, indent)
  indent = indent or 0
  local result = "{\n"
  local prefix = string.rep("  ", indent + 1)
  
  for k, v in pairs(tbl) do
    result = result .. prefix
    
    -- Key
    if type(k) == "string" then
      result = result .. k .. " = "
    else
      result = result .. "[" .. k .. "] = "
    end
    
    -- Value
    if type(v) == "table" then
      result = result .. serialize(v, indent + 1)
    elseif type(v) == "string" then
      result = result .. string.format("%q", v)
    elseif type(v) == "number" or type(v) == "boolean" then
      result = result .. tostring(v)
    end
    
    result = result .. ",\n"
  end
  
  result = result .. string.rep("  ", indent) .. "}"
  return result
end

-- Save data to file
function Save.save()
  if not data then return false end
  
  local serialized = "return " .. serialize(data)
  local success = love.filesystem.write(SAVE_FILE, serialized)
  
  if success then
    print("Save successful: " .. SAVE_FILE)
    return true
  else
    print("Save failed!")
    return false
  end
end

-- Load data from file
function Save.load()
  local info = love.filesystem.getInfo(SAVE_FILE)
  if not info then
    print("No save file found, using defaults")
    Save.init()
    return false
  end
  
  local chunk, err = love.filesystem.load(SAVE_FILE)
  if not chunk then
    print("Error loading save file: " .. tostring(err))
    Save.init()
    return false
  end
  
  local ok, loaded = pcall(chunk)
  if not ok or type(loaded) ~= "table" then
    print("Error parsing save file")
    Save.init()
    return false
  end
  
  -- Merge with defaults (in case save is from old version)
  data = {}
  for k, v in pairs(defaultData) do
    if type(v) == "table" then
      data[k] = {}
      for k2, v2 in pairs(v) do
        if loaded[k] and loaded[k][k2] ~= nil then
          data[k][k2] = loaded[k][k2]
        else
          data[k][k2] = v2
        end
      end
    else
      data[k] = loaded[k] or v
    end
  end
  
  print("Save loaded successfully")
  return true
end

-- Get save data
function Save.getData()
  return data
end

-- Update progress
function Save.setCheckpoint(x, y)
  if data then
    data.progress.checkpointX = x
    data.progress.checkpointY = y
  end
end

function Save.setLevel(levelPath)
  if data then
    data.progress.currentLevel = levelPath
  end
end

function Save.setScore(score)
  if data then
    data.progress.score = score
  end
end

function Save.setGems(gems)
  if data then
    data.progress.gemsCollected = gems
  end
end

-- Update settings
function Save.setSettings(settings)
  if data and settings then
    for k, v in pairs(settings) do
      data.settings[k] = v
    end
  end
end

function Save.getSettings()
  return data and data.settings or defaultData.settings
end

-- Update stats
function Save.incrementDeaths()
  if data then
    data.stats.totalDeaths = data.stats.totalDeaths + 1
  end
end

function Save.incrementKills()
  if data then
    data.stats.totalKills = data.stats.totalKills + 1
  end
end

function Save.addPlayTime(dt)
  if data then
    data.stats.playTime = data.stats.playTime + dt
  end
end

-- Delete save file (for testing or "New Game")
function Save.delete()
  local success = love.filesystem.remove(SAVE_FILE)
  if success then
    print("Save file deleted")
    Save.init()
  end
  return success
end

-- Get save file path (for user reference)
function Save.getSaveDirectory()
  return love.filesystem.getSaveDirectory()
end

return Save