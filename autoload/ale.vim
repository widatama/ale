" Author: w0rp <devw0rp@gmail.com>
" Description: Primary code path for the plugin
"   Manages execution of linters when requested by autocommands

let s:lint_timer = -1
let s:last_event = ''

function! ale#Queue(...) abort
    if a:0 < 1
        throw 'At least one argument, a milliseconds delay, should be provided!'
    endif

    if a:0 > 2
        throw 'Too many arguments!'
    endif

    let l:delay = a:1
    " The event that triggered linting. This is optional.
    let l:event = a:0 >= 2 ? a:2 : ''

    " Do nothing for blacklisted files.
    if index(g:ale_filetype_blacklist, &filetype) >= 0
        return
    endif

    if s:lint_timer != -1
        call timer_stop(s:lint_timer)
        let s:lint_timer = -1
    endif

    let l:linters = ale#linter#Get(&filetype)

    if len(l:linters) == 0
        " There are no linters to lint with, so stop here.
        return
    endif

    " Remember what the last event was that triggered linting.
    let s:last_event = l:event

    if l:delay > 0
        let s:lint_timer = timer_start(l:delay, function('ale#Lint'))
    else
        call ale#Lint()
    endif
endfunction

function! ale#Lint(...) abort
    " Do nothing for blacklisted files.
    if index(g:ale_filetype_blacklist, &filetype) >= 0
        return
    endif

    let l:buffer = bufnr('%')
    let l:linters = ale#linter#Get(&filetype)

    " Initialise the buffer information if needed.
    call ale#engine#InitBufferInfo(l:buffer)

    " Clear the new loclist again, so we will work with all new items.
    let g:ale_buffer_info[l:buffer].new_loclist = []

    for l:linter in l:linters
        " Check if a given linter has a program which can be executed.
        if has_key(l:linter, 'executable_callback')
            let l:executable = ale#util#GetFunction(l:linter.executable_callback)(l:buffer)
        else
            let l:executable = l:linter.executable
        endif

        if !executable(l:executable)
            " The linter's program cannot be executed, so skip it.
            continue
        endif

        if l:linter.only_run_on_save && s:last_event !=# 'save'
            " This linter should only be run when the file is saved, and
            " the event was something else, so skip it.
            continue
        endif

        call ale#engine#Invoke(l:buffer, l:linter)
    endfor
endfunction
