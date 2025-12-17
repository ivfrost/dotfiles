-- Leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- General options
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.autoread = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

-- Toggle nerdtree with Alt+z
vim.keymap.set('n', '<M-z>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })

