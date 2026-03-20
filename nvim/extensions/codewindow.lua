-- return {
--   {
--     "lervag/vimtex",
--     lazy = false, -- we don't want to lazy load VimTeX
--     -- tag = "v2.15", -- uncomment to pin to a specific release
--     init = function()
--       -- VimTeX configuration goes here
--       vim.g.vimtex_view_method = "zathura"
--     end,
--   },
-- }

return {
  {
    "gorbit99/codewindow.nvim",
    config = function()
      local codewindow = require("codewindow")
      codewindow.setup()
      codewindow.apply_default_keybinds()
    end,
  },
}
