-- Override Catppuccin's Conceal highlight — it sets guifg matching guibg
-- (#1e1e2e), making vimtex concealed math glyphs invisible.  Use Overlay0
-- gray (#6c7086) so concealed text is visible but visually distinct.
-- This file runs AFTER all plugins via nvim's after/plugin/ mechanism.
vim.cmd("highlight Conceal guifg=#6c7086 guibg=NONE")
