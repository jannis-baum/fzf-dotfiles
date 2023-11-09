function __opt_or_fallback() {
    # if option is set, make sure it's exported for vim
    # if not, set it to $2
    eval "(( \${+$1} )) && export $1=\"\$$1\" || export $1=\"$2\""
}

# KEYBINDINGS ------------------------------------------------------------------
# - explanation      name                default setting
# ------------------------------------------------------------------------------

# for Zsh, Vim & fzf
# - opens the finder in Zsh and Vim
# - opens the selection in a new split in Vim (automatic hsplit/vsplit)
# - writes the current fzf selection to the buffer in Zsh (if the commandline
#   buffer is not empty, you can also simply press `return` to write the pick to
#   the buffer)
__opt_or_fallback    FZFDF_ACT_1         ctrl-o

# for fzf
# - relaunches the finder from the selection's directory in Zsh
# - opens the selected file in a new tab in Vim
__opt_or_fallback    FZFDF_ACT_2         ctrl-u

# for fzf
# - prompts to run a command on the selection in Vim, `{}` will be replaced by
#   the selection
__opt_or_fallback    FZFDF_ACT_3         ctrl-b

# for fzf
# - prompts to create a new file in the selection's directory
# - in Vim you can append `v[sp[lit]]` or `s[p[lit]]` to the file name to open
#   the new file in the respective split
__opt_or_fallback    FZFDF_ACT_NEW       ctrl-n

# for fzf
# - reloads the finder without ignoring files such as those that are gitignored
#   (which is the default behavior)
__opt_or_fallback    FZFDF_ACT_RELOAD    ctrl-r

# OTHER ------------------------------------------------------------------------
# - explanation      name                default setting
# ------------------------------------------------------------------------------

# command that is used to list directory contents in the preview window
__opt_or_fallback    FZFDF_LS            "ls -la {}"
__opt_or_fallback    FZFDF_IMG           "echo image: {}"
__opt_or_fallback    FZFDF_TXT           "bat --style=plain --color=always {}"
__opt_or_fallback    FZFDF_ALL           ""

unset -f __opt_or_fallback
