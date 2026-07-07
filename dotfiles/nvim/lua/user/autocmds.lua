local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local user_group = augroup("UserAutocmds", { clear = true })

-- NERDTree: close if last window
autocmd("BufEnter", {
  group = user_group,
  callback = function()
    if vim.fn.winnr("$") == 1 and vim.bo.filetype == "nerdtree" then
      vim.cmd("q")
    end
  end,
})

-- LaTeX: auto-commit on save (if in a git repo)
autocmd("BufWritePost", {
  group = user_group,
  pattern = "*.tex",
  callback = function()
    local dir = vim.fn.expand("%:p:h")
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      vim.fn.system("cd " .. vim.fn.shellescape(dir)
        .. " && git add -A && git commit -m 'tex: " .. vim.fn.expand("%:t") .. "' 2>&1 &")
    end
  end,
})

-- LaTeX: clean aux files on close
autocmd("VimLeave", {
  group = user_group,
  pattern = "*.tex",
  command = "!latexmk -c %",
})

-- Filetype detection
autocmd({ "BufRead", "BufNewFile" }, {
  group = user_group,
  pattern = { "/tmp/calcurse*", "~/.calcurse/notes/*" },
  command = "set filetype=markdown",
})
autocmd({ "BufRead", "BufNewFile" }, {
  group = user_group,
  pattern = { "*.ms", "*.me", "*.mom", "*.man" },
  command = "set filetype=groff",
})
autocmd({ "BufRead", "BufNewFile" }, {
  group = user_group,
  pattern = "*.tex",
  command = "set filetype=tex",
})

-- LaTeX: disable auto-indent
autocmd("FileType", {
  group = user_group,
  pattern = "tex",
  callback = function()
    vim.bo.indentexpr = ""
    vim.bo.autoindent = false
    vim.bo.smartindent = false
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "+1"
  end,
})

-- Trailing whitespace cleanup
autocmd("BufWritePre", {
  group = user_group,
  pattern = "*",
  callback = function()
    local pos = vim.fn.getpos(".")
    vim.cmd("%s/\\s\\+$//e")
    vim.cmd("%s/\\n\\+\\%$//e")
    vim.fn.cursor(pos[2], pos[3])
  end,
})

-- C files: trailing newline
autocmd("BufWritePre", {
  group = user_group,
  pattern = "*.[ch]",
  command = "%s/\\%$/\\r/e",
})

-- Shortcut generation
autocmd("BufWritePost", {
  group = user_group,
  pattern = { "bm-files", "bm-dirs" },
  command = "!shortcuts",
})

-- Diff highlighting
vim.cmd([[
  if &diff
      highlight! link DiffText MatchParen
  endif
]])

-- Source shortcuts file
vim.cmd("silent! source ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/shortcuts.vim")

-- sudo write
vim.cmd("cabbrev w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!")
