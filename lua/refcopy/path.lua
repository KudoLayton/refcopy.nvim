local M = {}

local sep = package.config:sub(1, 1)

local function strip_trailing_separator(path)
  while #path > 1 and (path:sub(-1) == "/" or path:sub(-1) == "\\") do
    path = path:sub(1, -2)
  end
  return path
end

local function separator_for(path)
  if path:find("/", 1, true) then
    return "/"
  end
  if path:find("\\", 1, true) then
    return "\\"
  end
  return sep
end

function M.cwd()
  return strip_trailing_separator(vim.fn.getcwd())
end

function M.absolute(path)
  return strip_trailing_separator(vim.fn.fnamemodify(path, ":p"))
end

function M.relative(path, cwd)
  cwd = strip_trailing_separator(cwd or M.cwd())
  local absolute = M.absolute(path)
  local cwd_lower = cwd:lower()
  local absolute_lower = absolute:lower()

  if absolute_lower == cwd_lower then
    return "."
  end

  local prefix_slash = cwd_lower .. "/"
  local prefix_backslash = cwd_lower .. "\\"
  if absolute_lower:sub(1, #prefix_slash) == prefix_slash then
    return absolute:sub(#prefix_slash + 1)
  end
  if absolute_lower:sub(1, #prefix_backslash) == prefix_backslash then
    return absolute:sub(#prefix_backslash + 1)
  end

  return absolute
end

function M.join(dir, name)
  dir = strip_trailing_separator(dir)
  if dir == "" then
    return name
  end
  return dir .. separator_for(dir) .. name
end

function M.display(path, absolute)
  if absolute then
    return M.absolute(path)
  end
  return M.relative(path)
end

return M
