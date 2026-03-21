return {
  {
    "jeryldev/pyworks.nvim",
    dependencies = { "benlubas/molten-nvim", "3rd/image.nvim" },
    config = function()
      require("pyworks").setup()
    end,
    lazy = false,
    priority = 100,
  },
}
