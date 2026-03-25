local M = {}

local defaults = {
  flavour = "mocha",
  colorscheme = "catppuccin",
}

function M.current()
  local ok, local_theme = pcall(require, "config.theme_local")
  if not ok then
    local legacy_path = vim.fn.stdpath("config") .. "/lua/config/theme.local.lua"
    local loader = loadfile(legacy_path)
    if loader then
      local loaded = loader()
      if type(loaded) == "table" then
        local_theme = loaded
        ok = true
      end
    end
  end

  if ok and type(local_theme) == "table" then
    return vim.tbl_deep_extend("force", vim.deepcopy(defaults), local_theme)
  end

  return vim.deepcopy(defaults)
end

return M
