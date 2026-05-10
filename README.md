# refcopy.nvim

Copy file references and explorer paths from visual selections into the system clipboard.

## Features

- `:'<,'>RefCopy` copies the current visual selection. In file buffers it copies a file reference; in supported explorer buffers it copies selected paths.
- `:'<,'>RefCopyAbsolute` does the same with absolute paths.
- `:'<,'>RefCopyExplorer` explicitly copies selected paths from `netrw` or `oil.nvim`.
- `:'<,'>RefCopyExplorerAbsolute` explicitly copies absolute explorer paths.
- Formats are configurable with simple `{token}` placeholders.

## Default Output

The default single-line file format is:

```text
{path}#L{line}
```

For a single selected line, the default output is:

```text
lua/refcopy/init.lua#L24
```

The default multi-line file format is:

```text
{path}#L{start}-L{end}
```

For a multi-line visual selection, the default output is:

```text
lua/refcopy/init.lua#L24-L31
```

In `netrw` and `oil.nvim` buffers, `RefCopy` copies one selected entry per line. The default explorer format is:

```text
{path}
```

If you prefer a different shape, configure the single-line, multi-line, and explorer formats directly:

```lua
require("refcopy").setup({
  single_line_format = "{path}:{line}",
  multi_line_format = "{path}:{start}-{end}",
  explorer_format = '"{path}"',
})
```

## Configuration

```lua
require("refcopy").setup({
  clipboard_register = "+",
  single_line_format = "{path}#L{line}",
  multi_line_format = "{path}#L{start}-L{end}",
  explorer_format = "{path}",
})
```

The placeholder syntax is defined by this plugin. It is simple string replacement, not Lua evaluation.

File formats support `{path}`, `{line}`, `{start}`, `{end}`, and `{cwd}`.
Explorer formats support `{path}`, `{name}`, and `{cwd}`.

## lazy.nvim Keymaps

```lua
{
  "KudoLayton/refcopy.nvim",
  main = "refcopy",
  opts = {},
  keys = {
    { "<leader>ry", ":RefCopy<CR>", mode = "x", desc = "Copy file reference" },
    { "<leader>rY", ":RefCopyAbsolute<CR>", mode = "x", desc = "Copy absolute reference" },
  },
}
```

To configure it:

```lua
{
  "KudoLayton/refcopy.nvim",
  main = "refcopy",
  opts = {
    single_line_format = "{path}#L{line}",
    multi_line_format = "{path}#L{start}-L{end}",
    explorer_format = "{path}",
  },
}
```

## Notes

- Relative paths are calculated from `vim.fn.getcwd()`.
- Path separators are not normalized; Neovim and the OS decide the path shape.
- `oil.nvim` support is optional. If it is not installed, file buffer and netrw copying still work.
