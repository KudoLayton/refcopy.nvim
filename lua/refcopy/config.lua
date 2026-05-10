local M = {}

local defaults = {
  clipboard_register = "+",
  single_line_format = "{path}#L{line}",
  multi_line_format = "{path}#L{start}-L{end}",
  explorer_format = "{path}",
}

M.options = vim.deepcopy(defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  return M.options
end

function M.get()
  return M.options
end

return M
