" Author: diartyz <diartyz@gmail.com>

" let g:ale_scss_stylelint_executable =
" \   get(g:, 'ale_scss_stylelint_executable', 'stylelint')

let g:ale_css_stylelint_options =
\   get(g:, 'ale_css_stylelint_options', '')

" let g:ale_scss_stylelint_use_global =
" \   get(g:, 'ale_scss_stylelint_use_global', 0)

call ale#Set('scss_stylelint_executable', 'stylelint')
call ale#Set('scss_stylelint_use_global', 0)

function! ale_linters#scss#stylelint#GetExecutable(buffer) abort
    return ale#node#FindExecutable(a:buffer, 'scss_stylelint', [
    \   'node_modules/.bin/stylelint',
    \])
endfunction

function! ale_linters#scss#stylelint#GetCommand(buffer) abort
    return ale_linters#scss#stylelint#GetExecutable(a:buffer)
    \   . ' ' . g:ale_css_stylelint_options
    \   . ' --stdin-filename %s'
endfunction

call ale#linter#Define('scss', {
\   'name': 'stylelint',
\   'executable_callback': 'ale_linters#scss#stylelint#GetExecutable',
\   'command_callback': 'ale_linters#scss#stylelint#GetCommand',
\   'callback': 'ale#handlers#css#HandleStyleLintFormat',
\})
