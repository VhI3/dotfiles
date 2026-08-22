local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO)
end

local function get_terminal()
  local ok, terminal = pcall(require, "claudecode.terminal")
  if not ok then
    notify("Could not load claudecode.terminal", vim.log.levels.ERROR)
    return nil
  end
  return terminal
end

local function get_terminal_bufnr()
  local terminal = get_terminal()
  if not terminal then
    return nil
  end

  -- Ensure the Claude terminal exists without permanently stealing focus.
  terminal.ensure_visible()

  local bufnr = terminal.get_active_terminal_bufnr()
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    notify("Claude terminal buffer not found", vim.log.levels.ERROR)
    return nil
  end

  return bufnr
end

local function send_to_terminal(text)
  local bufnr = get_terminal_bufnr()
  if not bufnr then
    return
  end

  local jobid = vim.b[bufnr].terminal_job_id
  if not jobid then
    notify("Claude terminal job id not found", vim.log.levels.ERROR)
    return
  end

  vim.fn.chansend(jobid, text .. "\n")
end

function M.send_selection_with_prompt(prompt)
  vim.cmd("ClaudeCodeSend")

  vim.defer_fn(function()
    local terminal = get_terminal()
    if not terminal then
      return
    end

    terminal.ensure_visible()
    vim.cmd("ClaudeCodeFocus")

    vim.defer_fn(function()
      send_to_terminal(prompt)
    end, 120)
  end, 120)
end

return M
