if vim.g.loaded_refcopy_nvim then
  return
end
vim.g.loaded_refcopy_nvim = true

require("refcopy").setup()
