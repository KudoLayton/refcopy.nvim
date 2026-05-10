local path = require("refcopy.path")

local M = {}

local function get_buf_var(bufnr, name)
  local ok, value = pcall(vim.api.nvim_buf_get_var, bufnr, name)
  if ok then
    return value
  end
  return nil
end

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function clean_netrw_name(line)
  local name = trim(line)
  if name == "" then
    return nil
  end
  if name:sub(1, 1) == '"' or name:match("^=+$") or name:match("^%.%./?$") then
    return nil
  end
  if name:match("^Sorted by ") or name:match("^Quick Help:") or name:match("^Hiding:") then
    return nil
  end

  name = name:gsub("%s+$", "")
  name = name:gsub("[/@*=|]$", "")
  if name == "." or name == ".." or name == "" then
    return nil
  end

  return name
end

function M.file(bufnr, line1, line2, absolute)
  bufnr = bufnr or 0
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return nil, "refcopy.nvim: current buffer has no file path"
  end

  local start_line = math.min(line1, line2)
  local end_line = math.max(line1, line2)
  local line = tostring(start_line)
  if start_line ~= end_line then
    line = ("%d-%d"):format(start_line, end_line)
  end

  return {
    path = path.display(name, absolute),
    line = line,
    start = start_line,
    ["end"] = end_line,
    cwd = path.cwd(),
  }
end

function M.oil(bufnr, line1, line2, absolute)
  local ok, oil = pcall(require, "oil")
  if not ok then
    return nil, "refcopy.nvim: oil.nvim is not available"
  end
  if type(oil.get_current_dir) ~= "function" or type(oil.get_entry_on_line) ~= "function" then
    return nil, "refcopy.nvim: installed oil.nvim does not expose the required API"
  end

  local dir = oil.get_current_dir(bufnr)
  if not dir then
    return nil, "refcopy.nvim: cannot determine oil directory"
  end

  local items = {}
  for lnum = math.min(line1, line2), math.max(line1, line2) do
    local entry = oil.get_entry_on_line(bufnr, lnum)
    local name = entry and entry.name
    if name and name ~= "" and name ~= "." and name ~= ".." then
      local full_path = path.join(dir, name)
      table.insert(items, {
        path = path.display(full_path, absolute),
        name = name,
        cwd = path.cwd(),
      })
    end
  end

  return items
end

function M.netrw(bufnr, line1, line2, absolute)
  local dir = get_buf_var(bufnr, "netrw_curdir")
  if not dir or dir == "" then
    return nil, "refcopy.nvim: cannot determine netrw directory"
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, math.min(line1, line2) - 1, math.max(line1, line2), false)
  local items = {}
  for _, line in ipairs(lines) do
    local name = clean_netrw_name(line)
    if name then
      local full_path = path.join(dir, name)
      table.insert(items, {
        path = path.display(full_path, absolute),
        name = name,
        cwd = path.cwd(),
      })
    end
  end

  return items
end

function M.explorer(bufnr, line1, line2, absolute)
  bufnr = bufnr or 0
  local filetype = vim.bo[bufnr].filetype
  if filetype == "oil" then
    return M.oil(bufnr, line1, line2, absolute)
  end
  if filetype == "netrw" then
    return M.netrw(bufnr, line1, line2, absolute)
  end
  return nil, ("refcopy.nvim: unsupported explorer buffer type '%s'"):format(filetype)
end

function M.is_explorer(bufnr)
  bufnr = bufnr or 0
  local filetype = vim.bo[bufnr].filetype
  return filetype == "oil" or filetype == "netrw"
end

return M
