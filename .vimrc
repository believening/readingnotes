autocmd BufWritePost $MYVIMRC source $MYVIMRC

"""""""""""""""""""""""""""""""""""""""
" common config
"""""""""""""""""""""""""""""""""""""""
" indents and tab
set shiftwidth=4     " 一个缩进的宽度
set expandtab        " 使用空格展开 tab 键
set softtabstop=4    " tab 键被展开的
set autoindent       " 自动缩进
set smartindent      " 智能缩进

" line and column
set number            " 设置行号 'nu'
set cursorline        " 设置所在行高亮 'cul'
set colorcolumn=81    " 设置高亮 81 列 'cc'
highlight ColorColumn ctermbg=black  ctermfg=white

" others
set ignorecase
set incsearch
set hlsearch
set nocompatible
set backspace=indent,eol,start

syntax on
filetype plugin on

"""""""""""""""""""""""""""""""""""""""
" installed plugins
"""""""""""""""""""""""""""""""""""""""
" Specify a directory for plugins managed by vim-plug
call plug#begin('~/.vim/plugged')

" nerdtree and related
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jistr/vim-nerdtree-tabs'

" fuzzy find
Plug 'ctrlpvim/ctrlp.vim'

" tagbar
Plug 'majutsushi/tagbar'

" statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" golang
Plug 'fatih/vim-go' ", { 'do': ':GoUpdateBinaries' }
Plug 'mdempsky/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }

" Initialize plugin system
call plug#end()


"""""""""""""""""""""""""""""""""""""""
" nerdtree config
"""""""""""""""""""""""""""""""""""""""
map <F10> :NERDTreeToggle<CR>

" nerdtree
let NERDTreeShowLineNumbers=1     " 显示行号
let NERDTreeAutoCenter=1          " 打开文件时是否显示目录
let NERDTreeShowHidden=1          " 显示隐藏文件
let NERDTreeIgnore=['\.swp']      " 忽略文件

" vim-nerdtree-tabs
let g:nerdtree_tabs_open_on_console_startup=1

" nerdtree-git-plugin
let g:NERDTreeIndicatorMapCustom={
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }
"let g:NERDTreeShowIgnoredStatus=1    " show ignored status

"""""""""""""""""""""""""""""""""""""""
" tagbar config
"""""""""""""""""""""""""""""""""""""""
map <F9> :TagbarToggle<CR>
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
    \ }

"""""""""""""""""""""""""""""""""""""""
" airline config
"""""""""""""""""""""""""""""""""""""""
let g:airline_theme='base16_tomorrow'

"""""""""""""""""""""""""""""""""""""""
" vim-go config
"""""""""""""""""""""""""""""""""""""""
let g:go_fmt_command="goimports"
let g:go_autodetect_gopath=1
let g:go_list_type="quickfix"

let g:go_version_warning=1
let g:go_highlight_types=1
let g:go_highlight_fields=1
let g:go_highlight_functions=1
let g:go_highlight_function_calls=1
let g:go_highlight_operators=1
let g:go_highlight_extra_types=1
let g:go_highlight_methods=1
let g:go_highlight_generate_tags=1

let g:go_auto_type_info=1

imap <F2> <C-x><C-o>
