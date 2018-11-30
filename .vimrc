" Ned's .vimrc file

filetype off

" Windows thinks personal vim stuff should be in ~/vimfiles, make it look in ~/.vim instead
set runtimepath=~/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,~/.vim/after

set directory-=.                        " Don't store .swp files in the current directory
set updatecount=0                       " Don't create .swp files at all.
if filewritable(expand('~/.backup'))
    set backup backupdir=~/.backup      " Keep copies of files we're editing
endif
set shortmess+=I                        " Don't show the vim intro message
set history=500                         " Keep a LOT of history for commands
set scrolloff=2                         " Keep two lines visible above/below the cursor when scrolling.

set showmatch                           " Blink matching punctuation

set modeline modelines=2                " Read vim settings from the file itself
set encoding=utf-8
set fileformat=unix fileformats=unix,dos
set wildignore=*.o,*~,*.pyc,*.pyo,*\$py.class

set foldmethod=syntax foldlevelstart=999

" Line numbering
set number                              " Turn on line numbering
if exists('+numberwidth')
    set numberwidth=5                   " with space for at least four digits (plus 1 for space)
endif

" mac iTerm2 cursor control for insert mode.
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

set showcmd                             " Show partial commands in the status line
if has("syntax")
    syntax on                           " Turn on syntax coloring
endif
colorscheme nedsterm                    " Color scheme to use for terminals.

if exists('+colorcolumn')
    set colorcolumn=80
endif

set tabstop=8                           " Real tab characters take up 8 spaces
set softtabstop=4                       "   but indent by 4 when typing tab while editing.
set expandtab                           " Use spaces when hitting the tab key
set shiftwidth=4                        "   and shift by 4 spaces when indenting.
set shiftround                          " When indenting, round to a multiple of shiftwidth.
set autoindent                          " Pick the indent for a line from the previous line.
set nosmarttab                          " Tabs always means the same thing, don't be too smart.
set indentkeys=o,O                      " Only new lines should get auto-indented.

filetype plugin indent on               " Use the filetype to load syntax, plugins and indent files.
set autoread                            " Re-read a file if it changed behind vim's back.
set hidden                              " Allow a modified buffer to become hidden.
set nowrap                              " When I want to be confused by wrapped lines, I'll do it manually.
set linebreak                           "   but when I do wrap, I want word wrap, not character.
set showbreak=»\                        "   and show an indicator.
set display=lastline,uhex               " Display as much as possible of a last line, and ctrl chars in hex.
set ignorecase smartcase                " If all lower-case, match any case, else be case-sensitive
set virtualedit=onemore                 " One virtual character at the ends of lines, makes ^V work properly.
set fillchars=vert:\ ,fold:-,diff:·     " Spaces are enough for vertical split separators.
set diffopt=filler,foldcolumn:0,vertical  " Show lines where missing, no need for a foldcolumn during diff, split vertically by default

set noerrorbells                        " Don't ring the bell on errors
set visualbell t_vb=                    "   and don't flash either.
set timeoutlen=1000 ttimeoutlen=50      " Set timeouts so that terminals act briskly.

if exists("+mouse")
    set mouse=a                         " Mice are wonderful.
endif

if exists("+cursorline")
    augroup CursorLine
        autocmd!
        autocmd InsertEnter * set cursorline
        autocmd InsertLeave * set nocursorline
    augroup end
endif

set nrformats=alpha,bin,hex             " Don't infer base 8 when incrementing numbers

""
"" Undo
""

" Adapted from https://gist.github.com/mllg/5353184
function! CleanOldFiles(path, days)
    let l:path = expand(a:path)
    if isdirectory(l:path)
        for file in split(globpath(l:path, "*"), "\n")
            if localtime() > getftime(file) + 86400 * a:days && delete(file) != 0
                echo "CleanOldFiles(): Error deleting '" . file . "'"
            endif
        endfor
    else
        echo "CleanOldFiles(): Directory '" . l:path . "' not found"
    endif
endfunction

if exists("+undofile")
    let my_undodir = $HOME . '/.vimundo'
    if !isdirectory(my_undodir)
        if exists("*mkdir")
            call mkdir(my_undodir)
        endif
    endif
    if isdirectory(my_undodir)
        set undofile undodir=~/.vimundo         " Save undo's after file closes
        set undolevels=1000                     " How many undos
        set undoreload=10000                    " Number of lines to save for undo

        " Remove undo files which have not been modified for 2 days.
        call CleanOldFiles(&undodir, 2)
    endif
endif


""
"" Status line
""

function! StatusEncodingAndFormat()
    let enf = strpart(&fileencoding,0,1) . strpart(&fileformat,0,1)
    if enf == 'uu'
        let enf = ''
    else
        let enf = ' [' . enf . ']'
    endif
    return enf
endfunction

set laststatus=2                        " Always show a status line
let filestatus = ''
let filestatus .= ' %1*%{&readonly ? "" : &modified ? " + " : &modifiable ? "" : " - "}%*'
let filestatus .= '%3*%{&readonly ? (&modified ? " + " : " ∅ ") : ""}%*'
let filestatus .= '%{&readonly? "" : &modified ? "" : &modifiable ? "   " : ""}'
let filestatus .= ' %<%f  '
let filestatus .= '%2*%{tagbar#currenttag(" %s ", "", "f")}%*'
let filestatus .= ' %2*%{fugitive#head(6)}%* '
let filestatus .= '%='
let filestatus .= '%{strlen(&filetype) ? &filetype : "none"}'
let filestatus .= '%{StatusEncodingAndFormat()}'
let filestatus .= ' %2*%l,%c%*'
let filestatus .= ' %P '
let &statusline = filestatus

function! StatusQuickfixTitle()
    let slug = len(getloclist(0)) > 0 ? 'Location' : 'Quickfix'
    let title = '     ' . slug
    if exists('w:quickfix_title')
        let title .= ': '
        let titleparts = split(w:quickfix_title)
        if titleparts[0] =~ 'gerp.py'
            let titleparts[0] = 'gerp'
        endif
        let title .= join(titleparts, '  ')
    else
        let title = ''
    endif
    return title
endfunction

augroup QuickFixSettings
    autocmd!
    autocmd FileType qf let &l:statusline = '%{StatusQuickfixTitle()}%=%l of %L  %P '
    autocmd FileType qf setlocal nobuflisted colorcolumn= cursorline
    autocmd FileType qf nnoremap <silent> <buffer> ,            :colder<CR>
    autocmd FileType qf nnoremap <silent> <buffer> .            :cnewer<CR>
    autocmd FileType qf nnoremap <silent> <buffer> q            :quit\|:wincmd b<CR>
    autocmd FileType qf nnoremap <silent> <buffer> <Leader>c    :cclose<CR>
    " <Leader>a in quickfix means re-do the search.
    autocmd FileType qf nnoremap <expr>   <buffer> <Leader>a    ':<C-U>silent grep! ' . join(split(w:quickfix_title)[1:])
    " <Leader>s means start a new search, but from the same place.
    autocmd FileType qf nnoremap <expr>   <buffer> <Leader>s    ':<C-U>silent grep! ' . split(w:quickfix_title)[1] . ' /'
augroup end

augroup HelpSettings
    autocmd!
    autocmd FileType help let &l:statusline = ' Help: %f%=%P '
    autocmd FileType help setlocal colorcolumn=
    autocmd FileType help nnoremap <silent> <buffer> q :quit<CR>
augroup end

augroup GitCommitSettings
    autocmd!
    " auto-fill paragraphs
    autocmd FileType gitcommit setlocal formatoptions+=a
    autocmd FileType gitcommit DiffGitCached | wincmd r
augroup end

augroup HgCommitSettings
    autocmd!
    autocmd FileType hgcommit setlocal formatoptions+=a
    autocmd BufRead,BufNewFile hg-editor-*.txt set filetype=hgcommit
augroup end

augroup RstSettings
    autocmd!
    autocmd FileType rst setlocal textwidth=79
augroup end

augroup ScssSettings
    autocmd!
    autocmd FileType scss set iskeyword+=-
augroup end

augroup XmlSettings
    autocmd!
    autocmd BufRead,BufNewFile *.px,*.bx set filetype=xml
    " Make plain text in XML be spell-checked.
    autocmd FileType xml syntax spell toplevel
augroup end

augroup IrcSettings
    autocmd!
    autocmd BufRead */log/irc/**/*.log set filetype=irc
    autocmd FileType irc setlocal colorcolumn=
augroup end

" Fix the filetype for various files.
augroup MiscFiletypes
    autocmd!
    autocmd BufNewFile,BufRead *.md set filetype=markdown
    autocmd BufNewFile,BufRead Vagrantfile set filetype=ruby
    autocmd BufNewFile,BufRead setup.cfg set filetype=dosini
    autocmd BufNewFile,BufRead .coveragerc set filetype=dosini
augroup end

augroup FormatStupidity
    autocmd!
    autocmd BufNewFile,BufRead * silent! setlocal formatoptions+=jln
    " ftplugins are stupid and try to mess with indentkeys.
    " Idea from https://github.com/Julian/dotfiles/blob/master/.vimrc
    autocmd BufNewFile,BufRead * setlocal indentkeys=o,O " Only new lines should get auto-indented.
augroup end


if exists('##OptionSet')
    augroup AllFileSettings
        autocmd!
        " Don't want balloons ever. If anyone turns them on, turn them off.
        autocmd OptionSet ballooneval if &ballooneval | set noballooneval | endif
        " Don't want indentkeys ever
        autocmd OptionSet indentkeys set indentkeys=o,O
    augroup end
endif

" Abbreviations
iabbrev pdbxx   import pdb,sys as __sys;__sys.stdout=__sys.__stdout__;pdb.set_trace() # -={XX}=-={XX}=-={XX}=-        
iabbrev pudbxx  import pudb,sys as __sys;__sys.stdout=__sys.__stdout__;pudb.set_trace() # -={XX}=-={XX}=-={XX}=-        
iabbrev staxxx  import inspect;print("\n".join("%30s : %s @%d" % (t[3], t[1], t[2]) for t in inspect.stack()[:0:-1]))          

iabbrev loremx      lorem ipsum quia dolor sit amet consectetur adipisci velit, sed quia non numquam eius modi tempora incidunt.
iabbrev loremxx     lorem ipsum quia dolor sit amet consectetur adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam.
iabbrev loremxxx    lorem ipsum quia dolor sit amet consectetur adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur.

" Digraphs: frown and smile
digraph :( 9785 :) 9786

" ./ in the command line expands to the directory of the current file,
"   but ../ works without an expansion.
cnoremap <expr> ./ getcmdtype() == ':' ? expand('%:p:h').'/' : './'
cnoremap ../ ../

" Highlight conflict markers.
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" Create undo break point when you pause typing for 2 sec.
set updatetime=2000
autocmd CursorHoldI * call feedkeys("\<C-G>u", "nt")

" Terminal-in-vim stuff
if has("terminal")
    tnoremap <Esc> <C-W>N
endif

""
"" Plugins
""

" https://github.com/junegunn/vim-plug
" 'silent!' here to keep it from complaining if there's no "git" installed.
silent! call plug#begin()

Plug 'kshenoy/vim-signature'
let g:SignatureIncludeMarks = 'abcdefghijklmnopqrstuvwxyz'
let g:SignatureMarkerLineHL = 'SignatureMarkLine'

"Plug 'mgedmin/coverage-highlight.vim'
"Plug '~/coverage/coverage-highlight.vim'

Plug 'will133/vim-dirdiff', { 'on': 'DirDiff' }

Plug 'ctrlpvim/ctrlp.vim', { 'on': ['CtrlP', 'CtrlPMRUFiles', 'CtrlPBuffer'] }
noremap <silent> <Leader>e :CtrlP<CR>
noremap <Leader><Leader>e :e<Space>
noremap <silent> <Leader>r :CtrlPMRUFiles<CR>
noremap <silent> <Leader>b :CtrlPBuffer<CR>
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_custom_ignore = {
    \ 'dir': '\v(/htmlcov|/node_modules|/__pycache__|\.egg-info)$',
    \ }
let g:ctrlp_max_files = 0
let g:ctrlp_max_height = 30
let g:ctrlp_mruf_max = 1000
let g:ctrlp_mruf_exclude = '^/private/var/folders/.*\|.*hg-editor-.*\|.*fugitiveblame$'
let g:ctrlp_open_multiple_files = '2vjr'
let g:ctrlp_prompt_mappings = {
    \ 'ToggleType(1)': ['<C-F>', '<C-Up>', ',', '<Space>'],
    \ }
let g:ctrlp_root_markers = ['.treerc']
if executable('rg')
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
endif

Plug 'pearofducks/ansible-vim'
let g:ansible_attribute_highlight = 'ab'    " highlight all attributes, brightly.
let g:ansible_name_highlight = 'd'

Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
if v:version >= 700
    let g:NERDTreeIgnore = [
        \ '\.pyc$', '\.pyo$', '\.pyd$', '\$py\.class$',
        \ '\.o$', '\.so$',
        \ '^__pycache__$', '\.egg-info$',
        \ 'node_modules',
        \ ]
    let g:NERDTreeSortOrder = ['^_.*', '\/$', '*', '\.swp$',  '\.bak$', '\~$']
    let g:NERDTreeShowBookmarks = 0
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeBookmarksSort = 0
    let g:NERDTreeCascadeOpenSingleChildDir = 1
    if has("gui_win32")
        let g:NERDTreeDirArrows = 0
    endif
    noremap <silent> <Leader>f :NERDTreeFind<CR>
else
    " Don't load NERDTree, it will just complain.
    let g:loaded_nerd_tree = 1
endif

noremap <silent> <Leader><Leader>f :let @+ = expand("%:p") \| :echo @+ . " (cwd: " . getcwd() . ")"<CR>

Plug 'scrooloose/nerdcommenter', {
\   'on': [
    \   '<Plug>NERDCommenterComment',
    \   '<Plug>NERDCommenterUncomment'
    \ ]
\ }

" Don't map all the keys
let g:NERDCreateDefaultMappings = 0
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

map <Leader>cc <Plug>NERDCommenterComment
map <Leader>cu <Plug>NERDCommenterUncomment

Plug 'majutsushi/tagbar'                            " Tagbar, no 'on', so that statusbar will have tags
let g:tagbar_width = 40
let g:tagbar_zoomwidth = 30
let g:tagbar_sort = 0                               " sort by order in file
let g:tagbar_show_visibility = 0
let g:tagbar_show_linenumbers = 0
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
let g:tagbar_iconchars = ['+', '-']
nnoremap <silent> <Leader>t :TagbarToggle<CR>

let g:tagbar_type_css = {
\ 'ctagstype' : 'Css',
    \ 'kinds' : [
        \ 'c:classes',
        \ 's:selectors',
        \ 'i:ids',
        \ 't:tags',
        \ 'm:media'
    \ ]
\ }

let g:tagbar_type_html = {
    \ 'ctagstype' : 'html',
    \ 'sort' : 0,
    \ 'kinds' : [
        \ 'h:headings'
    \ ]
\ }

let g:tagbar_type_scss = {
\ 'ctagstype' : 'Scss',
    \ 'kinds' : [
        \ 'c:classes',
        \ 's:selectors',
        \ 'i:ids',
        \ 't:tags',
        \ 'd:media',
        \ 'm:mixins',
        \ 'v:variables'
    \ ]
\ }

Plug 'jszakmeister/rst2ctags'                       " Tag support for .rst files
let g:tagbar_type_rst = {
    \ 'ctagstype': 'rst',
    \ 'ctagsbin': expand('~/.vim/plugged/rst2ctags/rst2ctags.py'),
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

Plug 'mattn/webapi-vim'
Plug 'mattn/gist-vim', { 'on': 'Gist' }
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_post_private = 1

" Plug 'lfv89/vim-interestingwords'
" " This was useful: http://htmlcolorcodes.com/color-chart/
" let g:interestingWordsGUIColors = [
"     \ '#F0C0FF', '#A7FFB7', '#FFB7B7', '#A8D1FF', '#AAFFFF',
"     \ '#FCFA69', '#CCCCCC', '#F39C12', '#D6D450', '#999999',
"     \ '#A569BD', '#27AE60', '#DB5345', '#3E96D1', '#B78264',
"     \ ]
" noremap <silent> <Leader><Leader>k :call RecolorAllWords()<CR>

Plug 't9md/vim-quickhl'
" Highlight the current word.
nmap <silent> <Leader>k <Plug>(quickhl-manual-this)
xmap <silent> <Leader>k <Plug>(quickhl-manual-this)
" Unhighlight all words.
noremap <silent> <Leader>K :QuickhlManualReset<CR>
" Toggle dynamic highlighting of the current word.
nmap <silent> <Leader><Leader>k <Plug>(quickhl-cword-toggle)

let g:quickhl_manual_colors = [
    \ "guibg=#F0C0FF guifg=black",
    \ "guibg=#A7FFB7 guifg=black",
    \ "guibg=#FFB7B7 guifg=black",
    \ "guibg=#A8D1FF guifg=black",
    \ "guibg=#AAFFFF guifg=black",
    \ "guibg=#FCFA69 guifg=black",
    \ "guibg=#CCCCCC guifg=black",
    \ "guibg=#F39C12 guifg=black",
    \ "guibg=#D6D450 guifg=black",
    \ "guibg=#999999 guifg=white",
    \ "guibg=#A569BD guifg=white",
    \ "guibg=#27AE60 guifg=white",
    \ "guibg=#DB5345 guifg=white",
    \ "guibg=#3E96D1 guifg=white",
    \ "guibg=#B78264 guifg=white",
    \ ]

" https://github.com/inkarkat/vim-mark could be a replacement for quickhl

Plug 'vim-python/python-syntax'
let g:python_highlight_class_vars = 1
let g:python_highlight_string_formatting = 1
let g:python_highlight_string_format = 1
let g:python_highlight_string_templates = 1
let g:python_highlight_indent_errors = 1
let g:python_highlight_space_errors = 0
let g:python_highlight_doctests = 1

let g:pyindent_open_paren = 'shiftwidth()'
let g:pyindent_nested_paren = 'shiftwidth()'
let g:pyindent_continue = 'shiftwidth()'

Plug 'tpope/vim-fugitive'                           " No 'on': it's in the statusbar
autocmd FileType git noremap <silent> <buffer> <Leader><Leader>f :let @+ = fugitive#Object(@%) \| :echo @+<CR>

Plug 'tpope/vim-rhubarb'                            " GitHub support for fugitive
noremap <Leader>gb :Gblame<CR>
noremap <Leader>gu :Gbrowse!<CR>
noremap <Leader>gv :Gbrowse<CR>

Plug 'tpope/vim-git'                                " Git filetypes, etc.
"Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'

Plug 'kana/vim-textobj-user'
Plug 'Julian/vim-textobj-variable-segment'
Plug 'kana/vim-textobj-line'                        " Whole-line text object
Plug 'kana/vim-textobj-fold'                        " Manual-fold text object
Plug 'qstrahl/vim-dentures'                         " Indent-based text object
"Plug 'vim-utils/vim-space'                          " Space text object: di<Space>
Plug 'nedbat/vim-space', { 'branch': 'patch-1' }    " get my fix for end-of-virtual-line
Plug 'wellle/targets.vim'                           " Lots of improvements to text objects

Plug 'wellle/visual-split.vim'
noremap <Leader>* :VSSplit<CR>
noremap <Leader><Leader>* :VSResize<CR>

" Plug 'gregsexton/MatchTag'                          " Highlights paired HTML tags
" Plug 'Valloric/MatchTagAlways'                      " Highlights paired HTML tags
Plug 'andymass/vim-matchup', { 'for': ['html', 'xhtml', 'xml'] }
let g:matchup_matchparen_status_offscreen = 0

Plug 'junegunn/vim-peekaboo'                        " Pop-up panel to show registers
let g:peekaboo_window = 'vertical botright 50new'
let g:peekaboo_delay = 750

Plug 'atimholt/spiffy_foldtext'
let g:SpiffyFoldtext_format = "%c %<%f{ }« %n »%l{==}"

Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plug 'hail2u/vim-css3-syntax', { 'for': ['css', 'scss'] }
"Plug 'trapd00r/irc.vim', { 'for': 'irc' }
Plug 'nedbat/irc.vim', { 'for': 'irc' }

Plug 'sk1418/QFGrep'                                " Filter quickfix: \g \v \r

Plug 'editorconfig/editorconfig-vim'                " Obey .editorconfig files
let g:EditorConfig_preserve_formatoptions = 1

Plug 'bogado/file-line'                             " Enables opening and jumping to line with: foo.txt:345

" Ctrl-A, Ctrl-E, etc, when typing.
Plug 'tpope/vim-rsi'

Plug 'szw/vim-maximizer', { 'on': 'MaximizerToggle' }   " Maximize current split
noremap <Leader>= :MaximizerToggle!<CR>

" Display more information with ga
Plug 'manicmaniac/betterga'
let g:betterga_template = '<{ci.char}> "{ci.name}" ({ci.category}) {ci.ord} {ci.hex}'

" JavaScript niceness
Plug 'pangloss/vim-javascript'                      " Basic JavaScript highlighting
Plug 'mxw/vim-jsx'                                  " Support jsx for React
let g:jsx_ext_required = 0

Plug 'luochen1990/rainbow'                          " Parens in multiple colors
let g:rainbow_active = 1
let g:rainbow_conf = {
\   'guifgs': ['royalblue3', 'darkorange3', 'seagreen4', 'firebrick'],
\   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
\   'operators': '_,_',
\   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
\   'separately': {
\       '*': {},
\       'lisp': {
\           'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
\       },
\       'tex': {
\           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
\       },
\       'vim': {
\           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
\       },
\       'xml': {
\           'parentheses': ['start=/\v\<\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'))?)*\>/ end=#</\z1># fold'],
\           'operators': '',
\       },
\       'xhtml': {
\           'parentheses': ['start=/\v\<\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'))?)*\>/ end=#</\z1># fold'],
\           'operators': '',
\       },
\       'html': {
\           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
\           'operators': '',
\       },
\       'htmldjango': 0,
\       'php': {
\           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold', 'start=/(/ end=/)/ containedin=@htmlPreproc contains=@phpClTop', 'start=/\[/ end=/\]/ containedin=@htmlPreproc contains=@phpClTop', 'start=/{/ end=/}/ containedin=@htmlPreproc contains=@phpClTop'],
\       },
\       'css': 0,
\       'irc': 0,
\       'sh': {
\           'parentheses': [['\(^\|\s\)\S*()\s*{\?\($\|\s\)','_^{_','}'], ['\(^\|\s\)if\($\|\s\)','_\(^\|\s\)\(then\|else\|elif\)\($\|\s\)_','\(^\|\s\)fi\($\|\s\)'], ['\(^\|\s\)for\($\|\s\)','_\(^\|\s\)\(do\|in\)\($\|\s\)_','\(^\|\s\)done\($\|\s\)'], ['\(^\|\s\)while\($\|\s\)','_\(^\|\s\)\(do\)\($\|\s\)_','\(^\|\s\)done\($\|\s\)'], ['\(^\|\s\)case\($\|\s\)','_\(^\|\s\)\(\S*)\|in\|;;\)\($\|\s\)_','\(^\|\s\)esac\($\|\s\)']],
\       },
\   }
\}

" Open URLs, because netrw's gx is broken: https://github.com/vim/vim/issues/1386
Plug 'dhruvasagar/vim-open-url'
nmap gx <Plug>(open-url-browser)
xmap gx <Plug>(open-url-browser)

" Highlight the effect of commands as you type them.
Plug 'markonm/traces.vim'

call plug#end()

" Plugins I tried but didn't end up actually using:
"
"   Plug 'AndrewRadev/splitjoin.vim'                    " gS and gJ for smart expanding and contracting
"   let g:splitjoin_trailing_comma = 1
"   let g:splitjoin_python_brackets_on_separate_lines = 1
"
"   " cx{motion} - cx{motion} to swap things
"   Plug 'tommcdo/vim-exchange'
"   Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }  " Display undotree
"
"   " +/- auto-expand-contract selected region.
"   Plug 'terryma/vim-expand-region'
"   map + <Plug>(expand_region_expand)
"   map - <Plug>(expand_region_shrink)
"
"   " Better highlighting of searches
"   Plug 'fcpg/vim-spotlightify'
"   let g:splfy_keephls = 1         " Keep the highlights even after moving away from the match
"
"   " People love it, but I don't get it.
"   if isdirectory('/usr/local/opt/fzf')
"       Plug '/usr/local/opt/fzf'
"       Plug 'junegunn/fzf.vim'
"   endif


""
"" Custom functions
""

" Run a command, but keep the output in a buffer.
command! -nargs=+ -complete=command Bout call <SID>BufOut(<q-args>)
function! <SID>BufOut(cmd)
    redir => output
    silent execute a:cmd
    redir END
    if empty(output)
        echoerr "no output"
    else
        new
        setlocal buftype=nofile bufhidden=wipe noswapfile nomodified
        execute('file \[Scratch '.bufnr('%').': '.a:cmd.' \]')
        silent put =output
    endif
endfunction

" Don't close window, when deleting a buffer
" from: https://github.com/amix/vimrc/blob/master/vimrcs/basic.vim
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

" From https://github.com/Julian/dotfiles/blob/master/.vimrc
command! DiffThese call <SID>DiffTheseCommand()
function! <SID>DiffTheseCommand()
    if &diff
        diffoff!
    else
        diffthis

        let window_count = tabpagewinnr(tabpagenr(), '$')
        if window_count == 2
            wincmd w
            diffthis
            wincmd w
        endif
    endif
endfunction
nnoremap <Leader>d :<C-U>DiffThese<CR>

" From https://github.com/garybernhardt/dotfiles/blob/master/.vimrc
command! RemoveFancyCharacters :call <SID>RemoveFancyCharacters()
function! <SID>RemoveFancyCharacters()
    let typo = {}
    let typo["“"] = '"'
    let typo["”"] = '"'
    let typo["‘"] = "'"
    let typo["’"] = "'"
    "let typo["–"] = '--'
    let typo["—"] = '--'
    let typo["…"] = '...'
    execute ":%s/".join(keys(typo), '\|').'/\=typo[submatch(0)]/ge'
endfunction

" Show the syntax highlight group for the current character.
" Even better: https://gist.github.com/mcantor/7bff61685e8b17acee56d977b025a705
" from https://github.com/mcantor/dotfiles/blob/master/vim/.vimrc#L604-L646
map <silent><Leader>h :echo
\ "hi=" . synIDattr(synID(line("."),col("."),1),"name") .
\ " trans=" . synIDattr(synID(line("."),col("."),0),"name") .
\ " lo=" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")<CR>
map <silent><Leader><Leader>h :source $VIMRUNTIME/syntax/hitest.vim<CR>

" Shortcuts to things I want to do often.
noremap <Leader>p gwap
noremap <Leader><Leader>p gw}
nnoremap coa :setlocal <C-R>=(&formatoptions =~# "a") ? 'formatoptions-=a' : 'formatoptions+=a'<CR><CR>

noremap <Leader>q :quit<CR>
noremap <Leader><Leader>q :Bclose<CR>
noremap <Leader>w :<C-U>write<CR>
noremap <Leader><Leader>w :<C-U>wall<CR>
noremap <Leader>x :exit<CR>

noremap <Leader>2 :setlocal shiftwidth=2 softtabstop=2<CR>
noremap <Leader>4 :setlocal shiftwidth=4 softtabstop=4<CR>
noremap <Leader>8 :setlocal shiftwidth=8 softtabstop=8<CR>

" zM is close-all-folds, but I can never remember it.
nnoremap z0 zM
nnoremap z* zR

" Toggle list mode to see special characters.
set listchars=tab:→‐,trail:◘,nbsp:␣,eol:¶
" space was added in 7.4.710
silent! set listchars+=space:·

" Show only one window on the screen, but keep the explorers open.
noremap <silent> <Leader>1 :only!\|:NERDTreeToggle\|:vertical resize 30\|:wincmd b<CR>
noremap <silent> <Leader><Leader>1 :only!<CR>

" More intuitive splits.
nnoremap <Leader>_ <C-W>s
nnoremap <Leader><Bar> <C-W>v
nnoremap <Leader><Leader>_ :only!<CR><C-W>s
nnoremap <Leader><Leader><Bar> :only!<CR><C-W>v
autocmd VimResized * :wincmd =

" Selecting things: last modified text (good for after pasting); everything.
noremap <Leader>v `[v`]
noremap <Leader><Leader>v ggVG
noremap <Leader><Leader>y :%y<CR>

" Adapted from https://gist.github.com/dahu/6ff4de11ca9c5bb25902
" Toggle colorcolumn..
"   .. at start of line
nnoremap <silent> <Leader>i :exe "normal m`^\<Leader>\<Leader>i``"<CR>
"   .. at cursor
nnoremap <silent> <Leader><Leader>i :exe 'set cc'.(&cc =~ virtcol('.')?'-=':'+=').virtcol('.')<CR>

" Backspace and cursor keys wrap to previous/next line.
set backspace=indent,eol,start
set whichwrap+=<,>,[,]
set t_kb=                           " Use the delete key for backspace (the blot is ^?)

" Indenting in visual mode keeps the visual highlight.
xnoremap < <gv
xnoremap > >gv
" Indent in visual, but don't adjust relative indents in the block.
xnoremap <Leader>< <Esc>:setlocal noshiftround<CR>gv<:setlocal shiftround<CR>gv
xnoremap <Leader>> <Esc>:setlocal noshiftround<CR>gv>:setlocal shiftround<CR>gv

" Remove annoying F1 help.
inoremap <F1> <Nop>
nnoremap <F1> <Nop>
vnoremap <F1> <Nop>

" Jump to start and end of line using the home row keys.
nnoremap H ^
xnoremap H ^
nnoremap L $
xnoremap L $

noremap <silent> <C-PageUp>     :bprevious<CR>
noremap <silent> <C-PageDown>   :bnext<CR>
noremap <silent> <C-Tab>        <C-W><C-W>

" Control-H etc navigate among windows.
nnoremap <C-H> <C-W>h
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l

" Easier sizing of windows.
nnoremap <Leader>[ <C-W>-
nnoremap <Leader><Leader>[ 20<C-W>-
nnoremap <Leader>] <C-W>+
nnoremap <Leader><Leader>] 20<C-W>+
nnoremap <Leader>{ <C-W><
nnoremap <Leader><Leader>{ 20<C-W><
nnoremap <Leader>} <C-W>>
nnoremap <Leader><Leader>} 20<C-W>>

" Windows-style ctrl-up and ctrl-down: scroll the text without moving cursor.
noremap <C-Up> <C-Y>
noremap <C-Down> <C-E>
inoremap <silent> <C-Up>    <C-O><C-Y>
inoremap <silent> <C-Down>  <C-O><C-E>

inoremap <silent> <C-BS>    <C-O>db
inoremap <silent> <C-Del>   <C-O>dw

cnoremap <C-BS> <C-W>

noremap <silent> <PageUp>   <C-U>
noremap <silent> <PageDown> <C-D>

" backspace in Visual mode deletes selection
vnoremap <BS> d
" CTRL-X is Cut
vnoremap <C-X> "+x
" CTRL-C is Copy
vnoremap <C-C> "+y
" CTRL-V is Paste
noremap <C-V> "+gP
inoremap <C-V> <C-O>"+gP
cnoremap <C-V> <C-R>+

" Quick escape-and-save from insert mode.
inoremap <silent> jj <Esc>:update<CR>
inoremap <silent> jJ <Esc>:update<CR>
inoremap <silent> qqj <C-O>:update<CR>
" Quick one-command escape from insert mode.
inoremap qqo <C-O>
inoremap qqp <C-O>gwap

" Allow undoing <C-U> (delete text typed in the current line)
inoremap <C-U> <C-G>u<C-U>

" Easier access to completions
inoremap <C-L> <C-X><C-L>
inoremap <C-N> <C-X><C-N>
inoremap <C-P> <C-X><C-P>

" Use CTRL-Q to do what CTRL-V used to do
noremap <C-Q> <C-V>

" Searching
set incsearch                           " Use incremental search
set hlsearch                            " Highlight search results in the file.
nnoremap <Leader>n nzvzz
nnoremap <Leader>N Nzvzz
" <C-L> was redraw, make it \z
nnoremap <Leader>z :nohlsearch<CR><C-L>
nnoremap <Leader><Leader>z :nohlsearch<CR>zvzz<C-L>

" My own crazy grep program
set grepprg=~/bin/gerp.py

function! RunGrep(word)
    call inputsave()
    let l:cmdline = input('gerp /', a:word)
    call inputrestore()
    if l:cmdline == ''
        echo "No pattern entered, search aborted."
    else
        " Create the gerp command line.
        let l:words = split(l:cmdline)
        let l:pattern = shellescape(substitute(l:words[0], '[%#]', '\\&', 'g'))
        let l:options = join(l:words[1:])
        execute ':silent grep! % /' . l:pattern . ' ' . l:options
        " Force recalculation of all the buffer names. This makes the results
        " uniform in terms of absolute/relative pathnames.
        silent cd .
        " rg returns results non-contiguously
        call QfSortEntries()
        botright copen
    endif
endfunction

" Inspired by https://github.com/jboner/vim-config/blob/master/autoload/l9/quickfix.vim#L62-L82
" Compares quickfix entries for sorting.
function! QfCompareEntries(e0, e1)
    if a:e0.bufnr != a:e1.bufnr
        let i0 = bufname(a:e0.bufnr)
        let i1 = bufname(a:e1.bufnr)
    elseif a:e0.lnum != a:e1.lnum
        let i0 = a:e0.lnum
        let i1 = a:e1.lnum
    elseif a:e0.col != a:e1.col
        let i0 = a:e0.col
        let i1 = a:e1.col
    else
        return 0
    endif
    return (i0 > i1 ? +1 : -1)
endfunction

" Sorts quickfix
function! QfSortEntries()
    " Grab the window title, restore it later. setqflist() clobbers the title.
    let l:info = getqflist({'title': 1})
    call setqflist(sort(getqflist(), 'QfCompareEntries'), 'r')
    call setqflist([], 'r', l:info)
endfunction

noremap <Leader>s :call RunGrep('')<CR>
nnoremap <Leader>a :call RunGrep('<C-R><C-W>')<CR>
xnoremap <Leader>a y:call RunGrep(substitute(@", ' ', '.', 'g'))<CR>
nnoremap <silent> <Leader>c :botright copen<CR>

" Adapted from:
" Barry Arthur 2014 06 25 Jump to the last cursor position in a File Jump
function! FileJumpLastPos(jump_type)
    let jump_mark = nr2char(getchar())
    let the_jump = a:jump_type . jump_mark
    if jump_mark =~# '[A-Z]'
        let the_jump .= "'\""
    endif
    return the_jump
endfunction

nnoremap <expr> ' FileJumpLastPos("'")
nnoremap <expr> ` FileJumpLastPos("`")

nnoremap gj j
nnoremap gk k
nnoremap j gj
nnoremap k gk

" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$

" qq to record, Q to replay (thanks, junegunn)
nnoremap Q @q
xnoremap Q @q

runtime macros/matchit.vim

" Figure out if Python is properly configured.
try
    python 1+1
    let python_works = 1
catch /^Vim\%((\a\+)\)\=:E/ 
    let python_works = 0
endtry

" Custom formatters
if python_works
    python << EOF_PY
import json, vim, sys

def pretty_xml(x):
    """Make xml string `x` nicely formatted."""
    # Hat tip to http://code.activestate.com/recipes/576750/
    import xml.dom.minidom as md
    new_xml = md.parseString(x.strip()).toprettyxml(indent=' '*2)
    return '\n'.join([line for line in new_xml.split('\n') if line.strip()])

def pretty_json(j):
    """Make json string `j` nicely formatted."""
    return json.dumps(json.loads(j), sort_keys=True, indent=4)

prettiers = {
    'xml':  pretty_xml,
    'json': pretty_json,
    }

def pretty_it(datatype):
    r = vim.current.range
    content = "\n".join(r)
    content = prettiers[datatype](content)
    r[:] = str(content).split('\n')
EOF_PY

    command! -range=% Pxml :python pretty_it('xml')
    command! -range=% Pjson :python pretty_it('json')
endif
