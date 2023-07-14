function! s:Split(file)
    if (winheight(0) * 2 > winwidth(0))
        execute 'split ' . a:file
    else
        execute 'vsplit ' . a:file
    endif
endfunction
command! -nargs=? -complete=file SPLIT call s:Split(<q-args>)

let s:sink_by_key = {
    \$FZFDF_ACT_1: 'SPLIT',
    \$FZFDF_ACT_2: 'tabnew',
    \'': 'edit'
\}

" find files -------------------------------------------------------------------

command! FZFIND call s:fzf_finder()
exec 'noremap <silent>' . substitute($FZFDF_ACT_1, '^ctrl-\(.\)$', '<C-\1>', '') . ' :FZFIND<CR>'

let s:finder_fd_cmd = "fd --follow --strip-cwd-prefix --color=always --hidden --exclude '**/.git/'"
function! s:fzf_finder() abort
    call fzf#run(fzf#wrap({
        \'source': split(system(s:finder_fd_cmd), '\n'),
        \'options': [
            \'--ansi',
            \'--expect=' . join([$FZFDF_ACT_1, $FZFDF_ACT_2, $FZFDF_ACT_3, $FZFDF_ACT_NEW], ','),
            \'--no-multi',
            \'--preview-window=nohidden',
            \'--preview', 'test -d {} ' .
                \'&& ' . $FZFDF_LS . ' {} ' .
                \'|| bat --style=plain --color=always {}',
            \'--bind=' . 'left' . ':reload(' . s:finder_fd_cmd . ' --no-ignore)'
        \],
        \'sink*': function('s:finder_select')
    \}))
endfunction

function! s:finder_select(lines)
    let l:key = a:lines[0]
    let l:pick = a:lines[1]
    if l:pick == ''
        return
    endif

    let l:dir = isdirectory(l:pick) ? l:pick :
        \fnamemodify(l:pick, ':h') . '/'

    if l:key == $FZFDF_ACT_NEW
        call s:finder_new_file(l:dir)
    elseif l:key == $FZFDF_ACT_3
        call s:finder_action(l:pick)
    elseif !isdirectory(l:pick) && has_key(s:sink_by_key, l:key)
        execute s:sink_by_key[l:key] l:pick
    endif
endfunction

function! s:finder_new_file(dir) abort
    let l:inp = input('new file: ' . a:dir)
    let l:file = substitute(l:inp, ' .*$', '', '')
    if len(l:file) > 0
        if l:inp =~ ' s\(p\(lit\)\?\)\?$'
            let l:cmd = 'split'
        elseif l:inp =~ ' v\(ert\(ical\)\?\)\?\( \?s\(p\(lit\)\?\)\?\)\?$'
            let l:cmd = 'vsplit'
        else
            let l:cmd = 'edit'
        endif
        call system('mkdir -p ' . fnamemodify(a:dir . l:file, ':h'))
        execute l:cmd a:dir . l:file
    endif
endfunction

function! s:finder_action(pick) abort
    let l:cmd = input('{' . a:pick . '}: ')
    if len(l:cmd) > 0
        let l:out = system(substitute(l:cmd, '{}', a:pick, ''))
        echo substitute(l:out, '\n', '', '')
    endif
endfunction

" dynamic ripgrep --------------------------------------------------------------

function! s:rgi_select(lines) abort
    let l:key = a:lines[0]

    let l:fields = split(a:lines[1], ':')
    let l:query = l:fields[0][1:-2]
    let l:file = l:fields[1]
    let l:line = l:fields[2]
    let l:column = l:fields[3]

    if !has_key(s:sink_by_key, l:key)
        return
    endif

    execute s:sink_by_key[l:key] l:file
    normal zz
    let @/ = l:query
    exec 'call feedkeys("/\<CR>:call cursor(' . l:line . ', ' . l:column . ')\<CR>")'
endfunction

let s:rg_command = 'rg --column --line-number --no-heading'
function! s:rgi() abort
    call fzf#run(fzf#wrap({
        \'source': v:hlsearch
            \? split(system(s:rg_command . ' ' . @/ . " | sed \"s/^/'" . @/ . "':/g\""), '\n')
            \: [],
        \'options': [
            \'--query', v:hlsearch ? @/ : '',
            \'--delimiter', ':',
            \'--with-nth', '2',
            \'--no-multi',
            \'--bind', 'change:reload:' . s:rg_command . ' {q} | sed "s/^/{q}:/g" || true',
            \'--disabled',
            \'--preview-window=nohidden',
            \'--preview', 'bat --style=plain --color=always --line-range={3}: {2} 2>/dev/null ' .
                \'| rg --color always --context 10 {q}',
            \'--expect=' . join([$FZFDF_ACT_1, $FZFDF_ACT_2, $FZFDF_ACT_3, $FZFDF_ACT_NEW], ',')
        \],
        \'sink*': function('s:rgi_select')
    \}))
endfunction

command! RGI call s:rgi()
noremap <silent> <leader>/ :RGI<CR>
