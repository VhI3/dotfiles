local theme = require("config.theme").current()

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = theme.flavour,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = theme.colorscheme,
    },
  },
}
