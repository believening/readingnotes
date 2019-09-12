autocmd BufWritePost $MYVIMRC source $MYVIMRC

"""""""""""""""""""""""""""""""""""""""
" common config
"""""""""""""""""""""""""""""""""""""""
" indents and tab
set shiftwidth=4     " 一个缩进的宽度
set autoindent       " 自动缩进
set expandtab        " 使用空格展开 tab 键
set softtabstop=4    " tab 键被展开的

" line and column
set number            " 设置行号 'nu'
set cursorline        " 设置所在行高亮 'cul'
set colorcolumn=81    " 设置高亮 81 列 'cc'


"""""""""""""""""""""""""""""""""""""""
" installed plugins
"""""""""""""""""""""""""""""""""""""""
" Specify a directory for plugins managed by vim-plug
call plug#begin('~/.vim/plugged')

" nerdtree and related
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jistr/vim-nerdtree-tabs'

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

