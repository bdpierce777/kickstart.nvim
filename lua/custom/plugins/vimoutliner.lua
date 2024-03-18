vim.g.mapleader = '\\'
vim.g.maplocalleader = '\\'
print('votl =', vim.g.maplocalleader)
return {
  'vimoutliner/vimoutliner',
  priority = 1000,
  lazy = false,
}
