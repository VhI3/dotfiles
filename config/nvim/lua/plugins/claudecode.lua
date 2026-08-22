local function detect_claude_cmd()
  local path = vim.env.CLAUDE_NVIM_CMD
  if path and path ~= "" then
    return path
  end

  if vim.fn.executable("claude") == 1 then
    return "claude"
  end

  local local_cmd = vim.fn.expand("~/.claude/local/claude")
  if vim.fn.executable(local_cmd) == 1 then
    return local_cmd
  end

  return nil
end

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  init = function()
    vim.api.nvim_create_user_command("ClaudeCodeHistory", function()
      local ok, lazy = pcall(require, "lazy")
      if ok then
        lazy.load({ plugins = { "claudecode.nvim" } })
      end
      require("config.claude_history").pick()
    end, { desc = "Resume Claude Code session from history" })
  end,
  opts = function()
    local opts = {
      focus_after_send = true,
      git_repo_cwd = true,
    }

    local terminal_cmd = detect_claude_cmd()
    if terminal_cmd then
      opts.terminal_cmd = terminal_cmd
    end

    return opts
  end,
  config = true,
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    {
      "<leader>ah",
      function()
        require("config.claude_history").pick()
      end,
      desc = "Claude history",
    },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },

    {
      "<leader>ae",
      function()
        require("config.claude_helpers").send_selection_with_prompt([[
Explain the selected code like a senior engineer teaching me.
Cover:
1. what it does
2. how it works step by step
3. inputs and outputs
4. assumptions and edge cases
5. anything confusing or risky

Be concise but clear.
]])
      end,
      mode = "v",
      desc = "Explain selection",
    },
    {
      "<leader>av",
      function()
        require("config.claude_helpers").send_selection_with_prompt([[
Review the selected code.
Focus on:
1. bugs
2. risky assumptions
3. edge cases
4. readability problems
5. performance issues if relevant

Give the most important issues first.
Do not rewrite the code unless necessary.
]])
      end,
      mode = "v",
      desc = "Review selection",
    },

    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },

    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
