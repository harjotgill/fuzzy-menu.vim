""
" @public
" Invoke fuzzymenu to map a key
function! fuzzymenu#vimconfig#MapKey(params) abort range
  let mode = 'n'
  let filetype = expand("%:e")
  let opts = {
    \ 'source': fuzzymenu#MainSource({'mode': mode, 'filetype': filetype}),
    \ 'sink': function('s:MapKeySink', [mode]),
    \ 'options': ['--ansi', '--header', ':: Fuzzymenu - fuzzy select an item in order to create a mapping']}
  let fullscreen = 0
  if has_key(a:params, 'fullscreen')
    let fullscreen = a:params['fullscreen']
  endif
  call fzf#run(fzf#wrap('fuzzymenu', opts, fullscreen))
endfunction

function! s:MapKeySink(mode, arg) abort
  let key = fuzzymenu#Trim(split(a:arg, "\t")[0])
  let def = fuzzymenu#Get(key)
  if len(def) < 1
    echom printf("key '%s' not found!", key)
    "TODO: error how?
    return
  endif

  call inputsave()
  let keys = input('Key mapping (e.g. ''<leader>x''): ', '<leader>')
  call inputrestore()

  "" TODO vimrc file setting
  let file = g:fuzzymenu_vim_config
  execute 'e ' . file
  execute 'normal! G$'

  let mapping = ''
  if has_key(def, 'exec')
    if a:mode == 'v'
      " execute on selected range
      " TODO: only support range when it makes sense to? ... or should we just allow it? Someone can always just use normal-mode if it fails
      let mapping = "vmap ".keys." :" . def['exec'] . "<CR>"
    else
      let mapping = "nmap ".keys." :" . def['exec'] . "<CR>"
    endif
  elseif has_key(def, 'normal')
    " TODO: check mode?
      echom "nmap XXX to " . def['normal']
      let mapping = "nmap ".keys." " . def['normal']
  else
    echom "invalid key for fuzzymenu: " . key
  endif
  if has_key(def, 'after')
   let after = def['after']
   """ TODO ...  I think we can leave this out (normally only needed during an Fzm invocation)
  endif
  if mapping != ''
    call append(line('$'), mapping) 
    """ if not auto_write, don't save. suggest
    let auto_write = g:fuzzymenu_vim_config_auto_write
    if auto_write == 1
      execute 'w'
      let file = g:fuzzymenu_vim_config
      execute 'source '. file
      echom 'file ' . file . ' written and re-sourced'
    endif
    """ navigate to end of file
    execute 'normal! G$'
  endif
endfunction

let s:settings = {
      \ 'number': {'d': 'Show line numbers on the sidebar.', 'no': ['Show', 'Hide']},
      \ 'relativenumber': {'d': 'Show line number on the current line and relative numbers on all other lines.', 'no': ['Show', 'Hide']},
      \ 'autoindent': {'d': 'New lines inherit the indentation of previous lines'},
      \ 'expandtab': {'d': 'Convert tabs to spaces.'},
      \ 'smarttab': {'d': 'Insert "tabstop" number of spaces when the “tab” key is pressed.'},
      \ 'hlsearch': {'d': 'Enable search highlighting.'},
      \ 'ignorecase': {'d': 'Case-insensitive searching.', 'no': ['insens','sens']},
      \ 'incsearch': {'d': 'Incremental search (showing partial matches)', 'no': ['^','NOT ']},
      \ 'smartcase': {'d': 'Automatically switch search to case-sensitive when search query contains an uppercase letter.', 'no': ['^','NOT ']},
      \ 'wrap': {'d': 'Enable line wrapping', 'no': ['^','NOT ']},
      \ 'ruler': {'d': 'Always show cursor position.', 'no': ['^','NOT ']},
      \ 'wildmenu': {'d': 'Display command line’s tab complete options as a menu.', 'no': ['^','NOT ']},
      \ 'cursorline': {'d': 'Highlight the line currently under cursor.', 'no': ['^', 'NOT ']},
      \ 'noerrorbells': {'d': 'Disable beep on errors.'},
      \ 'visualbell': {'d': 'Flash the screen instead of beeping on errors.', 'no': ['^', 'NOT ']},
      \ 'g:fuzzymenu_vim_config_auto_write': {'d': 'Automatically write & reload vim config.', 'options': [1, 0]},
      \ 'background': {'d': 'Notify vim about the background (of your terminal)', 'options': ['dark','light']},
      \ 'shiftwidth': {'d': 'When shifting, indent using n spaces', 'value': 'numeric'},
      \ 'tabstop': {'d': 'Indent using n spaces', 'value': 'numeric'},
      \ 'colorscheme': {'d': 'Change color scheme', 'value': 'string'},
      \ 'title': {'d': 'Change window title', 'value': 'string', 'write': 'no'},
      \ }
" filetype indent on: Enable indentation rules that are file-type specific.
" shiftround: When shifting lines, round the indentation to the nearest multiple of “shiftwidth.”
" searching
"complete-=i: Limit the files searched for auto-completes.
"lazyredraw: Don’t update screen during macro and script execution.
"Text Rendering Options
"display+=lastline: Always try to show a paragraph’s last line.
"encoding=utf-8: Use an encoding that supports unicode.
"linebreak: Avoid wrapping a line in the middle of a word.
"scrolloff=1: The number of screen lines to keep above and below the cursor.
"sidescrolloff=5: The number of screen columns to keep to the left and right of the cursor.
"syntax enable: Enable syntax highlighting.
"User Interface Options
"laststatus=2: Always display the status bar.
"tabpagemax=50: Maximum number of tab pages that can be opened from the command line.
"colorscheme wombat256mod: Change color scheme.
"mouse=a: Enable mouse for scrolling and resizing.
"title: Set the window’s title, reflecting the file currently being edited.
"background=dark: Use colors that suit a dark background.
" Code Folding Options
"foldmethod=indent: Fold based on indention levels.
"foldnestmax=3: Only fold up to three nested levels.
"nofoldenable: Disable folding by default.
" Miscellaneous Options
"autoread: Automatically re-read files if unmodified inside Vim.
"backspace=indent,eol,start: Allow backspacing over indention, line breaks and insertion start.
"backupdir=~/.cache/vim: Directory to store backup files.
"confirm: Display a confirmation dialog when closing an unsaved file.
"dir=~/.cache/vim: Directory to store swap files.
"formatoptions+=j: Delete comment characters when joining lines.
"hidden: Hide files in the background instead of closing them.
"history=1000: Increase the undo limit.
"nomodeline: Ignore file’s mode lines; use vimrc configurations instead.
"noswapfile: Disable swap files.
"nrformats-=octal: Interpret octal as decimal when incrementing numbers.
"shell: The shell used to execute commands.
"spell: Enable spellchecking.
"wildignore+=.pyc,.swp: Ignore files matching these patterns when opening files based on a glob pattern.
""
" @public
" Invoke fuzzymenu to map a key
function! fuzzymenu#vimconfig#ApplySetting(write) abort range
  let option_provided = 0
  let option_val = ''
  let opts = {
    \ 'source': s:SettingsSource(),
    \ 'sink': function('s:ApplySettingSink', [option_provided, option_val, a:write]),
    \ 'options': ['--ansi', '--header', ':: Fuzzymenu - fuzzy select an item in order to create a mapping']}
  let fullscreen = 0
  call fzf#run(fzf#wrap('fuzzymenu', opts, fullscreen))
endfunction

function! s:SettingsSource() abort
  let settings = []
  for i in items(s:settings)
    let key = i[0]
    let val = i[1]
    let note = ''
    let description = val['d']
    if has_key(val, 'options')
      let note = printf(' (options: %s) ', val['options'])
    endif
    let setter = 'set'
    if key =~ '^g:'
      let setter = 'let'
    endif
    let setting = printf("%s\t%s%s", key, note, description)
    call add(settings, setting)

    if has_key(val, 'no')
      let description = substitute(description, val['no'][0], val['no'][1], '')
      let nosetting = printf("no%s\t%s", key, description)
      call add(settings, nosetting)
    endif
  endfor
  return settings
endfunction

function! s:ApplySettingSink(option_provided, option_val, write, arg) abort
  let setting = split(a:arg, "\t")[0]
  " find setting in s:settings ...
  if has_key(s:settings, setting)
    let key = setting
    let def = s:settings[setting]
  elseif setting =~ '^no'
    let key = substitute(setting, '^no', '', '')
    if has_key(s:settings, key)
      let def = s:settings[key]
    endif
  endif

  " search for existing string
  if setting != ''
    let ln = 'set ' . setting
    if a:option_provided == 1
      " don't present 'options' again
      if a:option_val != ''
        if type(a:option_val) == 0 || type(a:option_val) == 5 " numeric types - int or float
          let ln = 'let ' . setting . '=' . a:option_val
        elseif type(a:option_val) == 1 " string
          let ln = 'let ' . setting . '=''' . a:option_val . ''''
        else
          echom 'whoa, unsupported setting type (function/array/map). Ignoring value'
        endif
      endif
    elseif has_key(def, 'options') 
      " present options
      let opts = {
        \ 'source': def['options'],
        \ 'sink': function('s:ApplySettingWithOption', [key, 1, a:write]),
        \ 'options': ['--ansi', '--header', ':: Fuzzymenu - fuzzy select an option for this setting']}
      let fullscreen = 0
      call fuzzymenu#InsertModeIfNvim()
      call fzf#run(fzf#wrap('fuzzymenu', opts, fullscreen))
      return
    elseif has_key(def, 'value') 
      " free text box
      call inputsave()
      let option_val = input('Value for ' . key . ':')
      call inputrestore()
      call s:ApplySettingSink(1, option_val, a:write, a:arg)
      return
    else
    endif
    if a:write
      call s:replaceConfigByKey(ln, key, def)
    else
      "" just call it
      execute ':' . ln
    endif
  endif
endfunction

""" switcharoo because of how fzf sinks work (last arg must be the fzf result)
function s:ApplySettingWithOption(key, option_provided, write, option_val)
  call s:ApplySettingSink(a:option_provided, a:option_val, a:write, a:key)
endfunction


""" replace an entry
function s:replaceConfigByKey(ln, key, def)
  let file = g:fuzzymenu_vim_config
  execute 'e ' . file
  " match existing lines
  if has_key(a:def, 'no')
    let search = '^\(s\|l\)et \(no\)\?' . a:key
  else
    let search = '^\(s\|l\)et ' . a:key
  endif
  let start = line('.')
  let m = search(search)
  if m
    """ delete line
    execute 'normal! dd'
  else
    echom 'not found'
    """ navigate to end of file
    execute 'normal! G$'
  endif
  call append(line('$'), a:ln) 
  """ if not auto_write, don't save. suggest
  let auto_write = g:fuzzymenu_vim_config_auto_write
  if auto_write == 1
    execute 'w'
    let file = g:fuzzymenu_vim_config
    execute 'source '. file
    echom 'file ' . file . ' written and re-sourced'
  endif
  """ navigate to end of file
  execute 'normal! G$'
endfunction
