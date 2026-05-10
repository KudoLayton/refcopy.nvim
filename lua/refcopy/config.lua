local M = {}

local defaults = {
  clipboard_register = "+",
  default_format = "default",
  default_explorer_format = "default",
  formats = {
    default = "{path}:{line}",
  },
  explorer_formats = {
    default = "{path}",
  },
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
