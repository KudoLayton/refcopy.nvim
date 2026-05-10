vim.opt.runtimepath:prepend(vim.fn.getcwd())

local refcopy = require("refcopy")

local function assert_eq(actual, expected, label)
  if actual ~= expected then
    error(("%s\nexpected: %s\nactual:   %s"):format(label, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function assert_contains(value, needle, label)
  if not value:find(needle, 1, true) then
    error(("%s\nexpected %s to contain %s"):format(label, vim.inspect(value), vim.inspect(needle)))
  end
end

refcopy.setup({
  clipboard_register = '"',
  default_format = "default",
  default_explorer_format = "default",
  formats = {
    default = "{path}:{line}",
    custom = "[{path}] {start}/{end}",
  },
  explorer_formats = {
    default = "{path}",
    named = "{name} => {path}",
  },
})

vim.cmd("edit README.md")
vim.cmd("2,4RefCopy")
assert_contains(vim.fn.getreg('"'), "README.md:2-4", "RefCopy should copy relative path and line range")

vim.cmd("2,4RefCopy custom")
assert_contains(vim.fn.getreg('"'), "[README.md] 2/4", "RefCopy should use requested named format")

local netrw_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(netrw_buf)
vim.bo[netrw_buf].filetype = "netrw"
vim.api.nvim_buf_set_var(netrw_buf, "netrw_curdir", vim.fn.getcwd())
vim.api.nvim_buf_set_lines(netrw_buf, 0, -1, false, {
  '" Netrw Directory Listing',
  "README.md",
  "lua/",
})

vim.cmd("2,3RefCopyExplorer named")
local explorer_result = vim.fn.getreg('"')
assert_contains(explorer_result, "README.md =>", "RefCopyExplorer should include file name token")
assert_contains(explorer_result, "lua =>", "RefCopyExplorer should strip netrw directory marker")

package.loaded.oil = nil
vim.bo[netrw_buf].filetype = "oil"
local ok = refcopy.copy_explorer({ bufnr = netrw_buf, line1 = 1, line2 = 1 })
assert_eq(ok, false, "oil buffer should fail cleanly when oil.nvim is unavailable")

print("refcopy.nvim smoke tests passed")
