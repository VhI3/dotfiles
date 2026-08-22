-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local ok_dap, dap = pcall(require, "dap")
local ok_dapui, dapui = pcall(require, "dapui")

if ok_dap and ok_dapui then
  local function del(mode, lhs)
    pcall(vim.keymap.del, mode, lhs)
  end

  -- Optional: remove the old LazyVim debug keys.
  del("n", "<leader>dc")
  del("n", "<leader>dO")
  del("n", "<leader>di")
  del("n", "<leader>do")
  del("n", "<leader>db")
  del("n", "<leader>dt")
  del("n", "<leader>du")

  -- Simple IDE-like debugging keys.
  vim.keymap.set("n", "<F5>", function()
    dap.continue()
  end, { desc = "Debug: Start/Continue" })

  vim.keymap.set("n", "<F9>", function()
    dap.toggle_breakpoint()
  end, { desc = "Debug: Toggle Breakpoint" })

  vim.keymap.set("n", "<F10>", function()
    dap.step_over()
  end, { desc = "Debug: Step Over" })

  vim.keymap.set("n", "<F11>", function()
    dap.step_into()
  end, { desc = "Debug: Step Into" })

  vim.keymap.set("n", "<S-F11>", function()
    dap.step_out()
  end, { desc = "Debug: Step Out" })

  vim.keymap.set("n", "<S-F5>", function()
    dap.terminate()
  end, { desc = "Debug: Stop" })

  vim.keymap.set("n", "<F7>", function()
    dapui.toggle({})
  end, { desc = "Debug: Toggle UI" })
end
