function __opt_or_fallback() {
    eval "! (( \${+$1} )) && $1=\"$2\""
}

__opt_or_fallback FZFDF_ACT_1 ctrl-o
__opt_or_fallback FZFDF_ACT_2 ctrl-u
__opt_or_fallback FZFDF_ACT_3 ctrl-b
__opt_or_fallback FZFDF_ACT_NEW ctrl-n
__opt_or_fallback FZFDF_ACT_RELOAD ctrl-r

__opt_or_fallback FZFDF_LS "ls -la"

unset -f __opt_or_fallback

[[ -n "$ZDOTDIR" ]] \
    && FZFDF_DIR_HIST="$ZDOTDIR/.dir_history" \
    || FZFDF_DIR_HIST="$HOME/.zsh_dir_history"
