let s:cpo_save = &cpo
set cpo&vim

" TODO: / and ? with input
" TODO: f and t with input
" TODO: \ 'Entire': 'Entire buffer', ?
let s:motions = {
      \ 'w': 'word',
      \ 'W': 'WORD',
      \ 'b': 'backword',
      \ 'B': 'BACKWORD',
      \ 'e': 'to end of word',
      \ 'E': 'to end of WORD',
      \ 'ge': 'to end of previous word',
      \ 'gE': 'to end of previous WORD',
      \ '$': 'to end of line',
      \ '0': 'to start of line',
      \ '^': 'to first nonblank character of line',
      \ 'g_': 'to last nonblank character of line',
      \ 'h': 'left',
      \ 'j': 'down one line',
      \ 'k': 'up one line',
      \ 'l': 'right',
      \ '}': 'down one paragraph',
      \ '{': 'up one paragraph',
      \ 'n': 'next match',
      \ 'N': 'previous match',
      \ '%': 'to matching brace',
      \ 'G': 'to end of file',
      \ 'gg': 'to start of file',
      \ '//e': 'To end of match',
      \ 'Line': 'Line',
      \ }

let s:easy_motions = {
      \ 'f': 'Find {char} to the right',
      \ 'F': 'Find {char} to the left',
      \ 't': 'Till before the {char} to the right',
      \ 'T': 'Till after the {char} to the right',
      \ 'w': 'word',
      \ 'W': 'WORD',
      \ 'b': 'backword',
      \ 'B': 'BACKWORD',
      \ 'e': 'to end of word',
      \ 'E': 'to end of WORD',
      \ 'ge': 'to end of previous word',
      \ 'gE': 'to end of previous WORD',
      \ 'j': 'down line',
      \ 'k': 'up line',
      \ 'n': 'next match',
      \ 'N': 'previous match',
      \ 's': 'Find(Search) {char} forward and backward',
      \ }

""
" @public
" Fuzzy-select a motion (for yank,change,delete,etc)
function! fuzzymenu#motions#Run(operator, multiplier) abort
  let opts = {
    \ 'source': s:MotionsSource(a:operator, a:multiplier),
    \ 'sink': function('s:MotionsSink'),
    \ 'options': ['--ansi',
    \   '--header', ':: choose a motion'],
  \ }
  call fzf#run(fzf#wrap('fzm#Motions', opts, 0))
endfunction

function! fuzzymenu#motions#EasyRun(operator) abort
  let opts = {
    \ 'source': s:EasyMotionsSource(a:operator),
    \ 'sink': function('s:MotionsSink'),
    \ 'options': ['--ansi',
    \   '--header', ':: choose a motion'],
  \ }
  call fzf#run(fzf#wrap('fzm#Motions', opts, 0))
endfunction

function! s:EasyMotionsSource(operator) abort
  let motions = []
  for i in items(s:easy_motions)
    let key = i[0]
    let val = i[1]
    let motion = printf("%s%s%s\t%s", a:operator, g:mapleader, key, val)
    call add(motions, motion)
  endfor
  return motions
endfunction


function! s:MotionsSource(operator, multiplier) abort
  let motions = []
  for i in items(s:motions)
    let key = i[0]
    let val = i[1]
    if key == 'Line'
      " support for yy, dd, cc
      let key = a:operator
    endif
    let motion = printf("%s%s%s\t%s", a:operator, a:multiplier, key, val)
    call add(motions, motion)
  endfor
  return motions
endfunction

function! s:MotionsSink(arg) abort
  let key = split(a:arg, "\t")[0]
  call feedkeys(key)
endfunction
