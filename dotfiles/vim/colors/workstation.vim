" Neutral dark palette inspired by VS Code Dark+.
set background=dark
highlight clear
if exists('syntax_on')
    syntax reset
endif
let g:colors_name = 'workstation'

highlight Normal       guifg=#d4d4d4 guibg=#1e1e1e ctermfg=188 ctermbg=234
highlight CursorLine   guibg=#252526 ctermbg=235 cterm=NONE
highlight LineNr       guifg=#808080 guibg=#1e1e1e ctermfg=244 ctermbg=234
highlight CursorLineNr guifg=#dcdcaa guibg=#252526 ctermfg=187 ctermbg=235 cterm=bold
highlight Visual       guifg=#d4d4d4 guibg=#252526 ctermfg=188 ctermbg=235
highlight Search       guifg=#1e1e1e guibg=#dcdcaa ctermfg=234 ctermbg=187
highlight IncSearch    guifg=#1e1e1e guibg=#4ec9b0 ctermfg=234 ctermbg=80
highlight StatusLine   guifg=#d4d4d4 guibg=#252526 ctermfg=188 ctermbg=235
highlight StatusLineNC guifg=#808080 guibg=#252526 ctermfg=244 ctermbg=235
highlight VertSplit    guifg=#808080 guibg=#252526 ctermfg=244 ctermbg=235
highlight Pmenu        guifg=#d4d4d4 guibg=#252526 ctermfg=188 ctermbg=235
highlight PmenuSel     guifg=#1e1e1e guibg=#569cd6 ctermfg=234 ctermbg=75
highlight ErrorMsg     guifg=#f44747 guibg=#1e1e1e ctermfg=203 ctermbg=234

highlight Comment      guifg=#6a9955 ctermfg=65
highlight Constant     guifg=#4ec9b0 ctermfg=80
highlight String       guifg=#4ec9b0 ctermfg=80
highlight Identifier   guifg=#d4d4d4 ctermfg=188
highlight Function     guifg=#dcdcaa ctermfg=187
highlight Statement    guifg=#c586c0 ctermfg=176
highlight PreProc      guifg=#c586c0 ctermfg=176
highlight Type         guifg=#569cd6 ctermfg=75
highlight Special      guifg=#dcdcaa ctermfg=187
highlight Error        guifg=#f44747 guibg=#1e1e1e ctermfg=203 ctermbg=234

highlight link Boolean Constant
highlight link Number Constant
highlight link Float Constant
highlight link Keyword Statement
highlight link Conditional Statement
highlight link Repeat Statement
