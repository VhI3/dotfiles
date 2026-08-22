local M = {}

local history_path = vim.fn.expand("~/.claude/history.jsonl")

local function shorten(text, max_len)
  text = (text or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  if #text <= max_len then
    return text
  end
  return text:sub(1, max_len - 1) .. "…"
end

local function basename(path)
  if not path or path == "" then
    return ""
  end
  return vim.fs.basename(path)
end

local function format_item(item)
  local when = os.date("%Y-%m-%d %H:%M", math.floor((item.timestamp or 0) / 1000))
  local project = basename(item.project)
  local display = shorten(item.display, 90)
  return string.format("%s  [%s]  %s", when, project ~= "" and project or "no-project", display)
end

local function load_history()
  local file = io.open(history_path, "r")
  if not file then
    return {}
  end

  local sessions = {}
  for line in file:lines() do
    local ok, item = pcall(vim.json.decode, line)
    if ok and item and item.sessionId and item.timestamp then
      local current = sessions[item.sessionId]
      if not current or item.timestamp > current.timestamp then
        sessions[item.sessionId] = {
          session_id = item.sessionId,
          timestamp = item.timestamp,
          project = item.project or "",
          display = item.display or "",
        }
      end
    end
  end
  file:close()

  local items = vim.tbl_values(sessions)
  table.sort(items, function(a, b)
    return (a.timestamp or 0) > (b.timestamp or 0)
  end)

  for _, item in ipairs(items) do
    item.label = format_item(item)
  end

  return items
end

local function resume_item(item)
  if not item then
    return
  end

  if item.project ~= "" and vim.fn.isdirectory(item.project) == 1 then
    vim.cmd("lcd " .. vim.fn.fnameescape(item.project))
  end

  vim.cmd("ClaudeCode --resume " .. item.session_id)
end

function M.pick()
  local items = load_history()
  if vim.tbl_isempty(items) then
    vim.notify("No Claude history found in " .. history_path, vim.log.levels.WARN)
    return
  end

  local ok_fzf, fzf = pcall(require, "fzf-lua")
  if ok_fzf then
    local labels = {}
    local by_label = {}
    for _, item in ipairs(items) do
      table.insert(labels, item.label)
      by_label[item.label] = item
    end

    fzf.fzf_exec(labels, {
      prompt = "Claude History> ",
      actions = {
        ["default"] = function(selected)
          local choice = selected and selected[1]
          if choice then
            resume_item(by_label[choice])
          end
        end,
      },
    })
    return
  end

  vim.ui.select(items, {
    prompt = "Claude History",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    resume_item(choice)
  end)
end

return M
