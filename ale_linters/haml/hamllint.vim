" Author: Patrick Lewis - https://github.com/patricklewis
" Description: haml-lint for Haml files

let g:ale_haml_hamllint_executable =
\   get(g:, 'ale_haml_hamllint_executable', 'haml-lint')

let g:ale_haml_hamllint_options =
\   get(g:, 'ale_haml_hamllint_options', '')

function! ale_linters#haml#hamllint#GetCommand(buffer) abort
    return g:ale_haml_hamllint_executable
    \   . ' ' . g:ale_haml_hamllint_options
    \   . ' %s'
endfunction

function! ale_linters#haml#hamllint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " <path>:51 [W] RuboCop: Use the new Ruby 1.9 hash syntax.
    let l:pattern = '\v^.*:(\d+) \[([EW])\] (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'type': l:match[2],
        \   'text': l:match[3]
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('haml', {
\   'name': 'hamllint',
\   'executable': 'haml-lint',
\   'command_callback': 'ale_linters#haml#hamllint#GetCommand',
\   'callback': 'ale_linters#haml#hamllint#Handle',
\})
