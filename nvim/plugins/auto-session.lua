return {
  "rmagatti/auto-session",
  lazy = false,
  config = function()
    require("auto-session").setup({
      bypass_session_save_file_types = { "", "blank", "alpha", "neo-tree", "quickfix" },
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      pre_restore_cmds = { "Neotree close" },
      post_restore_cmds = { "Neotree show", "copen" },
    })
  end,
}
