# 从头到尾自己配一遍 VIM

vim 版本最好是 version 8 以上，能够支持 python 开发的插件

``` shell
# vim --version
VIM - Vi IMproved 8.1 (2018 May 18, compiled Jul 22 2019 00:00:00)
Included patches: 1-450
Compiled by <bugzilla@redhat.com>
Huge version without GUI.  Features included (+) or not (-):
......
+comments          +libcall           +python/dyn        +viminfo
+conceal           +linebreak         +python3/dyn       +vreplace
......
   system vimrc file: "/etc/vimrc"
     user vimrc file: "$HOME/.vimrc"
 2nd user vimrc file: "~/.vim/vimrc"
      user exrc file: "$HOME/.exrc"
       defaults file: "$VIMRUNTIME/defaults.vim"
  fall-back for $VIM: "/etc"
 f-b for $VIMRUNTIME: "/usr/share/vim/vim81"
......
```

## 1 基本配置

### 1.1 缩进 [indents and tabs](http://vimdoc.sourceforge.net/htmldoc/usr_25.html#25.3)

``` vimrc
set shiftwidth=4     " 一个缩进的宽度 'sw'
set autoindent       " 自动缩进 'ai'
set smartindent      " 智能缩进 'si'
set expandtab        " 使用空格展开 tab 键 'et'
set softtabstop=4    " tab 键被展开的宽度 'sts'
```

`softtabstop` 和 `tapstop` 的区别在于前者是在编辑模式下对于 **tab** 键的空格替换数目的计算，后者则是在其他模式下的空格数目的计算。由于默认的 `tapstop` 是 8 ，所以由别的主体维护的文件采用的可能是默认的 `tapstop` 配置，更改之后通过 vim 查看时，有可能会有显示上的错误。

### 1.2 行列显示

``` vimrc
set number            " 设置行号 'nu'
set cursorline        " 设置所在行高亮 'cul'
set colorcolumn=81    " 设置高亮 81 列 'cc'
highlight ColorColumn ctermbg=black  ctermfg=white
```

### 1.3 其他

``` vimrc
set nocompatible                  " 不兼容 vi 'nocp'
set backspace=indent,eol,start    " 插入模式下退格键的作用于缩进、行尾
set hlsearch                      " 高亮搜索 'hls'
set ignorecase                    " 搜索时忽略大小写 'ic'
set incsearch                     " 搜索模式实时匹配 'is'
syntax on
filetype plugin on
```

## 2 插件

### 2.1 插件管理器

vim 的插件管理器有很多

- [vim-plug](https://github.com/junegunn/vim-plug)
- [VAM](https://github.com/MarcWeber/vim-addon-manager)
- [Vundle](https://github.com/VundleVim/Vundle.vim)
- [Pathogen](https://github.com/tpope/vim-pathogen)

我个人没有体验过 vim-plug 之外的其他插件，毕竟改进并流行起来的解决方案的出现总会理由的，不是所有人都是明智的，但是业界群体的选择是值得尝试的，所以我直接用了 vim-plug。

vim-plug 的安装很简单

``` shell
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

这里要解释的是 `~/.vim/autoload/` 目录，

在 `~/.vimrc` 中配置 vim-plug

``` vimrc
" Specify a directory for plugins managed by vim-plug
call plug#begin('~/.vim/plugged')

" some plugins

" Initialize plugin system
call plug#end()
```

### 2.2 常用插件

#### 2.2.1 nerdtree 和相关

``` vimrc
call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'Xuyuanp/nerdtree-git-plugin'

call plug#end()

map <F10> :NERDTreeToggle<CR>
" nerdtree
let NERDTreeShowLineNumbers=1     " 显示行号
let NERDTreeAutoCenter=1          " 打开文件时是否显示目录
let NERDTreeShowHidden=1          " 显示隐藏文件
let NERDTreeIgnore=['\.swp']      " 忽略文件

" vim-nerdtree-tabs
let g:nerdtree_tabs_open_on_console_startup=1

" nerdtree-git-plugin
let g:NERDTreeIndicatorMapCustom = {
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
```

#### 2.2.2 文件搜索 ctrlpvim

``` vimrc
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
" Plug 'Yggdroot/LeaderF' " 依赖 python, 速度快

call plug#end()
```

- ctrl + p 搜索文件
- ctrl + k/j 选择文件
- ctrl + x/v 水平或者垂直分屏打开文件

#### 2.2.3 tagbar 文件大纲

``` vimrc
call plug#begin('~/.vim/plugged')

Plug 'majutsushi/tagbar'

call plug#end()

map <F9> :TagbarToggle︎︎︎︎<CR>
```

需要 ctags 支持

#### 2.2.4 状态栏增强

``` vimrc
call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

let g:airline_theme='base16_tomorrow' " 设置主题
```

#### 2.2.5 golang

``` vimrc
call plug#begin('~/.vim/plugged')

Plug 'fatih/vim-go' ",︎︎ { 'do': ':GoUpdateBinaries' }
Plug 'mdempsky/gocode'︎︎, { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }

call plug#end()

let g:tagbar_type_go={
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

let g:go_fmt_command="goimports" " 格式化将默认的 gofmt 替换
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
```

## 3 参考

### common

- [Vim documentation: options](http://vimdoc.sourceforge.net/htmldoc/options.html)
- [filetype](http://vimdoc.sourceforge.net/htmldoc/filetype.html)
- [syntax](http://vimdoc.sourceforge.net/htmldoc/syntax.html)
- [上古神器vim插件：你真的学会用NERDTree了吗？](https://www.jianshu.com/p/3066b3191cb1)
- [ctrlp](https://github.com/ctrlpvim/ctrlp.vim)
- [tagbar](https://github.com/majutsushi/tagbar)
- [airline](https://github.com/vim-airline/vim-airline)

### golang

- [vim-go](https://github.com/fatih/vim-go)
- [gocode](https://github.com/mdempsky/gocode)
- [gotags](https://github.com/jstemmer/gotags)
