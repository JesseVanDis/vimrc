" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" run these commands for this vimrc to work:
" sudo pip3 install neovim

" sync vimrc
let $vimrcsync_folder = $HOME . '/.vim/vimrcsync'
let $vimrcsync_usrfile = $vimrcsync_folder . '/usr.usr'
let $vimrcsync_passfile = $vimrcsync_folder . '/pass.pass'
let $vimrcsync_gitfolder = $vimrcsync_folder . '/git'
function SetupVimRcSync()
	if empty(glob($vimrcsync_usrfile)) || empty(glob($vimrcsync_passfile))
		echo "vimrc sync credentials not found."
		let username = input('Enter github username: ')
		let password = input('Enter github password: ')
		silent !echo "$username" > $vimrcsync_usrfile 
		silent !echo "$password" > $vimrcsync_passfile 
		echo "credentials saved"
	endif
	if !empty(glob($vimrcsync_usrfile)) && !empty(glob($vimrcsync_passfile))
		silent let $gitusr = join(readfile($vimrcsync_usrfile), "\n")
		silent let $gitpass = join(readfile($vimrcsync_passfile), "\n")
		if !isdirectory($vimrcsync_gitfolder)
			silent let $cloneCmd = "git clone https://" . $gitusr . ":" . $gitpass . "@github.com/PrimeVest/vimrc.git " . $vimrcsync_gitfolder
			silent ! $cloneCmd
		endif
		silent let $pullCmd = "git -C " . $vimrcsync_gitfolder . " pull"
		silent ! $pullCmd
	endif	
endfunction

function UploadVimRc()
	call SetupVimRcSync()
	silent let $copyCmd = "cp " . $HOME . "/.vimrc " . $vimrcsync_gitfolder . "/vimrc"
	silent let $addCmd = "git -C " . $vimrcsync_gitfolder . " add ."
	silent let $commitCmd = "git -C " . $vimrcsync_gitfolder . " commit -m \"updated\""
	silent let $pushCmd = "git -C " . $vimrcsync_gitfolder . " push"
	silent ! $copyCmd
	silent ! $addCmd
	silent ! $commitCmd
	silent ! $pushCmd
	:redraw!
endfunction

function DownloadVimRc()
	call SetupVimRcSync()
	silent let $copyCmd = "cp " . $vimrcsync_gitfolder . "/vimrc " . $HOME . "/.vimrc "
	silent ! $copyCmd
	:redraw!
endfunction

command! UploadVimRc call UploadVimRc()
command! DownloadVimRc call DownloadVimRc()

silent !dpkg -s build-essential 2>/dev/null >/dev/null || sudo apt-get install build-essential
silent !dpkg -s cmake 2>/dev/null >/dev/null || sudo apt-get install cmake
silent !dpkg -s python-dev 2>/dev/null >/dev/null || sudo apt-get install python-dev
silent !dpkg -s python3-dev 2>/dev/null >/dev/null || sudo apt-get install python3-dev

if has("python3")
  set pyxversion=3
endif

" Golang path
let $GOPATH = $HOME . '/go'
if isdirectory('/usr/local/go')
	let $PATH .= ':/usr/local/go/bin'
	let $GOROOT = '/usr/local/go'
else
	let $GOROOT = '/usr/lib/go'
endif
let $PATH .= ':' . $GOPATH

" Install vundle plugin
if !isdirectory($HOME . '/.vim/bundle/vundle')
    silent !git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
endif

set nocompatible
filetype off
filetype plugin indent off
set runtimepath+=$GOROOT/misc/vim
set rtp+=~/.vim/bundle/vundle/
call vundle#begin()

Plugin 'valloric/youcompleteme'
Plugin 'scrooloose/nerdtree'
Plugin 'bling/vim-airline'
" Plugin 'scrooloose/syntastic'
Plugin 'kien/ctrlp.vim'
Plugin 'nsf/gocode'
Plugin 'fatih/vim-go'
Plugin 'easymotion/vim-easymotion'

" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on
set nocompatible

" Build youcompleteme
if !isdirectory($HOME . '/.vim/bundle/youcompleteme/didbuild')
    silent !cd ~/.vim/bundle/youcompleteme && ./install.py --clang-completer
    silent !mkdir -p ~/.vim/bundle/youcompleteme/didbuild
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END
else
  set autoindent		" always set autoindenting on
endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langnoremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If unset (default), this may break plugins (but it's backward
  " compatible).
  set langnoremap
endif

" The matchit plugin makes the % command work better, but it is not backwards
" compatile
packadd matchit

autocmd vimenter * NERDTree

" .======================================.
" ||            MAPPINGS                ||
" '======================================'

" Don't use Ex mode, use Q for formatting
map Q gq

" replace word with yanked word
" map <C-p> cw<C-r>0<ESC>

" search for selected text
vmap * "ty/<C-r>t<CR>v//e<CR>
vmap # "ty?<C-r>t<CR>v//e<CR>

" Navigation
map <C-j> 10j
map <C-k> 10k
map <C-l> w
map <C-h> b
imap <C-l> <Left>
imap <C-h> <Right>
map ,e <esc>:NERDTreeToggle<CR>
map <C-Up> 10k
map <C-Down> 10j
map ,k :bp<CR>
map ,j :bn<CR>
vnoremap <F3> y/<C-R>"<CR>
vnoremap ff <Esc>:let @s=@<CR>gv"ay:let @"=@s<CR>:vimgrep /<C-r>a/ **/*.go **/*.js **/*.html<CR>:clist<CR>
nnoremap fk :cp<CR>:clist<CR>
nnoremap fj :cn<CR>:clist<CR>
autocmd BufNewFile,BufRead *.go noremap <C-g> <Esc>:GoReferrers<CR>

" Start search with word under cursor (and perserve default registry)
nmap ,n :let @s=@<CR>viw"ay/<C-r>a<CR>:let @"=@s<CR>

" Save
map <C-w> <Esc>:w<CR>

" Build / Run
" Workaround https://github.com/fatih/vim-go/issues/1477
autocmd BufNewFile,BufRead *.go  GoInstallBinaries 
autocmd BufNewFile,BufRead *.go  map <C-b> <Esc>:w<CR><Esc>:GoBuild<CR>:GoInstallBinaries<CR>

" Switch windows
nmap <silent> <S-Up> :wincmd k<CR>
nmap <silent> <S-Down> :wincmd j<CR>
nmap <silent> <S-Left> :wincmd h<CR>
nmap <silent> <S-Right> :wincmd l<CR>

" Escape insert mode
imap ii <Esc>

" .======================================.
" ||            SETTINGS                ||
" '======================================'
set wildignore=*.dll,*.o,*.pyc,*.bak,*.exe,*$py.class,*.class

set number
highlight LineNr ctermfg=grey ctermbg=white     
set cursorline                                  " highlight cursor line
set tabstop=4 shiftwidth=4                      " tab is 4 wide
set encoding=utf-8
set ttyfast                                     " smoother scrolling
set nowrap                                      " lines longer than the screen will not be given a new line
set backspace=indent,eol,start                  " allow backspacing over everything in insert mode
set history=50		                            " keep 50 lines of command line history
set ruler		                                " show the cursor position all the time
set showcmd		                                " display incomplete commands
set incsearch		                            " do incremental searching
syntax on                                       " enable syntax highlighting
set hlsearch                                    " switch on highlighting the last used search pattern.
set mouse=a                                     " enable mouse
set autowrite                                   " auto-write file when searching for a word or something
set ignorecase                                  " ignore case when searching with '/'

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  set undofile		" keep an undo file (undo changes after closing)
endif

autocmd FileType html set spell
autocmd FileType python set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType phtml set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType sql set omnifunc=sqlcomplete#Complete
autocmd FileType java setlocal omnifunc=javacomplete#Complete
" autocmd FileType go setlocal omnifunc=gocomplete#Complete

" let g:neocomplcache_omni_patterns.go = '\h\w*%.'

autocmd InsertEnter,InsertLeave * set cul!   " Indicate insert mode by changing selected line layout

let g:ctrlp_by_filename = 1

let g:airline#extensions#tabline#enabled = 1

let g:go_fmt_command = "goimports"
" let g:go_fmt_options = "-tabs=false -tabwidth=4"
let g:go_highlight_operators = 1
"let g:go_highlight_function_arguments = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_types = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
"let g:go_highlight_generate_tags = 1
"let g:go_highlight_fields = 1

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

set showtabline=2

set wildmenu " display all matching files when we tab complete

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_signs = 1
let g:syntastic_go_checkers = ['go', 'govet']
let g:syntastic_java_checkers=['javac']
let g:syntastic_java_javac_config_file_enabled = 1
let g:syntastic_python_checkers=['python3', 'flake8']

let g:deoplete#enable_at_startup = 1

let g:go_auto_sameids = 1
let g:go_def_mapping_enabled = 1

filetype indent on

hi EasyMotionTarget2First ctermbg=none ctermfg=red
hi EasyMotionTarget2Second ctermbg=none ctermfg=brown




