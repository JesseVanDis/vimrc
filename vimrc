
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
			silent let $cloneCmd = "git clone https://" . $gitusr . ":" . $gitpass . "@github.com/JesseVanDis/vimrc.git " . $vimrcsync_gitfolder
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

" silent !dpkg -s build-essential 2>/dev/null >/dev/null || sudo apt-get install build-essential
" silent !dpkg -s python-dev 2>/dev/null >/dev/null || sudo apt-get install python-dev
" silent !dpkg -s python3-dev 2>/dev/null >/dev/null || sudo apt-get install python3-dev
" silent !dpkg -s cscope 2>/dev/null >/dev/null || sudo apt-get install cscope
" " TODO: Use universal Ctags
" silent !dpkg -s exuberant-ctags 2>/dev/null >/dev/null || sudo apt-get install exuberant-ctags
" silent !dpkg -s silversearcher-ag 2>/dev/null >/dev/null || sudo apt-get install silversearcher-ag
" " NeoVim
" silent !dpkg -s qtbase5-dev 2>/dev/null >/dev/null || sudo apt-get install qtbase5-dev
" " Javascript
" silent !dpkg -s python3-pip 2>/dev/null >/dev/null || sudo apt-get install python3-pip
" if !isdirectory(pythonDir . "/neovim")
" 	" this command is a bit slow... (that why we just first check the folder which is simply faster
" 	silent !pip3 list --format=legacy | grep -F neovim || pip3 install neovim
" endif


" function InstallCmake()
" 	if !isdirectory($HOME . "/.vim/cmake")
" 	 	silent !mkdir -p ~/.vim/cmake
" 	 	silent !echo "mkdir -p ~/.vim/cmake/cmakegit" > ~/.vim/cmake/clonesetup.sh
" 	 	silent !echo "cd ~/.vim/cmake/cmakegit" >> ~/.vim/cmake/clonesetup.sh
" 		silent !echo "wget https://cmake.org/files/v3.12/cmake-3.12.2.tar.gz" >> ~/.vim/cmake/clonesetup.sh
" 		silent !echo "tar -xvzf cmake-3.12.2.tar.gz" >> ~/.vim/cmake/clonesetup.sh
" 		silent !echo "cd ./cmake-3.12.2/" >> ~/.vim/cmake/clonesetup.sh
" 		silent !echo "./bootstrap --system-curl" >> ~/.vim/cmake/clonesetup.sh
" 		silent !echo "make" >> ~/.vim/cmake/clonesetup.sh
" 		silent !echo "sudo make install" >> ~/.vim/cmake/clonesetup.sh
" 	 	silent !chmod +x ~/.vim/cmake/clonesetup.sh
" 	 	silent !xterm -e ~/.vim/cmake/clonesetup.sh
" 	 	:redraw!
" 	endif
" endfunction
" call InstallCmake()


" function InstallNeoVimQt()
" 	if !isdirectory($HOME . "/.vim/neovimqt")
" 	 	silent !mkdir -p ~/.vim/neovimqt
" 	 	silent !echo "mkdir -p ~/.vim/neovimqt/neovim-qt" > ~/.vim/neovimqt/clonesetup.sh
" 	 	silent !echo "git clone https://github.com/equalsraf/neovim-qt ~/.vim/neovimqt/neovim-qt" >> ~/.vim/neovimqt/clonesetup.sh
" 	 	silent !echo "mkdir -p ~/.vim/neovimqt/neovim-qt/build" >> ~/.vim/neovimqt/clonesetup.sh
" 	 	silent !echo "cd ~/.vim/neovimqt/neovim-qt/build" >> ~/.vim/neovimqt/clonesetup.sh
" 	 	silent !echo "cmake -DCMAKE_BUILD_TYPE=Release .." >> ~/.vim/neovimqt/clonesetup.sh
" 	 	silent !echo "make" >> ~/.vim/neovimqt/clonesetup.sh
" 	 	silent !echo "sudo make install" >> ~/.vim/neovimqt/clonesetup.sh
" 	 	silent !chmod +x ~/.vim/neovimqt/clonesetup.sh
" 	 	silent !xterm -e ~/.vim/neovimqt/clonesetup.sh
" 	 	:redraw!
" 	endif
" endfunction
" call InstallNeoVimQt()


" function InstallJavascriptStuff()
" 	" Javascript stuff TODO: tedect javascript files
" 	silent !dpkg -s npm 2>/dev/null >/dev/null || sudo apt-get install npm
" 	if !isdirectory('../node_modules')
" 		" ToDeleteAll: sudo npm ls -gp --depth=0 | sudo awk -F/ '/node_modules/ && !/\/npm$/ {print $NF}' | sudo xargs npm -g rm
" 		" silent !npm init -f
" 		silent !echo "current dir:"
" 		silent !echo $(pwd)
" 		silent !{ cd ../; npm init -f; }
" 		silent !npm list --depth 1 --global eslint > /dev/null 2>&1 || sudo npm install "eslint@>=5.0.0-alpha.2" -g
" 		silent !npm list --depth 1 --global eslint-plugin-import > /dev/null 2>&1 || sudo npm install "eslint-plugin-import@>=2.8.0" -g
" 		silent !npm list --depth 1 --global eslint-plugin-node > /dev/null 2>&1 || sudo npm install "eslint-plugin-node@>=5.2.1" -g
" 		silent !npm list --depth 1 --global eslint-plugin-promise > /dev/null 2>&1 || sudo npm install "eslint-plugin-promise@>=3.6.0" -g
" 		silent !npm list --depth 1 --global eslint-plugin-standard > /dev/null 2>&1 || sudo npm install "eslint-plugin-standard@>=3.0.1" -g
" 		silent !npm list --depth 1 --global eslint-config-standard > /dev/null 2>&1 || sudo npm install eslint-config-standard -g
" 		" eslint-config-standard@12.0.0-alpha.0 
" 		silent !echo "__________________________________________________"
" 		silent !echo "  Use: populair -> standard -> javascript -> yes  "
" 		silent !echo "--------------------------------------------------"
" 		silent !{ cd ../; eslint --init; }
" 	endif
" endfunction
" autocmd BufNewFile *.js call InstallJavascriptStuff() 


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
" Plug 'fatih/vim-go'
" Plug 'easymotion/vim-easymotion'
" Plug 'skywind3000/asyncrun.vim'

" cpp
" Plug 'oblitum/YouCompleteMe'

" javascript
" Plug 'Shougo/deoplete.nvim', {'for': 'javascript'}
" Plug 'roxma/nvim-yarp', {'for': 'javascript'}
" Plug 'roxma/vim-hug-neovim-rpc', {'for': 'javascript'}
" Plug 'w0rp/ale', {'for': 'javascript'}

" Theme
"" Plug 'fatih/molokai'
"" Plug 'colepeters/spacemacs-theme.vim'
Plug 'lifepillar/vim-solarized8'
Plug 'jonathanfilip/vim-lucius'

call plug#end()

" filetype plugin indent on
" set nocompatible


" " Build youcompleteme
" if isdirectory($HOME . '/.vim/bundle/youcompleteme')
" 	if !isdirectory($HOME . '/.vim/bundle/youcompleteme_didbuild')
" 		silent !cd ~/.vim/bundle/youcompleteme && ./install.py --clang-completer
" 		silent !mkdir -p ~/.vim/bundle/youcompleteme_didbuild
" 	endif
" endif

" " Build youcompleteme ( oblitum fork )
" if isdirectory($HOME . '/.vim/bundle/YouCompleteMe')
" 	if !isdirectory($HOME . '/.vim/bundle/YouCompleteMe_didbuild')
" 		silent !cd ~/.vim/bundle/YouCompleteMe && ./install.py --clang-completer
" 		silent !mkdir -p ~/.vim/bundle/YouCompleteMe_didbuild
" 	endif
" endif

" Build youcompleteme ( vim-plug )
" if isdirectory($HOME . '/.vim/plugged/YouCompleteMe')
" 	if !isdirectory($HOME . '/.vim/plugged/YouCompleteMe_didbuild')
" 		silent !cd ~/.vim/plugged/YouCompleteMe && ./install.py --clang-completer
" 		silent !mkdir -p ~/.vim/plugged/YouCompleteMe_didbuild
" 	endif
" endif

" Instal vim proc for golang debugging
" if isdirectory($HOME . '/.vim/bundle/vimproc.vim')
"     silent !cd ~/.vim/bundle/vimproc.vim && make
" endif


" extention mapping
au BufNewFile,BufRead *.locatext set filetype=xml


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

" .======================================.
" ||            MAPPINGS                ||
" '======================================'


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

" search for selected text
vmap * "ty/<C-r>t<CR>v//e<CR>
vmap # "ty?<C-r>t<CR>v//e<CR>

" Switch windows
nmap <silent> <S-Up> :wincmd k<CR>
nmap <silent> <S-Down> :wincmd j<CR>
nmap <silent> <S-Left> :wincmd h<CR>
nmap <silent> <S-Right> :wincmd l<CR>


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



autocmd InsertEnter,InsertLeave * set cul!   " Indicate insert mode by changing selected line layout

" set background=light
colorscheme lucius
LuciusWhite

if has('gui_running')
  set guifont=Monospace\ 11
endif


hi MatchParen      ctermfg=208 ctermbg=233 cterm=bold 



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

" disable spellcheck
set nospell


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





