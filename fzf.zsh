# key bindings -----------------------------------------------------------------

# action_1 for finder
#   - enter           open file in editor / cds to directory
#   - action_1        write pick to buffer (also happens when buffer not empty)
#   - action_2        start finder in selected directory (/ directory of selected file)
#   - action_new      create new file (path can have new directories)
#   - action_reload   reload without ignoring anything (e.g. .git/*)
# if multiple items are selected, items are quoted if necessary and written to
# LBUFFER

_fzf_finder() {
    [[ -z "$1" ]] && local target_dir="." || local target_dir=$1

    local fd_opts=("--follow" "--strip-cwd-prefix" "--color=always" \
        "--hidden")
    local out=$(fd $fd_opts --exclude '**/.git/' --full-path $1 \
        | fzf --ansi \
            --multi \
            --expect=$FZFDF_ACT_1,$FZFDF_ACT_NEW,$FZFDF_ACT_2 \
            --preview="\
                $FZFDF_ALL
                if test -d {}; then \
                    $FZFDF_LS;\
                else \
                    if file --mime-type {} | grep -qF image/; then \
                        $FZFDF_IMG;\
                    else \
                        $FZFDF_TXT;\
                    fi ;\
                fi" \
            --preview-window="nohidden" \
            --bind "${FZFDF_ACT_RELOAD}:reload(fd --no-ignore-vcs $fd_opts)")

    zle reset-prompt
    [[ -n "$FZFDF_ALL" ]] && eval "$FZFDF_ALL"

    local key=$(head -1 <<< $out)
    local picks=$(tail -n +2 <<< $out)
    [[ -z "$picks" ]] && return

    if [[ $(wc -l <<< $picks) -gt 1 ]]; then
        # merge picks into 1 line of correctly quoted items & write to buffer
        LBUFFER+="$(print -r -- ${(f)$(for item in "${(f)picks}"; do
            print -r -- "${(q-)item}"
        done)})"
        return
    fi

    local pick="$picks"
    test -d "$pick" \
        && local dir="$pick" \
        || local dir="$(dirname "$pick")/"

    if [[ -n "$BUFFER" || "$key" == $FZFDF_ACT_1 ]]; then
        pick="${(q-)picks}"
        # if buffer is 'mv ' we write the pick twice because you probably want
        # to move the file :)
        [[ "$BUFFER" == "mv " ]] \
            && LBUFFER+="$pick $pick" \
            || LBUFFER+="$pick"
    elif [[ "$key" == $FZFDF_ACT_NEW ]]; then
        LBUFFER="$EDITOR $dir"
    elif [[ "$key" == $FZFDF_ACT_2 ]]; then
        _fzf_finder "$dir" || _fzf_finder "$target"
    else
        if test -d "$pick"; then
            cd "$pick"
        else
            local file_output="$(file "$pick")"
            if [[ "$file_output" = *text* || "$file_output" = *empty* || -z "$(cat "$pick")" ]]; then
                $EDITOR "$pick"
            else
                $FZFDF_PROG_OPEN "$pick"
            fi
        fi
    fi
}
zle -N _fzf_finder
bindkey $(sed 's/ctrl-/^/' <<< $FZFDF_ACT_1) _fzf_finder

# commands ---------------------------------------------------------------------

# interactive ripgrep: live search & highlighted preview
#   - enter    open selection in vim, go to selected occurance and highlight
#              search
rgi() {
    local rg_command=("rg" "--column" "--line-number" "--no-heading")
    local selection=$(true | \
        fzf -d ':' --with-nth=1 +m --disabled --print-query \
            --bind "change:reload:$rg_command $@ {q} || true" \
            --preview-window="right,70%,wrap,nohidden" \
            --preview "\
                bat --style=plain --color=always --line-range {2}: {1} 2> /dev/null\
                    | rg --color always --context 10 {q}\
                || bat --style=plain --color=always --line-range {2}: {1} 2> /dev/null")

    local query=$(head -n 1 <<< $selection)
    local details=$(tail -n 1 <<< $selection)

    if [[ "$details" != "$query" ]]; then
        local file=$(awk -F: '{ print $1 }' <<< $details)
        local line=$(awk -F: '{ print $2 }' <<< $details)
        local column=$(awk -F: '{ print $3 }' <<< $details)
        $EDITOR "+let @/='$query'" "+call feedkeys('/\<CR>:call cursor($line, $column)\<CR>')" "$file"
    fi
}

# dir history picker
#   - enter    go to directory

# keep history file
[[ -n "$ZDOTDIR" ]] \
    && FZFDF_DIR_HIST="$ZDOTDIR/.dir_history" \
    || FZFDF_DIR_HIST="$HOME/.zsh_dir_history"

function _fzfdf_log_dir_history() {
    echo "$(pwd; test -f $FZFDF_DIR_HIST && head -n1000 $FZFDF_DIR_HIST)" > $FZFDF_DIR_HIST
}
autoload -U add-zsh-hook
add-zsh-hook chpwd _fzfdf_log_dir_history
# coloring
_fzfdf_ls_color=$(sed -r 's/^.*di=([^:]+):.*$/\1/' <<< $LS_COLORS)
[[ -n "$_fzfdf_ls_color" ]] && _fzfdf_ls_color="\e[${_fzfdf_ls_color}m"

# actual command
function cdf() {
    test -f $FZFDF_DIR_HIST || return
    # make paths unique and delete non-existing
    local valid_paths=""
    for p in ${(f)"$(
        cat -n $FZFDF_DIR_HIST \
            | sort -uk2 \
            | sort -nk1 \
            | cut -f2-
    )"}; do
        test -d "$p" && valid_paths+="$p\n"
    done
    echo "$valid_paths" > $FZFDF_DIR_HIST
    [[ -z "$valid_paths" ]] && return

    # pick target
    local target="$(
        printf "$_fzfdf_ls_color$(printf $valid_paths | rg --invert-match "^$(pwd)\$")" \
        | fzf --ansi --preview-window="nohidden" \
            --preview="$FZFDF_LS")"

    # go to dir
    if [[ -n "$target" ]]; then
        cd "$target"
    fi
}
