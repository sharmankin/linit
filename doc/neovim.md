# Neovim
## Prepare
```bash

RELEASE="$(grep -RPho '(?<=\bNAME=").*?(?=")' -R /etc/*-release)"
case ${RELEASE} in
  "Ubuntu")
        sudo apt purge vim vim-nox vim-tiny --autoremove -y
        sudo apt install python3-{dev,pip,venv} curl build-essential \
          cmake ninja-build gettext unzip software-properties-common \
          git -y --no-install-recommends
        ;;
  "Rocky Linux")
        sudo dnf remove vim{,-minimal} python3-neovim -yq
        sudo dnf install gcc-c++ make cmake ShellCheck git ninja-build -yq --setopt=install_weak_deps=False
        sudo dnf install python3-{virtualenv,wheel,pip,devel,jedi} --setopt=install_weak_deps=False -y
      ;;
esac

```
## Install
```bash
src_dir="/opt/neovim"

rm -rf "${src_dir}"
mkdir -p "${src_dir}"

rm -f $(which nvim)

git clone https://github.com/neovim/neovim.git "${src_dir}" && {
cd "${src_dir}"
} || exit ${LINENO}

git checkout stable -q

make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr" -j "$(nproc)" || {
printf '\e[1;31m%s\e[0m\n' "Error on compile"
exit ${LINENO}
}

sudo make install
cd -

nvim_binary="$(which nvim)"

for alternative in vi vim; do
  update-alternatives --install /usr/bin/$alternative $alternative "${nvim_binary}" 100
  update-alternatives --set $alternative "${nvim_binary}"
done
update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 1000
```
## Config
```bash
PYTHON_VERSION='3.11'

vim_conf_dir="${HOME}/.config/nvim"

rm -rf "${vim_conf_dir}"
mkdir -p "${vim_conf_dir}"

vimrc="${vim_conf_dir}/init.vim"

python_bin=$(which python${PYTHON_VERSION}) || exit 222

${python_bin} -m pip install --user pynvim --upgrade --no-cache-dir 2>/dev/null

curl -sfL https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
  -o "${vim_conf_dir}"/autoload/plug.vim --create-dirs

tee "${vimrc}" <<EOF
set tabstop=4
set shiftwidth=4
set expandtab
set mouse=a
set number
set wrap
set linebreak
set hidden
set showmatch
set showcmd
set autoread
set confirm
set noshowmode
set t_Co=256
if isdirectory(\$HOME . '/.vim/backup') == 0
    :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
endif

if &term =~ '256color'
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color GNU screen.
  set t_ut=
endif

set backupdir-=.
set backupdir+=.
set backupdir-=~/
set backupdir^=~/.vim/backup/
set backupdir^=./.vim-backup/
set backup

if isdirectory(\$HOME . '/.vim/swap') == 0
    :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set directory=./.vim-swap//
set directory+=~/.vim/swap//
set directory+=~/tmp//
set directory+=.

if exists("+undofile")
    if isdirectory(\$HOME . '/.vim/undo') == 0
        :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
    endif
    set undodir=./.vim-undo//
    set undodir+=~/.vim/undo//
    set undofile
endif
filetype plugin indent on
autocmd! bufwritepost \$MYVIMRC source \$MYVIMRC
syntax on
set browsedir=current
set visualbell
set undolevels=2048
set smartindent
set foldmethod=syntax
set cul
hi CursorLine term=none cterm=none ctermbg=235
set infercase
set encoding=utf-8
set termencoding=utf-8
set fileformat=unix
set hlsearch
set incsearch

call plug#begin("${vim_conf_dir}/plugged")
    Plug 'Valloric/YouCompleteMe', { 'dir': '${vim_conf_dir}/plugged/YouCompleteMe', 'do': '${python_bin} install.py --force-sudo' }
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all 2>&1 > /dev/null' }
    Plug 'neomake/neomake'
    Plug 'eiginn/netrw'
    Plug 'tpope/vim-eunuch'
    Plug 'olimorris/onedarkpro.nvim'
    Plug 'farmergreg/vim-lastplace'
    Plug 'airblade/vim-gitgutter'
call plug#end()

"call neomake#configure#automake('rw', 500)

"colorscheme onedark_vivid
"let g:gitgutter_max_signs = -1
"let g:airline#extensions#tabline#formatter = 'unique_tail'
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'
"let g:airline_theme = 'onedark'
"let g:netrw_altv = 1
"let g:netrw_browse_split = 4
"let g:netrw_liststyle = 3
"let g:netrw_banner = 0
"let g:lastplace_ignore = "gitcommit,gitrebase,svn,hgcommit"
"let g:lastplace_ignore_buftype = "quickfix,nofile,help"
"let g:lastplace_open_folds = 0
let g:python3_host_prog = '${python_bin}'

nmap <F2> :SudoWrite<CR>
vmap <F2> <Esc> :SudoWrite<CR>
imap <F2> <Esc> :SudoWrite<CR>

nmap <F3> :SudoEdit<CR>
vmap <F3> <Esc> :SudoEdit<CR>
imap <F3> <Esc> :SudoEdit<CR>

nmap <F4> :Chmod -x<CR>
vmap <F4> <Esc> :Chmod -x<CR>v
imap <F4> <Esc> :Chmod -x<CR>i

nmap <F4><F4> :Chmod +x<CR>
vmap <F4><F4> <Esc> :Chmod +x<CR>v
imap <F4><F4> <Esc> :Chmod +x<CR>i

nmap <F9> :set mouse=a number<CR>
vmap <F9> <Esc> :set mouse=a<CR>v
imap <F9> <Esc> :set mouse=a<CR>i

nmap <F9><F9> :set mouse= nonumber<CR>
vmap <F9><F9> <Esc> :set mouse=<CR>v
imap <F9><F9> <Esc> :set mouse=<CR>i
EOF

nvim +PlugInstall +qall

sed -ri '/neomake|airline|netrw|colorscheme|lastplace|gitgutter/s/^"//' "${vimrc}"
```