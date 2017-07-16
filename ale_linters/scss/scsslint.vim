" Author: w0rp <devw0rp@gmail.com>
" Description: This file add scsslint support for SCSS support

let g:ale_scss_scsslint_executable =
\   get(g:, 'ale_scss_scsslint_executable', 'scss-lint')

let g:ale_scss_scsslint_options =
\   get(g:, 'ale_scss_scsslint_options', '')

function! ale_linters#scss#scsslint#GetCommand(buffer) abort
    return g:ale_scss_scsslint_executable
    \   . ' ' . g:ale_scss_scsslint_options
    \   . ' %s'
endfunction

function! ale_linters#scss#scsslint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " test.scss:2 [W] Indentation: Line should be indented 2 spaces, but was indented 4 spaces
    let l:pattern = '^.*:\(\d\+\):\(\d*\) \[\([^\]]\+\)\] \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if !ale#Var(a:buffer, 'warn_about_trailing_whitespace')
        \&& l:match[4] =~# '^TrailingWhitespace'
            " Skip trailing whitespace warnings if that option is off.
            continue
        endif

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[4],
        \   'type': l:match[3] ==# 'E' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('scss', {
\   'name': 'scsslint',
\   'executable': 'scss-lint',
\   'command_callback': 'ale_linters#scss#scsslint#GetCommand',
\   'callback': 'ale_linters#scss#scsslint#Handle',
\})
