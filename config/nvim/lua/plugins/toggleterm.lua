return {
  "akinsho/toggleterm.nvim",
  config = function()
    require("toggleterm").setup({
      direction = "horizontal", -- Options: 'horizontal', 'vertical', 'tab'
      size = 15, -- Height for horizontal terminal (or width for vertical)
      shade_terminals = true, -- Shading for better visibility
      start_in_insert = true, -- Start terminal in insert mode
      persist_size = true, -- Remember terminal size
      close_on_exit = true, -- Close terminal on process exit
    })

    -- Optional: Keybinding to toggle horizontal terminal
    vim.api.nvim_set_keymap(
      "n",
      "<leader>tt",
      "<cmd>ToggleTerm direction=horizontal<CR>",
      { noremap = true, silent = true, desc = "Toggle Terminal (Horizontal)" }
    )
    vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
  end,
}
