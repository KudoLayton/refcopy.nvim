# refcopy.nvim

Copy file references and explorer paths from visual selections into the system clipboard.

## Features

- `:'<,'>RefCopy` copies the current file path and selected line range.
- `:'<,'>RefCopyAbsolute` uses an absolute file path.
- `:'<,'>RefCopyExplorer` copies selected paths from `netrw` or `oil.nvim`.
- `:'<,'>RefCopyExplorerAbsolute` uses absolute explorer paths.
- Formats are configurable with simple `{token}` placeholders.

## Configuration

```lua
require("refcopy").setup({
  clipboard_register = "+",
  default_format = "default",
  default_explorer_format = "default",
  formats = {
    default = "{path}:{line}",
    github = "{path}#L{start}-L{end}",
  },
  explorer_formats = {
    default = "{path}",
    quoted = '"{path}"',
  },
})
```

The placeholder syntax is defined by this plugin. It is simple string replacement, not Lua evaluation.

File formats support `{path}`, `{line}`, `{start}`, `{end}`, and `{cwd}`.
Explorer formats support `{path}`, `{name}`, and `{cwd}`.

## lazy.nvim Keymaps

```lua
{
  dir = "~/path/to/refcopy.nvim",
  config = function()
    require("refcopy").setup()
  end,
  keys = {
    { "<leader>ry", ":RefCopy<CR>", mode = "x", desc = "Copy file reference" },
    { "<leader>rY", ":RefCopyAbsolute<CR>", mode = "x", desc = "Copy absolute file reference" },
    { "<leader>re", ":RefCopyExplorer<CR>", mode = "x", desc = "Copy explorer paths" },
    { "<leader>rE", ":RefCopyExplorerAbsolute<CR>", mode = "x", desc = "Copy absolute explorer paths" },
  },
}
```

To use a named format for one mapping:

```lua
{ "<leader>rg", ":RefCopy github<CR>", mode = "x", desc = "Copy GitHub-style reference" }
```

## Notes

- Relative paths are calculated from `vim.fn.getcwd()`.
- Path separators are not normalized; Neovim and the OS decide the path shape.
- `oil.nvim` support is optional. If it is not installed, file buffer and netrw copying still work.
