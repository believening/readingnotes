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
set expandtab        " 使用空格展开 tab 键 'et'
set softtabstop=4    " tab 键被展开的宽度 'sts'
```

### 1.2 行列显示

``` vimrc
set number            " 设置行号 'nu'
set cursorline        " 设置所在行高亮 'cul'
set colorcolumn=81    " 设置高亮 81 列 'cc'
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

## 3 参考

- [Vim documentation: options](http://vimdoc.sourceforge.net/htmldoc/options.html)
- [上古神器vim插件：你真的学会用NERDTree了吗？](https://www.jianshu.com/p/3066b3191cb1)
