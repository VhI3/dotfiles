return {
  "Exafunction/codeium.vim",
  event = "BufEnter",
  keys = {
    { "<leader>at", "<cmd>CodeiumToggle<cr>", desc = "Toggle Codeium" },
    {
      "<C-g>",
      function() return vim.fn["codeium#Accept"]() end,
      mode = "i",
      expr = true,
      silent = true,
      desc = "Codeium: accept suggestion",
    },
    {
      "<C-l>",
      function() return vim.fn["codeium#CycleCompletions"](1) end,
      mode = "i",
      expr = true,
      silent = true,
      desc = "Codeium: next suggestion",
    },
    {
      "<C-j>",
      function() return vim.fn["codeium#CycleCompletions"](-1) end,
      mode = "i",
      expr = true,
      silent = true,
      desc = "Codeium: prev suggestion",
    },
    {
      "<C-x>",
      function() return vim.fn["codeium#Clear"]() end,
      mode = "i",
      expr = true,
      silent = true,
      desc = "Codeium: dismiss suggestion",
    },
  },
}
