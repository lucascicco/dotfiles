-- AI Tools Configuration for Neovim
-- Checks which AI tools are enabled via environment variables or config file
--
-- Priority (highest to lowest):
-- 1. Environment variables: DOTFILES_AI_<TOOL>=1
-- 2. Config file: ~/.config/dotfiles/ai.toml
-- 3. Repo config: ~/dotfiles/config/ai/ai.toml
-- 4. Default: disabled

local M = {}

-- Cache for parsed config
local config_cache = nil
local config_loaded = false

-- Config file paths
local function get_config_paths()
  local home = os.getenv("HOME") or ""
  local dotfiles = os.getenv("DOTFILES_DIR") or (home .. "/dotfiles")

  return {
    local_config = home .. "/.config/dotfiles/ai.toml",
    repo_config = dotfiles .. "/config/ai/ai.toml",
  }
end

-- Check if file exists
local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

-- Simple TOML parser for our specific format
local function parse_toml_file(path)
  if not file_exists(path) then
    return nil
  end

  local config = {}
  local current_section = nil

  for line in io.lines(path) do
    -- Skip comments and empty lines
    if not line:match("^%s*#") and line:match("%S") then
      -- Section header
      local section = line:match("^%s*%[([%w_]+)%]%s*$")
      if section then
        current_section = section
        config[section] = config[section] or {}
      elseif current_section then
        -- Key = value
        local key, value = line:match("^%s*([%w_]+)%s*=%s*(.+)%s*$")
        if key and value then
          -- Parse boolean values
          value = value:lower():gsub("^%s*(.-)%s*$", "%1")
          if value == "true" or value == "1" or value == "yes" then
            config[current_section][key] = true
          elseif value == "false" or value == "0" or value == "no" then
            config[current_section][key] = false
          else
            config[current_section][key] = value
          end
        end
      end
    end
  end

  return config
end

-- Load config from files (cached)
local function load_config()
  if config_loaded then
    return config_cache
  end

  local paths = get_config_paths()

  -- Try local config first, then repo config
  config_cache = parse_toml_file(paths.local_config)
  if not config_cache then
    config_cache = parse_toml_file(paths.repo_config)
  end

  config_loaded = true
  return config_cache
end

-- Parse environment variable as boolean
local function parse_env_bool(value)
  if not value then
    return nil
  end
  value = value:lower()
  if value == "1" or value == "true" or value == "yes" then
    return true
  elseif value == "0" or value == "false" or value == "no" then
    return false
  end
  return nil
end

-- Check if an AI tool is enabled
-- @param tool string: Tool name (e.g., "copilot", "opencode")
-- @return boolean: true if enabled, false otherwise
function M.is_enabled(tool)
  -- 1. Check environment variable (highest priority)
  local env_var = "DOTFILES_AI_" .. tool:upper():gsub("-", "_")
  local env_value = os.getenv(env_var)
  local env_bool = parse_env_bool(env_value)
  if env_bool ~= nil then
    return env_bool
  end

  -- 2. Check config file
  local config = load_config()
  if config and config.tools and config.tools[tool] ~= nil then
    return config.tools[tool] == true
  end

  -- 3. Default: disabled
  return false
end

return M
