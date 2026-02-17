-- AI Tools Configuration for Neovim
-- Checks which AI tools are enabled via DOTFILES_AI_<TOOL> environment variables
-- set by export_dotfiles_config in shell startup.
--
-- Default: disabled (env var absent or "0")

local M = {}

--- Check if an AI tool is enabled
--- @param tool string Tool name (e.g., "copilot", "opencode")
--- @return boolean
function M.is_enabled(tool)
  local env_var = "DOTFILES_AI_" .. tool:upper():gsub("-", "_")
  return os.getenv(env_var) == "1"
end

return M
