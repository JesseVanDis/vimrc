" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

set nocompatible " be iMproved, required

" sync vimrc
let $vimrcsync_folder = $HOME . '/.vim/vimrcsync'
let $vimrcsync_usrfile = $vimrcsync_folder . '/usr.usr'
let $vimrcsync_passfile = $vimrcsync_folder . '/pass.pass'
let $vimrcsync_gitfolder = $vimrcsync_folder . '/git'

function SetupVimRcSync()
	if empty(glob($vimrcsync_usrfile)) || empty(glob($vimrcsync_passfile))
		silent !mkdir -p $vimrcsync_folder
		echo "vimrc sync credentials not found."
		call inputsave()
		let username = input('Enter github username: ')
		call inputrestore()
		call writefile([username], $vimrcsync_usrfile, "a") 
		call inputsave()
		let password = input('Enter github password: ')
		call inputrestore()
		call writefile([password], $vimrcsync_passfile, "a") 
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
	echo "copying .vimrc.. (1/5)"
	silent ! $copyCmd
	echo "creating commit.. (2/5)"
	silent ! $addCmd
	echo "committing.. (3/5)"
	silent ! $commitCmd
	echo "pushing.. (4/5)"
	silent ! $pushCmd
	echo "done! (5/5)"
	:redraw!
endfunction

function DownloadVimRc()
	echo "pulling.. (1/2)"
	call SetupVimRcSync()
	silent let $copyCmd = "cp " . $vimrcsync_gitfolder . "/vimrc " . $HOME . "/.vimrc "
	silent ! $copyCmd
	echo "done! (2/2)"
	:redraw!
	:source ~/.vimrc
endfunction

command! UploadVimRc call UploadVimRc()
command! DownloadVimRc call DownloadVimRc()

let pythonDir = substitute(system('python3 -m site | grep -F "USER_SITE: ' . "'" . '" | awk -F"' . "'" . "\" '{print $2}'"), '\n\+$', '', '')

silent !dpkg -s build-essential 2>/dev/null >/dev/null || sudo apt-get install build-essential
silent !dpkg -s python-dev 2>/dev/null >/dev/null || sudo apt-get install python-dev
silent !dpkg -s python3-dev 2>/dev/null >/dev/null || sudo apt-get install python3-dev
silent !dpkg -s cscope 2>/dev/null >/dev/null || sudo apt-get install cscope
" TODO: Use universal Ctags
silent !dpkg -s exuberant-ctags 2>/dev/null >/dev/null || sudo apt-get install exuberant-ctags
silent !dpkg -s silversearcher-ag 2>/dev/null >/dev/null || sudo apt-get install silversearcher-ag
" NeoVim
silent !dpkg -s qtbase5-dev 2>/dev/null >/dev/null || sudo apt-get install qtbase5-dev
" Javascript
silent !dpkg -s python3-pip 2>/dev/null >/dev/null || sudo apt-get install python3-pip
if !isdirectory(pythonDir . "/neovim")
	" this command is a bit slow... (that why we just first check the folder which is simply faster
	silent !pip3 list --format=legacy | grep -F neovim || pip3 install neovim
endif

function InstallCmake()
	if !isdirectory($HOME . "/.vim/cmake")
	 	silent !mkdir -p ~/.vim/cmake
	 	silent !echo "mkdir -p ~/.vim/cmake/cmakegit" > ~/.vim/cmake/clonesetup.sh
	 	silent !echo "cd ~/.vim/cmake/cmakegit" >> ~/.vim/cmake/clonesetup.sh
		silent !echo "wget https://cmake.org/files/v3.12/cmake-3.12.2.tar.gz" >> ~/.vim/cmake/clonesetup.sh
		silent !echo "tar -xvzf cmake-3.12.2.tar.gz" >> ~/.vim/cmake/clonesetup.sh
		silent !echo "cd ./cmake-3.12.2/" >> ~/.vim/cmake/clonesetup.sh
		silent !echo "./bootstrap --system-curl" >> ~/.vim/cmake/clonesetup.sh
		silent !echo "make" >> ~/.vim/cmake/clonesetup.sh
		silent !echo "sudo make install" >> ~/.vim/cmake/clonesetup.sh
	 	silent !chmod +x ~/.vim/cmake/clonesetup.sh
	 	silent !xterm -e ~/.vim/cmake/clonesetup.sh
	 	:redraw!
	endif
endfunction
call InstallCmake()

function InstallNeoVimQt()
	if !isdirectory($HOME . "/.vim/neovimqt")
	 	silent !mkdir -p ~/.vim/neovimqt
	 	silent !echo "mkdir -p ~/.vim/neovimqt/neovim-qt" > ~/.vim/neovimqt/clonesetup.sh
	 	silent !echo "git clone https://github.com/equalsraf/neovim-qt ~/.vim/neovimqt/neovim-qt" >> ~/.vim/neovimqt/clonesetup.sh
	 	silent !echo "mkdir -p ~/.vim/neovimqt/neovim-qt/build" >> ~/.vim/neovimqt/clonesetup.sh
	 	silent !echo "cd ~/.vim/neovimqt/neovim-qt/build" >> ~/.vim/neovimqt/clonesetup.sh
	 	silent !echo "cmake -DCMAKE_BUILD_TYPE=Release .." >> ~/.vim/neovimqt/clonesetup.sh
	 	silent !echo "make" >> ~/.vim/neovimqt/clonesetup.sh
	 	silent !echo "sudo make install" >> ~/.vim/neovimqt/clonesetup.sh
	 	silent !chmod +x ~/.vim/neovimqt/clonesetup.sh
	 	silent !xterm -e ~/.vim/neovimqt/clonesetup.sh
	 	:redraw!
	endif
endfunction
call InstallNeoVimQt()

function InstallJavascriptStuff()
	" Javascript stuff TODO: tedect javascript files
	silent !dpkg -s npm 2>/dev/null >/dev/null || sudo apt-get install npm
	if !isdirectory('../node_modules')
		" ToDeleteAll: sudo npm ls -gp --depth=0 | sudo awk -F/ '/node_modules/ && !/\/npm$/ {print $NF}' | sudo xargs npm -g rm
		" silent !npm init -f
		silent !echo "current dir:"
		silent !echo $(pwd)
		silent !{ cd ../; npm init -f; }
		silent !npm list --depth 1 --global eslint > /dev/null 2>&1 || sudo npm install "eslint@>=5.0.0-alpha.2" -g
		silent !npm list --depth 1 --global eslint-plugin-import > /dev/null 2>&1 || sudo npm install "eslint-plugin-import@>=2.8.0" -g
		silent !npm list --depth 1 --global eslint-plugin-node > /dev/null 2>&1 || sudo npm install "eslint-plugin-node@>=5.2.1" -g
		silent !npm list --depth 1 --global eslint-plugin-promise > /dev/null 2>&1 || sudo npm install "eslint-plugin-promise@>=3.6.0" -g
		silent !npm list --depth 1 --global eslint-plugin-standard > /dev/null 2>&1 || sudo npm install "eslint-plugin-standard@>=3.0.1" -g
		silent !npm list --depth 1 --global eslint-config-standard > /dev/null 2>&1 || sudo npm install eslint-config-standard -g
		" eslint-config-standard@12.0.0-alpha.0 
		silent !echo "__________________________________________________"
		silent !echo "  Use: populair -> standard -> javascript -> yes  "
		silent !echo "--------------------------------------------------"
		silent !{ cd ../; eslint --init; }
	endif
endfunction
autocmd BufNewFile *.js call InstallJavascriptStuff() 

if !has('nvim')
	if has("python3")
		set pyxversion=3 " Thiscauses error on nvim.... disable it temporarily
	endif
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
let $PATH .= ':' . $HOME . '/go/bin'

" Install vundle plugin
if !isdirectory($HOME . '/.vim/bundle/vundle')
    silent !git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
endif

" set nocompatible
" filetype off
" filetype plugin indent off
set runtimepath+=$GOROOT/misc/vim
set rtp+=~/.vim/bundle/vundle/

call plug#begin('~/.vim/plugged')

" generic
Plug 'scrooloose/nerdtree'
Plug 'kien/ctrlp.vim'
Plug 'fatih/vim-go'
Plug 'easymotion/vim-easymotion'
Plug 'skywind3000/asyncrun.vim'

" cpp
Plug 'oblitum/YouCompleteMe'

" javascript
Plug 'Shougo/deoplete.nvim', {'for': 'javascript'}
Plug 'roxma/nvim-yarp', {'for': 'javascript'}
Plug 'roxma/vim-hug-neovim-rpc', {'for': 'javascript'}
Plug 'w0rp/ale', {'for': 'javascript'}

" Theme
"" Plug 'fatih/molokai'
"" Plug 'colepeters/spacemacs-theme.vim'
Plug 'lifepillar/vim-solarized8'
Plug 'jonathanfilip/vim-lucius'

call plug#end()

" filetype plugin indent on
" set nocompatible

let g:deoplete#enable_at_startup = 1
" let g:deoplete#auto_complete = 0

" Build youcompleteme
if isdirectory($HOME . '/.vim/bundle/youcompleteme')
	if !isdirectory($HOME . '/.vim/bundle/youcompleteme_didbuild')
		silent !cd ~/.vim/bundle/youcompleteme && ./install.py --clang-completer
		silent !mkdir -p ~/.vim/bundle/youcompleteme_didbuild
	endif
endif

" Build youcompleteme ( oblitum fork )
if isdirectory($HOME . '/.vim/bundle/YouCompleteMe')
	if !isdirectory($HOME . '/.vim/bundle/YouCompleteMe_didbuild')
		silent !cd ~/.vim/bundle/YouCompleteMe && ./install.py --clang-completer
		silent !mkdir -p ~/.vim/bundle/YouCompleteMe_didbuild
	endif
endif

" Build youcompleteme ( vim-plug )
if isdirectory($HOME . '/.vim/plugged/YouCompleteMe')
	if !isdirectory($HOME . '/.vim/plugged/YouCompleteMe_didbuild')
		silent !cd ~/.vim/plugged/YouCompleteMe && ./install.py --clang-completer
		silent !mkdir -p ~/.vim/plugged/YouCompleteMe_didbuild
	endif
endif

" Instal vim proc for golang debugging
if isdirectory($HOME . '/.vim/bundle/vimproc.vim')
    silent !cd ~/.vim/bundle/vimproc.vim && make
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

" The matchit plugin makes the % command work better, but it is not backwards compatile
if !has('nvim')
	packadd matchit
endif

" autocmd vimenter * NERDTree
autocmd vimenter * wincmd l

" extention mapping
au BufNewFile,BufRead *.locatext set filetype=xml


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
vnoremap <F3> "qy/<C-R>q<CR>
vnoremap * "qy/<C-R>q<CR>
nnoremap <C-H> :cp<CR>
nnoremap <C-L> :cn<CR>

autocmd BufNewFile,BufRead *.html nnoremap <C-]> "ayiw:call SearchText_OpenFirst("function.<C-r>a", "html,js")<CR>

" switch header/source
autocmd BufNewFile,BufRead *.hpp nnoremap ,l :e %:r.cpp<CR>
autocmd BufNewFile,BufRead *.cpp nnoremap ,l :e %:r.hpp<CR>

" generate function in cpp
autocmd BufNewFile,BufRead *.hpp nnoremap ,c "xyy/(<CR>Nh*<C-o>:e %:r.cpp<CR>nB"cyiw/{<CR>%o<Esc>"xpv=w"cPa::<Esc>Bhvbelc <Esc>$xo{<CR><CR>}<Esc>kaa<Esc>v=x:noh<CR>

function! SearchText_Begin(text, filterExt)
	call delete($HOME . "/.searchresults.txt_1~")
	call delete($HOME . "/.searchresults.txt~")
	if empty(a:filterExt)
		let $searchCommand = "grep -F -R -r -i --include=\*.* " . a:text . " . > ~/.searchresults.txt_1~"
	else
		let $searchCommand = "grep -F -R -r -i --include=\*.{" . substitute(a:filterExt, "[.]", "", "g") . ",boooooool} " . a:text . " . > ~/.searchresults.txt_1~"
	endif
	silent exec $searchCommand
	silent ! echo "" > ~/.searchresults.txt~
	silent ! expand -t 4 ~/.searchresults.txt_1~ > ~/.searchresults.txt~
endfunction

function! SearchText_End()
	" call delete($HOME . "/.searchresults.txt_1~")
	" call delete($HOME . "/.searchresults.txt~")
endfunction

function! SearchText(text, filterExt)
	let $henk = a:text
	call SearchText_Begin(a:text, a:filterExt)
	cexpr system("cat ~/.searchresults.txt~")	
	execute "normal 1 \<c-o>"
	copen
	execute "match Error /\\c" . a:text . "/"
	redraw!
	call SearchText_End()
endfunction

function! SearchText_OpenFirst(text, filterExt)
	call SearchText_Begin(a:text, a:filterExt)
	let $filename = substitute(system("head -1 ~/.searchresults.txt~ | awk -F: '{print $1}'"), "\n", "", "")
	let $line = substitute(system("head -1 ~/.searchresults.txt~ | awk -F: '{print $2}'"), "\n", "", "")
	execute "normal! :e +" . $line . " " . $filename . "\<CR>"
	redraw!
	execute "normal! :echo('" . $filename . ":" . $line . "')\<CR>"
 	call SearchText_End()
endfunction

vnoremap ,f "ayiw:call SearchText("<C-r>a", "")<Left><Left><Left><Left><Left><left>
nnoremap ,f "ayiw:call SearchText("<C-r>a", "")<Left><Left><Left><Left><Left><left>

autocmd BufNewFile,BufRead *.go nnoremap ,f "ayiw:call SearchText("<C-r>a", "go,js,html")<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><left><Left><left><left>
autocmd BufNewFile,BufRead *.go vnoremap ,f "aylh:call SearchText("<C-r>a", "go,js,html")<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><left><Left><left><left>

autocmd BufNewFile,BufRead *.html nnoremap ,f "ayiw:call SearchText("<C-r>a", "go,js,html,css")<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><left><Left><left><left><left><Left><left><left>
autocmd BufNewFile,BufRead *.html vnoremap ,f "aylh:call SearchText("<C-r>a", "go,js,html,css")<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><left><Left><left><left><left><Left><left><left>

autocmd BufNewFile,BufRead *.js nnoremap ,f "ayiw:call SearchText("<C-r>a", "go,js,html")<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><left><Left><left><left>
autocmd BufNewFile,BufRead *.js vnoremap ,f "aylh:call SearchText("<C-r>a", "go,js,html")<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><left><Left><left><left>

autocmd BufNewFile,BufRead *.go noremap <C-g> <Esc>:GoReferrers<CR>

" insert for loop
autocmd BufNewFile,BufRead *.go noremap ,i <Esc>afor i, v := range xxx {<CR>}<Esc><S-v>k=$bciw

" print variable
autocmd BufNewFile,BufRead *.go noremap ,p <Esc>afmt.Printf("%+v\n",  )<Esc>v=$hi

" avoid yanking the text you delete... 
nnoremap c "_c
vnoremap c "_c
nnoremap C "_C
vnoremap C "_C
nnoremap x "_x
xnoremap p pgvy

" Build / Run
" Workaround https://github.com/fatih/vim-go/issues/1477
autocmd BufNewFile,BufRead *.go  GoInstallBinaries 
autocmd BufNewFile,BufRead *.go  noremap <C-b> <Esc>:w<CR><Esc>:GoBuild<CR>:GoInstallBinaries<CR>
" autocmd BufNewFile,BufRead *.go  noremap <F5> <Esc>:!killall -9 debug<CR>:redir @y<CR>:pwd<CR>:redir END<CR>:redir @z<CR>:echo fnamemodify('<C-r>y', ':t')<CR>:redir END<CR>:DlvDebug <C-r>z<BS><BS><BS><C-B><Right><Right><Right><Right><Right><Right><Right><Right><Right><Del><Del><CR>y<CR><C-w>J:res 10<CR>G
" autocmd BufNewFile,BufRead *.go  noremap <F6> <Esc>:DlvConnect localhost:2345<CR><C-w>J:res 10<CR>
" autocmd BufNewFile,BufRead *.go  noremap bb <Esc>:DlvToggleBreakpoint<CR>
" noremap bb <Esc>:Breakpoint<CR>

" Switch windows
nmap <silent> <S-Up> :wincmd k<CR>
nmap <silent> <S-Down> :wincmd j<CR>
nmap <silent> <S-Left> :wincmd h<CR>
nmap <silent> <S-Right> :wincmd l<CR>

" Ctags
nmap ,r :!ctags -R .

" .======================================.
" ||            SETTINGS                ||
" '======================================'
set wildignore+=*.dll,*.o,*.pyc,*.bak,*.exe,*$py.class,*.class


syntax on                                       " enable syntax highlighting
syntax enable  
filetype plugin on  
filetype indent on
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
set hlsearch                                    " switch on highlighting the last used search pattern.
set mouse=a                                     " enable mouse
set autowrite                                   " auto-write file when searching for a word or something
set ignorecase                                  " ignore case when searching with '/'
" set whichwrap+=<,>,h,l,[,]						" Auto-next/prev line when moving cursor beyond end/beginning of line
set tags=tags;									" find tags file in current dir, if its not there then parent, then parent ect.

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  set undofile		" keep an undo file (undo changes after closing)
endif


function OnLoadFiletype(filetype)
 	let l:useDeoplete = 0
 	if a:filetype == "javascript"
 		let l:useDeoplete = 1
 	elseif a:filetype == "cpp"

	endif

	" if exists("*deoplete")
	if exists("*deoplete#custom#option")
		if l:useDeoplete == 1
			call deoplete#custom#option('auto_complete', v:true)
		else
			call deoplete#custom#option('auto_complete', v:false)
		endif
	endif
endfunction


" autocmd FileType html set spell
autocmd FileType python set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
" autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType python call OnLoadFiletype("python")

autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType python call OnLoadFiletype("html")

autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType python call OnLoadFiletype("css")

autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType python call OnLoadFiletype("xml")

autocmd FileType java setlocal omnifunc=javacomplete#Complete
autocmd FileType java call OnLoadFiletype("java")

autocmd FileType javascript call OnLoadFiletype("javascript")

autocmd FileType go call OnLoadFiletype("go")

autocmd FileType cpp call OnLoadFiletype("cpp")

" autocmd FileType go setlocal omnifunc=gocomplete#Complete

" let g:neocomplcache_omni_patterns.go = '\h\w*%.'

autocmd InsertEnter,InsertLeave * set cul!   " Indicate insert mode by changing selected line layout

" colorscheme molokai

"if (has("termguicolors"))
"  set termguicolors
"endif
"set background=dark
"colorscheme spacemacs-theme

" set background=light
" colorscheme solarized8

" set background=light
colorscheme lucius
LuciusWhite

if has('gui_running')
  set guifont=Monospace\ 11
endif


hi MatchParen      ctermfg=208 ctermbg=233 cterm=bold 

let g:ctrlp_by_filename = 1
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'

let g:airline#extensions#tabline#enabled = 1

let g:go_fmt_command = "goimports"
" let g:go_fmt_options = "-tabs=false -tabwidth=4"
let g:go_highlight_operators = 1
let g:go_highlight_function_arguments = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_types = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_structs = 1  
let g:go_highlight_generate_tags = 1
let g:go_auto_sameids = 0 " if 1 then it will highlight stuff that is currently under cursor.
let g:go_def_mapping_enabled = 1
let g:go_auto_type_info = 1 " automatically show info of the type
"let g:go_highlight_fields = 1

set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set showtabline=2
set wildmenu " display all matching files when we tab complete
" set autoindent
set cindent

" ignore anoying bitchass 'swp file exists' message
set shortmess+=A

" scroll margin from cursor
set so=7 

" scrollbars?
set guioptions=mlrb

set lines=11 columns=42

" disable spellcheck
set nospell

" avoid auto window creation if buffer wasnt saved
" set hidden

" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
" let g:syntastic_enable_signs = 1
" let g:syntastic_go_checkers = ['go', 'govet']
" let g:syntastic_java_checkers=['javac']
" let g:syntastic_java_javac_config_file_enabled = 1
" let g:syntastic_python_checkers=['python3', 'flake8']

let g:ale_linters = {
 \   'python': ['flake8', 'mypy'],
 \   'go': ['gofmt', 'golint', 'go vet'],
 \   'javascript': ['eslint'],
 \   'cpp': ['clang', 'clangcheck', 'clangtidy', 'cppcheck', 'cpplint', 'g++'],
 \   'c': 'all'
 \ }

" run ALEFix to fix
let g:ale_fixers = {
 \ 'javascript': ['eslint']
 \ }

let g:ale_python_flake8_options='--ignore=E225,E402,E501'
let g:ale_python_mypy_options='--ignore-missing-imports'


let g:deoplete#enable_at_startup = 1


if !exists('g:vdebug_options')
    let g:vdebug_options = {}
endif
let g:vdebug_options["break_on_open"] = 0
let g:vdebug_options["debug_file"] = $HOME . '/.vim/bundle/vdebug/log.log'
let g:vdebug_options["debug_window_level"] = 2
let g:vdebug_options["debug_file_level"] = 2

let g:javascript_plugin_jsdoc = 1

let g:ycm_confirm_extra_conf = 0
" let g:ycm_show_diagnostics_ui = 0
let g:ycm_show_diagnostics_ui = 1
let g:ycm_add_preview_to_completeopt = 1
" let g:ycm_autoclose_preview_window_after_completion = 1
" let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_filetype_blacklist = { 'javascript' : 1 }
" https://medium.com/@alexlafroscia/writing-js-in-vim-4c971a95fd49

hi EasyMotionTarget2First ctermbg=none ctermfg=red
hi EasyMotionTarget2Second ctermbg=none ctermfg=brown


" .======================================.
" ||            CUSTOM SHIT             ||
" '======================================'

let s:comment_map = { 
    \   "c": '\/\/',
    \   "cpp": '\/\/',
    \   "go": '\/\/',
    \   "java": '\/\/',
    \   "javascript": '\/\/',
    \   "sh": '#',
    \   "vimrc": '" ',
    \ }

function! ToggleComment()
    if has_key(s:comment_map, &filetype)
        let comment_leader = s:comment_map[&filetype]
        if getline('.') =~ "^\\s*" . comment_leader . " " 
            execute "silent s/^\\(\\s*\\)" . comment_leader . " /\\1/"
        else 
            if getline('.') =~ "^\\s*" . comment_leader
                execute "silent s/^\\(\\s*\\)" . comment_leader . "/\\1/"
            else
                execute "silent s/^\\(\\s*\\)/\\1" . comment_leader . " /"
            end
        end
    else
        echo "No comment leader found for filetype"
    end
endfunction


nnoremap ,/ :call ToggleComment()<cr>
vnoremap ,/ :call ToggleComment()<cr>



" rr tournament specific
if isdirectory($HOME . '/projects/rr-tournament')
	nmap ,r :!../../commands.sh hg<CR><CR>
	nnoremap ,t <C-]>:let @f=expand("%:p")<CR><C-^>ggO<Esc>:let @g=expand("%:p:h")<CR>:read !python -c "import os.path; print os.path.relpath('<C-r>f', '<C-r>g')"<CR><CR>i#include "<Esc>$xxxahpp"<ESC>0ellv$h"yyggdd<C-o><C-o>:echo "Added: " @y<CR>
	nnoremap ,T <C-]>:let @f=expand("%:p")<CR><C-^>ggO<Esc>O<Esc>"fp0i#include "<Esc>$a"<ESC>0ellv$h"yy<C-o>:echo "Added: " @y<CR>

	vnoremap <C-f> <Esc>:let @s=@<CR>gv"ay:let @"=@s<CR>:grep -R -r -i --include=\*.{cpp,hpp,bdef,ds} --exclude-dir=*/library/local <C-r>a . <CR>:cw<CR>
	
	nnoremap ,b :copen<CR>:AsyncRun! ../../commands.sh bp<CR>
	nnoremap <F8> :copen<CR>:AsyncRun! ../../commands.sh s2<CR>

	set path+=/home/jvandis/projects/rr-tournament/code/client/build/linux/debug/include
	set wildignore+=*/tmp/*,
				\*.so,
				\*.swp,
				\*.zip,
				\*.js,
				\*.mk,
				\*.scala,
				\*.class,
				\*.jar,
				\*.json,
				\*.*~,
				\*/.git/*,
				\*/server,
				\*/scripts,
				\*/tools,
				\*/modules/boost-1.53.0,
				\*/modules/boost_regexp,
				\*/client/build/android,
				\*/client/build/emscripten

	let g:ctrlp_custom_ignore = {
				\ 'dir':  '\.git$\|\.hg$\|\.svn$\|library|configuration$',
				\ 'file': '\v\.(js|json|dll|class|scala|html)$',
				\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
				\ }

	" Edit .agignore for ignore CTRL+p options
	"
 	if executable('ag')
 		let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
 	endif

endif
