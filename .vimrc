execute pathogen#infect()
syntax on
filetype plugin indent on
set backspace=2
" set auto-indenting on for programming
set ai

" automatically show matching brackets. works like it does in bbedit.
set showmatch

" show line numbers
set number

" do NOT put a carriage return at the end of the last line! if you are programming
" for the web the default will cause http headers to be sent. that's bad.
set binary noeol

" 2 spaces = tab, auto-intent new block scopes, make backspace not stupid
set smartindent
set tabstop=2
set shiftwidth=2
set expandtab
set softtabstop=2
set nofoldenable
set colorcolumn=100

" show tabs and other non-printable characters all the time
"set list

augroup markdown
    au! BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

autocmd BufNewFile,BufRead *.json set ft=json

augroup filetype
    au! BufRead,BufNewFile *.ll     set filetype=llvm
augroup END

let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
let g:EclimJavascriptLintEnabled = 0
let g:EclimJavascriptValidate = 0 
let g:EclimCompletionMethod = 'omnifunc'

let g:vim_json_syntax_conceal = 0
let &t_Co=256
hi SpellBad    ctermfg=015      ctermbg=052     cterm=none

au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set ft=glsl

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exec = '~/cardash/cardash/node_modules/.bin/eslint'
