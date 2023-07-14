# key bindings -----------------------------------------------------------------

# action_1 for finder
#   - enter           open file in editor / cds to directory
#   - action_1        write pick to buffer (also happens when buffer not empty)
#   - action_2        start finder in selected directory (/ directory of selected file)
#   - action_new      create new file (path can have new directories)
#   - action_reload   reload without ignoring anything (e.g. .git/*)

_fzf_finder() {
    [[ -z "$1" ]] && local target_dir="." || local target_dir=$1

    local fd_opts=("--follow" "--strip-cwd-prefix" "--color=always" \
        "--hidden" "--exclude" '**/.git/')
    local out=$(fd $fd_opts --full-path $1 \
        | fzf --ansi \
            --expect=$FZFDF_ACT_1,$FZFDF_ACT_NEW,$FZFDF_ACT_2 \
            --preview="test -d {} \
                && $FZFDF_LS {} \
                || bat --style=numbers --color=always {}" \
            --preview-window="nohidden" \
            --bind "${FZFDF_ACT_RELOAD}:reload(fd --no-ignore $fd_opts)")
    zle reset-prompt

    local key=$(head -1 <<< $out)
    local pick=$(tail -n +2 <<< $out)
    [[ -z "$pick" ]] && return

    pick=${(q-)pick}
    test -d $pick \
        && local dir="$pick" \
        || local dir="${(q-)$(dirname $pick)}/"

    if [[ -n "$BUFFER" || "$key" == $FZFDF_ACT_1 ]]; then
        LBUFFER+="$pick"
    elif [[ "$key" == $FZFDF_ACT_NEW ]]; then
        LBUFFER="$EDITOR $dir"
    elif [[ "$key" == $FZFDF_ACT_2 ]]; then
        _fzf_finder "$dir" || _fzf_finder "$target"
    else
        test -d $pick \
            && BUFFER="cd $pick" \
            || BUFFER="$EDITOR $pick"
        zle accept-line; zle reset-prompt
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
    local selection=$($rg_command "$1" | \
        fzf -d ':' --with-nth=1 +m --disabled --print-query --query "$1" \
            --bind "change:reload:$rg_command {q} || true" \
            --preview-window="right,70%,wrap,nohidden" \
            --preview "\
                bat --style=numbers --color=always --line-range {2}: {1} 2> /dev/null\
                    | rg --color always --context 10 {q}\
                || bat --style=numbers --color=always --line-range {2}: {1} 2> /dev/null")

    local query=$(head -n 1 <<< $selection)
    local details=$(tail -n 1 <<< $selection)

    if [[ "$details" != "$query" ]]; then
        local file=$(awk -F: '{ print $1 }' <<< $details)
        local line=$(awk -F: '{ print $2 }' <<< $details)
        local column=$(awk -F: '{ print $3 }' <<< $details)
        $EDITOR "+call cursor($line, $column)" "+let @/='$query'" "+call feedkeys('/\<CR>')" "$file"
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

# actual command
function cdf() {
    test -f $FZFDF_DIR_HIST || return
    # make paths unique and delete non-existing
    local valid_paths=""
    for p in $(
        cat -n $FZFDF_DIR_HIST \
            | sort -uk2 \
            | sort -nk1 \
            | cut -f2-
    ); do
        test -d $p && valid_paths+=$p"\n"
    done
    echo $valid_paths > $FZFDF_DIR_HIST
    [[ -z "$valid_paths" ]] && return

    # pick target
    local target=$(
        printf "\e[$(sed -r 's/^.*di=([^:]+):.*$/\1/' <<< $LS_COLORS)m$(printf $valid_paths | tail -n +2)" \
        | fzf --ansi --preview-window="nohidden" \
            --preview="$FZFDF_LS "'$(sed "s|~|$HOME|" <<<{})')

    # go to dir
    if [[ -n "$target" ]]; then
        cd ${(q-)$(sed "s|~|$HOME|" <<<$target)}
    fi
}
