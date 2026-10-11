" begin switch settings for emapach paltform
let s:myMacIMControl = 0
let s:myMacIMDisable = 0
let s:myMacIMRestore = 1
let s:mySKKControl   = 0
let s:myMatchParen   = 1
let s:myMatchBySign  = 1
if has('mac')
	if has('gui_macvim') && has('gui_running')
		let s:myMacIMControl = 1
"		I gave up as temporaly to restore IM state when re-enter insert mode
		let s:myMacIMRestore = 0
	else 
		let s:mySKKControl   = 1
		let s:myMacIMDisable = 1
	endif
elseif has('linux')
	if isdirectory(expand('~/.eskk'))
		let s:mySKKControl = 1
	endif
endif
" end switch settings for each paltform

" settings for text formatting by gq
set textwidth=64
set formatoptions+=mM
set formatoptions-=t
set formatoptions-=c

" begin settings for MacVim
if has('gui_macvim') && has('gui_running')
	set macmeta
	set lines=60
	set columns=120
" these are not working on the macOS version?
"set iminsert=2
"set imsearch=2
endif
" end settings for MacVim

set	ff=unix

nnoremap	;	q:
nnoremap	Y	ma1GVGy'a
nnoremap	`	:ls:buffer
nnoremap <silent> W :<C-u>execute 'set ts=' . nr2char(getchar()) . ' sw=0'<CR>


" nnoremap	<C-f>	l
" nnoremap	<C-b>	h

" meta + key moving


function! s:setupMKeys()
"	timeout setting
"	1. enable timeout/ttimeout
	set timeout
	set ttimeout

"	2. normal timeout set to same as default
	set timeoutlen=1000

	" 3. timeout for Esc
	set ttimeoutlen=50

	execute "set <M-w>=\<Esc>w"
	execute "set <M-p>=\<Esc>p"
	execute "set <M-n>=\<Esc>n"
	nnoremap	<M-w>	<C-w>
	nnoremap	<M-w><M-w>	<C-w><C-w>
	nnoremap	<M-p>	:bp
	nnoremap	<M-n>	:bn

"	alternative cursor navigation w/ meta-key
	execute "set <M-h>=\<Esc>h"
	execute "set <M-j>=\<Esc>j"
	execute "set <M-k>=\<Esc>k"
	execute "set <M-l>=\<Esc>l"
	execute "set <M-f>=\<Esc>f"
	execute "set <M-b>=\<Esc>b"
	nnoremap	<M-h>	h
	nnoremap	<M-j>	j
	nnoremap	<M-k>	k
	nnoremap	<M-l>	l
	nnoremap	<M-f>	<C-f>
	nnoremap	<M-b>	<C-b>
"	use 'map' instead of 'nnoremap'
"	because I'd like to use smoothie facilities
	execute "set <M-e>=\<Esc>e"
	execute "set <M-y>=\<Esc>y"
	execute "set <M-u>=\<Esc>u"
	execute "set <M-d>=\<Esc>d"
	map	<M-e>	<C-e>
	map	<M-y>	<C-y>
	map	<M-u>	<C-u>
	map	<M-d>	<C-d>

"	remap 'finding match keyword'
	inoremap <M-n> <C-n>
	inoremap <M-p> <C-p>
"	if exists('g:smoothie_enabled')
"		nnoremap	<M-u>	* <Cmd>call smoothie#do("\<C-U>") <CR>
"		nnoremap	<M-d>	* <Cmd>call smoothie#do("\<C-D>") <CR>
"	endif

"	bindings for terminal mode setting
"	Cause <C-\> is hooked for switching IM by system..
	execute "set <M-z>=\<Esc>z"
	tnoremap <M-z> <C-\><C-n>
endfunction

" becuase in .vimrc, plugins have not beed loaded
augroup MyVimEnterGroup
	autocmd!
	autocmd VimEnter	* call s:setupMKeys()
augroup END


" binding at insert mode.
" move cursor in insert mode
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-n> <Down>
inoremap <C-p> <Up>
inoremap <C-a> <Home>
inoremap <C-e> <End>
"inoremap <C-d> <Del>

" move cursor in command mode
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Del>
cmap <C-K> <C-\>estrpart(getcmdline(), 0, getcmdpos()-1)

set	rnu
set	nowrapscan
set	nowrap
set	ai
set	laststatus=2
set	noshowmode
set	statusline=[%{mode()}]%m%r%y\ %<%f\ %=%l:%c\ [%{wordcount().chars}]

" allow switching buffer even if it was not written
set	hidden

function! g:AreYouSure(message)
    echo a:message . ' (y/n): '
    let l:char = getchar()
    echo ''

    let l:ans = type(l:char) == v:t_number ? nr2char(l:char) : l:char

    return l:ans ==# 'y' || l:ans ==# 'Y'
endfunction
" quit and switch to an alternative.
" execute 'quit' at next idle time, cause it will be a error if call directory.
function! g:QuitBuffer()

	if len(getbufinfo({'buflisted': 1})) <= 1
		if !&modified
			call timer_start(0, {-> execute('quit!')})
			return
		endif

		if !g:AreYouSure('Are you sure?')
			return
		endif

		call timer_start(0, {-> execute('quit!')})
		return
	endif

	if !&modified
		call timer_start(0, {-> execute('bdelete!')})
		return
	endif

	call timer_start(0, {-> execute('bnext')})
endfunction
nnoremap <expr> Q g:QuitBuffer()

set	incsearch
set	hlsearch
map		:nohl
" to keep few number of line for searching as incremental
set	scrolloff=2

syntax	enable

" begin :terminal settings 
" bindings for terminal mode setting
" Cause <C-\> is hooked for switching IM by system..
tnoremap <M-z> <C-\><C-n>
" Termial may be cleared after .vimrc loaded
" So, fire the setting at entering the vim
augroup MyTerminalColor
    autocmd!
    autocmd VimEnter * highlight Terminal guifg=White guibg=Black
augroup END
" end :terminal settings

" begin - for hilighting cursor line
" Use cursorline at active window only
augroup FocusCursorLine
	autocmd!
	autocmd WinEnter,BufWinEnter * setlocal cursorline
	autocmd WinLeave * setlocal nocursorline
augroup END

" 0 normal mode
" 1 insert mode w/ IM
" 2 insert mode w/o IM
function! s:setCursorline(mode)
	if a:mode == 2
		hi CursorLine cterm=underline ctermbg=62 
		hi CursorLine guibg=#eeeeff
"		hi CursorLine gui=underline guifg=#000000 guibg=#eeeeff
		return
	endif
	if a:mode == 1
		hi CursorLine cterm=underline ctermbg=52 
		hi CursorLine guifg=#000000 guibg=#ccccff
"		hi CursorLine gui=underline guifg=#000000 guibg=#ccccff
		return
	endif
"	0 and others
	hi CursorLine cterm=underline ctermbg=NONE
	hi CursorLine gui=underline guibg=NONE
endfunction
call s:setCursorline(0)
" end - for hilighting cursor line

set	clipboard=unnamed,unnamedplus

" mmp - My Match Paren
if s:myMatchParen

	set signcolumn=yes

	if  s:myMatchBySign
"		define design of sign
		call sign_define('ScopeT', {'text': '┌', 'texthl': 'Identifier'})
		call sign_define('ScopeM', {'text': '│', 'texthl': 'Identifier'})
		call sign_define('ScopeB', {'text': '└', 'texthl': 'Identifier'})

		def s:mmpClearSign()
			call sign_unplace('my_scope_group', {buffer: bufnr('%')})
		enddef

		function! s:mmpShowSign(ls, le)
			call s:mmpClearSign()
			call sign_place(0, 'my_scope_group',
				\ 'ScopeT', 
				\ bufnr('%'), 
				\ {'lnum': a:ls, 'priority': 10})
			if a:le - a:ls > 1
				for l:lnum in range(a:ls + 1, a:le - 1)
					call sign_place(0, 'my_scope_group',
						\ 'ScopeM', 
						\ bufnr('%'), 
						\ {'lnum': l:lnum, 'priority': 10})
				endfor
			endif
			call sign_place(0, 'my_scope_group',
				\ 'ScopeB', 
				\ bufnr('%'), 
				\ {'lnum': a:le, 'priority': 10})
		endfunction
	endif

	let s:mmp_id  = 0
	function! s:mmpClearMatch()
		if s:mmp_id <= 0
			return
		endif

		try
			call matchdelete(s:mmp_id)
		catch /^Vim\%((\a\+)\)\=:E803/
			" through errors
		endtry
		let s:mmp_id = 0
	endfunction

	function! s:mmpClear()
		if s:myMatchBySign
			call s:mmpClearSign()
			return
		endif
		call s:mmpClearMatch()
	endfunction

	function! s:mmpShowMatch(ls, le)
		let l:lines = range(a:ls, a:le)
		let s:mmp_id = matchaddpos('Search', l:lines)
	endfunction

	function! s:mmpShow(ls, le)
		call s:mmpClear()
		if s:myMatchBySign
			call s:mmpShowSign(a:ls, a:le)
			return
		endif
		call s:mmpShowMatch(a:ls, a:le)
	endfunction

	let s:mmp_pairs = {
	\ '(': [ '(', ')', 'nW'  ],
	\ ')': [ '(', ')', 'nbW' ],
	\ '{': [ '{', '}', 'nW'  ],
	\ '}': [ '{', '}', 'nbW' ],
	\ '[': [ '\[', '\]', 'nW'  ],
	\ ']': [ '\[', '\]', 'nbW' ],
	\ }

	function! s:mmpCheck()
		let l:dmesg = []
		let l:cc = matchstr(getline('.'), '\%' . col('.') . 'c.')
		let l:dmesg += [l:cc, line('.'), col('.')]
		if !has_key(s:mmp_pairs, l:cc)
			call s:mmpClear()
			return ['notp'] + l:dmesg
		endif

		let l:conf = s:mmp_pairs[l:cc]
		let [l:match_line, l:match_col] = searchpairpos(l:conf[0], '', l:conf[1], l:conf[2])
		let l:dmesg += [l:conf[0], l:conf[1], l:conf[2]]
		let l:dmesg += [l:match_line, l:match_col]
		if l:match_line <= 0
			call s:mmpClear()
			return ['none'] + l:dmesg
		endif

		let l:cline = line('.')
		" if parents are on same line, no hilight.
		if l:cline == l:match_line
			call s:mmpClear()
			return ['same'] + l:dmesg
		endif

		if l:cline < l:match_line
			call s:mmpShow(l:cline, l:match_line)
		else
			call s:mmpShow(l:match_line, l:cline)
		endif

		return ['find'] + l:dmesg
	endfunction

	function! s:mmpHookCursorMovedI() abort
		call s:mmpCheck()
	endfunction

	function! s:mmpHookCursorMoved() abort
		call s:mmpCheck()
	endfunction

	augroup MyMatchParen
		autocmd!
		autocmd CursorMoved	* call s:mmpHookCursorMoved()
		autocmd CursorMovedI	* call s:mmpHookCursorMovedI()
		autocmd WinLeave	* call s:mmpClear()
		autocmd BufLeave	* call s:mmpClear()
		autocmd BufHidden	* call s:mmpClear()
	augroup END
endif

" begin eskk control
if s:mySKKControl
	let g:eskk#directory = expand('~/.eskk')
	let g:eskk#dictionary = {
	      \ 'path': expand('~/.eskk/jisyo'),
	      \ 'sorted': 1,
	      \ 'encoding': 'utf-8',
	      \ }
	let g:eskk#large_dictionary = {
	      \ 'path': expand('~/.eskk/SKK-JISYO.L'),
	      \ 'sorted': 1,
	      \ 'encoding': 'euc-jp',
	      \ }
"	remeber eskk-mode after leaving insert
"	BUG: This is for keep eskk henkan state beyond swiching the mode.
"	     But it disable eskk input on the dict resitering.
"	let g:eskk#keep_state = 1
	set imdisable
	set statusline^=%{eskk#statusline()}

	let s:eskkLastState = 0
	function! s:eskkCheck()
		let s:eskkLastState = eskk#is_enabled()
		call s:setCursorline(0)
	endfunction
	function! s:eskkRestore()
		call s:setCursorline(2)
		return
"	disable restoring the skk mode becuse I can't solve something wrong Orz
"		if !s:eskkLastState
"			call s:setCursorline(2)
"			return
"		endif
"		call eskk#enable()
"		call s:setCursorline(1)
	endfunction
"	too much tricky for checking mode at any key input,
"	alternative is not good but not so bad.
	function! s:eskkTextChangedI()
		if !eskk#is_enabled()
"			call s:setCursorline(0)
			call s:setCursorline(2)
			return
		endif
		if eskk#get_mode() ==# 'ascii'
"			call s:setCursorline(0)
			call s:setCursorline(2)
			return
		endif
		call s:setCursorline(1)
	endfunction
	augroup s:eskkCursorLine
		autocmd!
		autocmd User eskk-enable-post	call s:setCursorline(1)
		autocmd User eskk-disable-post	call s:setCursorline(2)
		autocmd CmdlineLeave	*	call s:setCursorline(0)
		autocmd InsertEnter	*	call s:eskkRestore()
"		autocmd InsertLeavePre	*	call s:eskkCheck()
		autocmd InsertLeave	*	call s:eskkCheck()
		autocmd TextChangedI	*	call s:eskkTextChangedI()
	augroup END
endif
" end eskk control

" begin macOS IM control
" mic - Mac IM Control
if s:myMacIMControl || s:myMacIMDisable
	let s:im_default = 'com.apple.keylayout.ABC'
	let s:im_state_i = s:im_default
	let s:im_another = s:im_default
	let s:im_select_path = expand('~/bin/im-select')

	function! s:micSelectAnother()
		call job_start([s:im_select_path, s:im_another])
	endfunction

	function! s:micSelectDefault()
		call job_start([s:im_select_path, s:im_default])
	endfunction

"	indicate IM status on the statusline
	if s:myMacIMControl
		function! g:ImStatusline()
			if s:im_state_i == s:im_default
				return '[--]'
			endif
			return '[IM]'
		endfunction
		set statusline^=%{g:ImStatusline()}
	endif

	function! s:micIndicate()
		if mode() !=# 'i' 
			call s:setCursorline(0)
			return
		endif
		if s:im_default !=# s:im_state_i
			call s:setCursorline(1)
			return
		endif
		call s:setCursorline(2)
	endfunction

" begin peep IM state
" handler should be a global cause it will be resolved other place.
	function! g:ImIAIIRecv(channel, msg)
		let l:im = trim(a:msg)
		if l:im ==# ''
			return
		endif

"		remember name of IM that is not default
		if l:im !=# s:im_default
			let s:im_another = l:im
		endif

		if l:im ==# s:im_state_i
			return
		endif

		let s:im_state_i = l:im
		call s:micIndicate()
	endfunction
	function! s:micIsActiveInI()
		call job_start([s:im_select_path], {
			\ 'out_cb': function('g:ImIAIIRecv'),
			\ 'out_mode': 'nl'
			\ })
	endfunction

	function! s:micTextChangedI()
		call s:micIsActiveInI()
	endfunction
" end peep IM state

" restore state if it is not default
	function! s:micRestore()
		if s:im_state_i ==# s:im_default
			return
		endif
		call s:micSelectAnother()
	endfunction

	function! s:micDeactivate()
		if s:im_state_i ==# s:im_default
			return
		endif
		call s:micSelectDefault()
	endfunction

	function! s:micModeChanged()
		if mode() ==# 'i' && s:myMacIMRestore
			call s:micRestore()
		else
			call s:micDeactivate()
		endif
		call s:micIndicate()
	endfunction

	" after few second idle, turn off the IM.
	function! s:micCursorHold()
		if mode() ==# 'i'
			return
		endif
		let s:im_state_i = s:im_default
	endfunction

	" handler should be a global cause it will be resolved other place.
	function! g:ImSDIARecv(channel, msg)
		let l:im = trim(a:msg)
		if l:im ==# ''
			return
		endif
		if l:im ==# s:im_default
			return
		endif
		call s:micSelectDefault()
	endfunction
	function! s:micSeletDefaultIfAnother()
		call job_start([s:im_select_path], {
			\ 'out_cb': function('g:ImSDIARecv'),
			\ 'out_mode': 'nl'
			\ })
	endfunction

	function! s:micCmdlineLeave()
		call s:micSeletDefaultIfAnother()
	endfunction

" begin overwrite eskk settings
	if s:myMacIMControl
		function! g:ImToggleI()
			call s:micSeletDefaultIfAnother()
			return ''
"			I've not succeed to toggling IM properly
"			if s:im_state_i !=# s:im_default
"				call s:micSelectDefault()
"				let s:im_state_i = s:im_default
"			else
"				call s:micSelectAnother()
"				let s:im_state_i = s:im_another
"			endif
"			call s:micIndicate()
"			return ''
		endfunction
		function! g:ImToggleC()
			call s:micSeletDefaultIfAnother()
			return ''
		endfunction
		inoremap <expr> <C-j> g:ImToggleI()
		cnoremap <expr> <C-j> g:ImToggleC()
	endif
" end overwrite eskk settings

	augroup MyIMControlGroup
		autocmd!
		autocmd ModeChanged	* call s:micModeChanged()
		autocmd CursorHold	* call s:micCursorHold()
		autocmd CmdlineLeave	* call s:micCmdlineLeave()
		if !has('timers')
			autocmd TextChangedI	* call s:micTextChangedI()
		endif
	augroup END

" begin periodical watch by timer
" turn off IM if it's activated in normal mode
" timer handler g:ImWatcher(timer) should be a global.
" bucause the name will be resolved in other script.
	if has('timers')
		function! g:ImWatcher(timer) abort
			if s:myMacIMDisable
				call s:micSeletDefaultIfAnother()
				return
			endif
			let l:mode =  mode()
			if l:mode ==# 'i'
				call s:micIsActiveInI()
				return
			endif
			if l:mode ==# 'n'
				call s:micSeletDefaultIfAnother()
				return
			endif
		endfunction

		function! s:micActivateWatcher() abort
			if exists('s:im_timer') && s:im_timer != -1
				return
			endif
			let s:im_timer = timer_start(333, 'g:ImWatcher', {'repeat': -1})
		endfunction

		function! s:micDeactivateWatcher() abort
			if !exists('s:im_timer') || s:im_timer == -1
				return
			endif
			call timer_stop(s:im_timer)
			let s:im_timer = -1
		endfunction

		augroup IMWatcherGroup
			autocmd!
			autocmd VimEnter	* call s:micActivateWatcher()
			autocmd FocusGained	* call s:micActivateWatcher()
			autocmd VimLeavePre	* call s:micDeactivateWatcher()
			autocmd FocusLost	* call s:micDeactivateWatcher()
		augroup END

	endif
" end periodical watch by timer
endif
" end macOS IM control
