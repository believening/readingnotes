" for vim8
" ref: https://github.com/amix/vimrc

" map leader to ',', 
" if not set, <leader> means '\'
let mapleader = ","

" wildmenu command-line completion operates in an enhanced mode
set wildmenu
" ignore compiled files
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

set nu rnu

""""""""""""""""""""""""""""""""""""""""
" TEXT
""""""""""""""""""""""""""""""""""""""""
" switches on syntax highlighting
syntax enable

" set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use spaces instead of tabs
set expandtab

if has("autocmd")
  " If the filetype is Makefile then we need to use tabs
  " So do not expand tabs into space.
  autocmd FileType make   set noexpandtab
endif

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

""""""""""""""""""""""""""""""""""""""""
" SEARCH
""""""""""""""""""""""""""""""""""""""""
" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map <space> /
map <C-space> ?

""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""
set laststatus=2
" Format the status line
"set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
set statusline=
set statusline+=%{FugitiveStatusline()}
set statusline+=%f%m%r%h%w
set statusline+=%=\ Line:\ %l\ \ Column:\ %c

""""""""""""""""""""""""""""""""""""""""
" MOVE BETWEEN WINDOWS
""""""""""""""""""""""""""""""""""""""""
" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

""""""""""""""""""""""""""""""""""""""""
" PLUGIN
""""""""""""""""""""""""""""""""""""""""
" set gruvbox colorscheme
" upstream: https://github.com/morhetz/gruvbox
" install: git clone https://github.com/morhetz/gruvbox.git ~/.vim/pack/default/start/gruvbox
set background=dark    " Setting dark mode
autocmd vimenter * ++nested colorscheme gruvbox

" set nerd tree 
" upstream: https://github.com/preservim/nerdtree
" install: git clone https://github.com/preservim/nerdtree.git ~/.vim/pack/vendor/start/nerdtree
let NERDTreeShowHidden=0
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let g:NERDTreeWinSize=35
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark<Space>
map <leader>nf :NERDTreeFind<cr>

" coc.nvim
" upstream: https://github.com/neoclide/coc.nvim
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('runCommand', 'editor.action.formatDocument') <bar> w
" autoimport for go
autocmd BufWritePre *.go silent call CocAction('runCommand', 'editor.action.organizeImport')
" confirms completion
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
" select the first completion item and confirm the completion when no item has been selected
inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

" ack.vim
" upstream: https://github.com/mileszs/ack.vim
"if executable('rg')
"  let g:ackprg = 'rg --vimgrep --smart-case'
"endif
"
"cnoreabbrev Ack Ack!
"nnoremap <Leader>g :Ack!<Space>
""let g:ack_autoclose = 1
"let g:ack_mappings = {
"      \  'v':  '<C-W><CR><C-W>L<C-W>p<C-W>J<C-W>p',
"      \ 'gv': '<C-W><CR><C-W>L<C-W>p<C-W>J' }

" fzf, fzf.vim
" upstream: https://github.com/junegunn/fzf, https://github.com/junegunn/fzf.vim
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
map <leader>f :Files<cr>
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--disabled', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  let spec = fzf#vim#with_preview(spec, 'right', 'ctrl-/')
  call fzf#vim#grep(initial_command, 1, spec, a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
map <leader>g :RG<cr>

" fold
set foldmethod=syntax
set nofoldenable

" set maxmempattern(default 1000) to fix E363
set mmp=10000

" use <leader>t to select next tab
nnoremap <leader>t :tabnext<CR>