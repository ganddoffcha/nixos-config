local map = vim.keymap.set

-- Placeholder jump
map({ "n", "i" }, ",,", function()
  vim.cmd("keepp /<++><CR>ca<")
end)

-- Basics
map("n", "c", '"_c')
map("n", "Q", "gq")
map("n", "S", ":%s//g<Left><Left>")
map("v", ".", ":normal .<CR>")

-- Split navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Leader mappings
map("n", "<leader>f", ":Goyo | set bg=light | set linebreak<CR>")
map("n", "<leader>o", ":setlocal spell! spelllang=en_us<CR>")
map("n", "<leader>n", ":NERDTreeToggle<CR>")
map("n", "<leader>s", ":!clear && shellcheck -x %<CR>")
map("n", "<leader>b", ":vsp $BIB<CR>")
map("n", "<leader>r", ":vsp $REFER<CR>")
map("n", "<leader>c", ":w! | !compiler \"%:p\"<CR>")
map("n", "<leader>p", ":!opout \"%:p\"<CR>")
map("n", "<leader>v", ":VimwikiIndex<CR>")
map("n", "<leader>h", ":call ToggleHiddenAll()<CR>")

-- Toggle hidden (statusbar)
vim.cmd([[
  let s:hidden_all = 0
  function! ToggleHiddenAll()
      if s:hidden_all == 0
          let s:hidden_all = 1
          set noshowmode
          set noruler
          set laststatus=0
          set noshowcmd
      else
          let s:hidden_all = 0
          set showmode
          set ruler
          set laststatus=2
          set showcmd
      endif
  endfunction
]])
