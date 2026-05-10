local config = require("refcopy.config")
local format = require("refcopy.format")
local sources = require("refcopy.sources")

local M = {}

local function notify_error(message)
  vim.notify(message, vim.log.levels.ERROR)
end

local function copy_to_clipboard(text)
  vim.fn.setreg(config.get().clipboard_register, text)
end

local function file_template(options, line1, line2)
  if line1 == line2 then
    return options.single_line_format
  end
  return options.multi_line_format
end

function M.copy_file(opts)
  opts = opts or {}
  local options = config.get()

  local tokens
  local line1 = opts.line1 or vim.fn.line(".")
  local line2 = opts.line2 or vim.fn.line(".")
  local err
  tokens, err = sources.file(opts.bufnr or 0, line1, line2, opts.absolute)
  if err then
    notify_error(err)
    return false
  end

  local template = file_template(options, tokens.start, tokens["end"])
  local text = format.render(template, tokens)
  copy_to_clipboard(text)
  vim.notify("refcopy.nvim: copied 1 reference")
  return true
end

function M.copy_explorer(opts)
  opts = opts or {}
  local options = config.get()
  local template = options.explorer_format

  local items
  local err
  items, err = sources.explorer(opts.bufnr or 0, opts.line1 or vim.fn.line("."), opts.line2 or vim.fn.line("."), opts.absolute)
  if err then
    notify_error(err)
    return false
  end
  if #items == 0 then
    notify_error("refcopy.nvim: no explorer entries selected")
    return false
  end

  local lines = {}
  for _, item in ipairs(items) do
    table.insert(lines, format.render(template, item))
  end

  copy_to_clipboard(table.concat(lines, "\n"))
  vim.notify(("refcopy.nvim: copied %d paths"):format(#lines))
  return true
end

function M.copy(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or 0
  if sources.is_explorer(bufnr) then
    return M.copy_explorer(opts)
  end
  return M.copy_file(opts)
end

local function create_commands()
  vim.api.nvim_create_user_command("RefCopy", function(args)
    M.copy({
      line1 = args.line1,
      line2 = args.line2,
      absolute = false,
    })
  end, { range = true, nargs = 0 })

  vim.api.nvim_create_user_command("RefCopyAbsolute", function(args)
    M.copy({
      line1 = args.line1,
      line2 = args.line2,
      absolute = true,
    })
  end, { range = true, nargs = 0 })

  vim.api.nvim_create_user_command("RefCopyExplorer", function(args)
    M.copy_explorer({
      line1 = args.line1,
      line2 = args.line2,
      absolute = false,
    })
  end, { range = true, nargs = 0 })

  vim.api.nvim_create_user_command("RefCopyExplorerAbsolute", function(args)
    M.copy_explorer({
      line1 = args.line1,
      line2 = args.line2,
      absolute = true,
    })
  end, { range = true, nargs = 0 })
end

function M.setup(opts)
  config.setup(opts)
  create_commands()
end

return M
