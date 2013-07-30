" vim 7.3+
set nocompatible
call pathogen#infect()
set laststatus=2

"let g:Powerline_symbols = 'fancy'

set backspace=indent,eol,start
" make arrow keys wrap lines and whitespace properly
set whichwrap=b,s,<,>,[,]
syntax on
set number
set ic
set smartcase
set autoindent
set incsearch

" match by highlight as well (still need to press return to search, however)
set hlsearch
" Clear search highlight by hitting enter
nnoremap <silent> <CR> :noh<CR>

" Spell checking. Does not offer suggestions :-)
set spell

set cursorline " Highlight current line
set autoread " Reload files that have changed

filetype on
au BufNewFile,BufRead *.json set filetype=javascript
au BufNewFile,BufRead *.less set filetype=css
au BufNewFile,BufRead *.ino  set filetype=c
au BufNewFile,BufRead *.pde  set filetype=c
au BufNewFile,BufRead *.md   set filetype=markdown
au BufNewFile,BufRead *.fish set filetype=sh

" It's not the 70's anymore. Use git or something.
set noswapfile
set nobackup

" get rid of the engulfing behavior of highlighting matching brackets
" when inside parenthesis. It makes the cursor hard to distinguish.
set noshowmatch


" NoMatchParen " this works as a command but not a setting
" this does work, fooling the matching system into
let loaded_matchparen = 1


" Reselect visual block after indent/outdent
vnoremap < <gv
vnoremap > >gv

" no point in pressing/releasing the shift key!
nnoremap ; :

" if you want to force yourself to use hjkl, uncomment this:
"map <up> <nop>
"map <down> <nop>
"map <left> <nop>
"map <right> <nop>

" Nice command. Probably better as a keybinding
" :autocmd BufWritePost * !forever restartall
" map <silent> <f5> :!forever restartall <cr>
" map <f5> :autocmd BufWritePost * !forever restartall

let g:SuperTabNoCompleteAfter = ['^', '\s', '//', '#']


" 16-color terminal with solarised theme is preferable.
" failing this, the following option can be set to use a degraded 256 color pallette
let g:solarized_termcolors=256

" good on crap laptop monitors
let g:solarized_contrast="high"


" Configure solarised per machine.
set background=dark
colorscheme solarized

" anti typo
ca WQ wq
ca Wq wq
ca wQ wq
ca qw wq
ca W w
ca Q q

" <tab> to toggle nerdtree, persistent across all tabs!
nnoremap <tab> :NERDTreeTabsToggle<CR>
let NERDTreeMapQuit='\t'

" Ex mode? WTF VIM?
map Q <Nop>

" re-flow entire paragraph
nmap Q gqap

" http://nvie.com/posts/how-i-boosted-my-vim/
" Finally, a trick by Steve Losh "for when you forgot to sudo before editing a
" file that requires root privileges (typically /etc/hosts). This lets you use
" w!! to do that after you opened the "file already:
cmap w!! w !sudo tee % >/dev/null

set mouse=a

" abbreviations
ab teh the
ab THe The
ab eb be

" Hide toolbar by default
if has("gui_running")
	set guioptions=egmrt
endif

set tabpagemax=20

" disable useless viminfo files
set viminfo=

" open help in new tab
cabbrev help tab help

" abbreviate messages to avoid hit-enter prompt
set shortmess=a
