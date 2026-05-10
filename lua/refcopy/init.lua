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

local function complete_file_formats()
  return vim.tbl_keys(config.get().formats or {})
end

local function complete_explorer_formats()
  return vim.tbl_keys(config.get().explorer_formats or {})
end

function M.copy_file(opts)
  opts = opts or {}
  local options = config.get()
  local template, err = format.resolve(options.formats, options.default_format, opts.format)
  if err then
    notify_error(err)
    return false
  end

  local tokens
  tokens, err = sources.file(opts.bufnr or 0, opts.line1 or vim.fn.line("."), opts.line2 or vim.fn.line("."), opts.absolute)
  if err then
    notify_error(err)
    return false
  end

  local text = format.render(template, tokens)
  copy_to_clipboard(text)
  vim.notify("refcopy.nvim: copied 1 reference")
  return true
end

function M.copy_explorer(opts)
  opts = opts or {}
  local options = config.get()
  local template, err = format.resolve(options.explorer_formats, options.default_explorer_format, opts.format)
  if err then
    notify_error(err)
    return false
  end

  local items
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

local function create_commands()
  vim.api.nvim_create_user_command("RefCopy", function(args)
    M.copy_file({
      line1 = args.line1,
      line2 = args.line2,
      format = args.args,
      absolute = false,
    })
  end, { range = true, nargs = "?", complete = complete_file_formats })

  vim.api.nvim_create_user_command("RefCopyAbsolute", function(args)
    M.copy_file({
      line1 = args.line1,
      line2 = args.line2,
      format = args.args,
      absolute = true,
    })
  end, { range = true, nargs = "?", complete = complete_file_formats })

  vim.api.nvim_create_user_command("RefCopyExplorer", function(args)
    M.copy_explorer({
      line1 = args.line1,
      line2 = args.line2,
      format = args.args,
      absolute = false,
    })
  end, { range = true, nargs = "?", complete = complete_explorer_formats })

  vim.api.nvim_create_user_command("RefCopyExplorerAbsolute", function(args)
    M.copy_explorer({
      line1 = args.line1,
      line2 = args.line2,
      format = args.args,
      absolute = true,
    })
  end, { range = true, nargs = "?", complete = complete_explorer_formats })
end

function M.setup(opts)
  config.setup(opts)
  create_commands()
end

return M
