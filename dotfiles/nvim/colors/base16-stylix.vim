" Catppuccin Mocha — base16 colourscheme
highlight clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = 'catppuccin-mocha'

" Terminal colours
let g:terminal_ansi_colors = [
      \ '#1e1e2e', '#f38ba8', '#a6e3a1', '#f9e2af',
      \ '#89b4fa', '#cba6f7', '#94e2d5', '#cdd6f4',
      \ '#6c7086', '#f38ba8', '#a6e3a1', '#f9e2af',
      \ '#89b4fa', '#cba6f7', '#94e2d5', '#b4befe'
      \ ]

" Normal
exe 'hi Normal       guifg=#cdd6f4 guibg=#1e1e2e'
exe 'hi Cursor       guifg=#1e1e2e guibg=#cdd6f4'
exe 'hi LineNr       guifg=#6c7086 guibg=NONE'
exe 'hi CursorLineNr guifg=#a6adc8 guibg=NONE'
exe 'hi CursorLine   guibg=#313244'
exe 'hi ColorColumn  guibg=#313244'
exe 'hi FoldColumn   guifg=#6c7086 guibg=NONE'
exe 'hi Folded       guifg=#6c7086 guibg=#313244'
exe 'hi SignColumn   guifg=#6c7086 guibg=NONE'
exe 'hi VertSplit    guifg=#45475a guibg=NONE'
exe 'hi StatusLine   guifg=#cdd6f4 guibg=#45475a'
exe 'hi StatusLineNC guifg=#6c7086 guibg=#313244'
exe 'hi TabLine      guifg=#6c7086 guibg=#313244'
exe 'hi TabLineFill  guibg=#313244'
exe 'hi TabLineSel   guifg=#cdd6f4 guibg=#1e1e2e'
exe 'hi Pmenu        guifg=#cdd6f4 guibg=#313244'
exe 'hi PmenuSel     guifg=#cdd6f4 guibg=#45475a'
exe 'hi PmenuSbar    guibg=#45475a'
exe 'hi PmenuThumb   guibg=#a6adc8'
exe 'hi WildMenu     guifg=#cdd6f4 guibg=#45475a'
exe 'hi Visual       guibg=#45475a'
exe 'hi Search       guifg=#1e1e2e guibg=#f9e2af'
exe 'hi IncSearch    guifg=#1e1e2e guibg=#a6e3a1'
exe 'hi MatchParen   guifg=#f38ba8 guibg=NONE'
exe 'hi NonText      guifg=#6c7086'
exe 'hi SpecialKey   guifg=#6c7086'
exe 'hi Directory    guifg=#89b4fa'
exe 'hi Title        guifg=#89b4fa'
exe 'hi ErrorMsg     guifg=#f38ba8 guibg=NONE'
exe 'hi WarningMsg   guifg=#fab387'
exe 'hi ModeMsg      guifg=#cdd6f4'
exe 'hi MoreMsg      guifg=#89b4fa'
exe 'hi Question     guifg=#89b4fa'
exe 'hi EndOfBuffer  guifg=#313244'

" Diff
exe 'hi DiffAdd      guibg=#a6e3a1 guifg=#1e1e2e'
exe 'hi DiffChange   guibg=#f9e2af guifg=#1e1e2e'
exe 'hi DiffDelete   guibg=#f38ba8 guifg=#1e1e2e'
exe 'hi DiffText     guibg=#89b4fa guifg=#1e1e2e'

" Spelling
exe 'hi SpellBad     guisp=#f38ba8 gui=undercurl'
exe 'hi SpellCap     guisp=#89b4fa gui=undercurl'
exe 'hi SpellRare    guisp=#cba6f7 gui=undercurl'
exe 'hi SpellLocal   guisp=#94e2d5 gui=undercurl'

" Syntax
exe 'hi Comment      guifg=#6c7086 gui=italic'
exe 'hi Constant     guifg=#fab387'
exe 'hi String       guifg=#a6e3a1'
exe 'hi Character    guifg=#a6e3a1'
exe 'hi Number       guifg=#fab387'
exe 'hi Boolean      guifg=#fab387'
exe 'hi Float        guifg=#fab387'
exe 'hi Identifier   guifg=#f38ba8'
exe 'hi Function     guifg=#89b4fa'
exe 'hi Statement    guifg=#cba6f7'
exe 'hi Conditional  guifg=#cba6f7'
exe 'hi Repeat       guifg=#cba6f7'
exe 'hi Label        guifg=#cba6f7'
exe 'hi Operator     guifg=#94e2d5'
exe 'hi Keyword      guifg=#cba6f7'
exe 'hi Exception    guifg=#f38ba8'
exe 'hi PreProc      guifg=#f9e2af'
exe 'hi Include      guifg=#89b4fa'
exe 'hi Define       guifg=#cba6f7'
exe 'hi Macro        guifg=#89b4fa'
exe 'hi PreCondit    guifg=#94e2d5'
exe 'hi Type         guifg=#f9e2af'
exe 'hi StorageClass guifg=#f9e2af'
exe 'hi Structure    guifg=#f9e2af'
exe 'hi Typedef      guifg=#f9e2af'
exe 'hi Special      guifg=#94e2d5'
exe 'hi SpecialChar  guifg=#94e2d5'
exe 'hi Tag          guifg=#f38ba8'
exe 'hi Delimiter    guifg=#cdd6f4'
exe 'hi SpecialComment guifg=#6c7086'
exe 'hi Debug        guifg=#f38ba8'
exe 'hi Underlined   gui=underline'
exe 'hi Ignore       guifg=#313244'
exe 'hi Error        guifg=#f38ba8 guibg=NONE'
exe 'hi Todo         guifg=#cba6f7 guibg=NONE'
