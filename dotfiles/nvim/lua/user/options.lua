-- ═══════════════════════════════════════════════════════════════════════
-- General settings
-- ═══════════════════════════════════════════════════════════════════════
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.title = true
vim.opt.background = "dark"
vim.opt.hlsearch = false
vim.opt.clipboard = "unnamedplus"
vim.opt.showmode = false
vim.opt.ruler = false
vim.opt.laststatus = 0
vim.opt.showcmd = false
vim.opt.cmdheight = 0
vim.opt.encoding = "utf-8"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wildmode = "longest,list,full"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.undofile = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 10
vim.opt.mouse = ""
vim.opt.conceallevel = 2

-- Disable automatic commenting on newline
vim.cmd("autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o")
