-- ═══════════════════════════════════════════════════════════════════════
-- Bootstrap lazy.nvim
-- ═══════════════════════════════════════════════════════════════════════
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ═══════════════════════════════════════════════════════════════════════
-- Load configuration modules
-- ═══════════════════════════════════════════════════════════════════════
require("user.options")
require("user.keymaps")
require("user.autocmds")
require("lazy").setup("user.plugins")

-- Colourscheme is set by the catppuccin/nvim plugin (see lua/user/plugins.lua).
-- Catppuccin Mocha with transparent_background=false provides solid #1e1e2e bg.
