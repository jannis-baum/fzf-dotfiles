# fzf-dotfiles

This plugin is where I keep my
[`fzf`](https://github.com/junegunn/fzf.vim)-related dotfiles for file
management in Zsh and Vim.

![`rgi`-showcase](../assets/rgi-showcase.gif)

## Features

- All features work consistently from Zsh and Vim
- A key-bound file and directory picker with content preview that makes it easy
  to
  - open files from Zsh in Vim and from Vim in the current buffer or new splits
    and tabs
  - select files to use in any command
  - create new files
- `rgi`: Live search though all files that is well integrated with Vim's native
  search (see showcase above)
- `cdf`: Tracks your working directory history and lets you switch to any
  directory *fast*
  - this works especially well because we tend to work in the same set of
    directories and because `cdf` keeps the most recent ones in the top

## Configuration

This plugin has some configuration options to enable you to customize your
experience. You can set all options as variables in your `.zshrc`; it is not
necessary to export them manually.

### Keybindings

- `FZFDF_ACT_1`: Zsh, Vim and fzf keybinding, default `ctrl-o`
  - opens the finder in Zsh and Vim
  - writes the current fzf selection to the buffer in Zsh (if the commandline
    buffer is not empty, you can also simply press `return` to write the pick to
    the buffer)
  - opens the selected file in a new split in Vim
- `FZFDF_ACT_2`: fzf keybinding, default `ctrl-u`
  - relaunches the finder from the selection's directory in Zsh
  - opens the selected file in a new tab in Vim
- `FZFDF_ACT_3`: fzf keybinding, default `ctrl-b`
  - prompts to run a command on the selection in Vim, `{}` will be replaced by
    the selection
- `FZFDF_ACT_NEW`: fzf keybinding, default `ctrl-n` \
  prompts to create a new file in the selection's directory
  - in Vim you can append `v[sp[lit]]` or `s[p[lit]]` to the file name to open
    the new file in the respective split
- `FZFDF_ACT_RELOAD`: fzf keybinding, default `ctrl-r` \
  reloads the finder without ignoring files such as those that are gitignored
  (which is the default behavior)

### Other

- `FZFDF_LS`: command, default `ls -la` \
  the command to use to preview directory contents

## Usage

Find instructions for how to use this plugin below

### Requirements

- [`fzf`](https://github.com/junegunn/fzf), including the [Vim
  install](https://github.com/junegunn/fzf/blob/master/README-VIM.md#installation)
- [ripgrep (`rg`)](https://github.com/BurntSushi/ripgrep) for searching files
- [`bat`](https://github.com/sharkdp/bat) for pretty previews

On top of these, this plugin relies on you having your `$EDITOR` variable set to
whatever command you use to open your text editor (`vim`, `nvim`, etc.). If you
use [si-vim](https://github.com/jannis-baum/si-vim.zsh) for example, you should
have `export EDITOR=siv` in your `.zshenv` file.

### Installation

With all requirements available, simply source all `.zsh` files from this repo
in your `.zshrc`, for example like this

```zsh
for script in $(find '<path to this repo>' -name '*.zsh'); do
    source $script
done
```

and all `.vim` files in your `.vimrc`, for example like this

```vimscript
for f in glob($HOME . '<path to this repo>/**/*.vim', 0, 1)
    execute 'source ' . f
endfor
```

I do this by keeping this repository as a submodule in my
[dotfiles](https://github.com/jannis-baum/dotfiles.git). If you want to do this,
I recommend using my tool
[`sdf`](https://github.com/jannis-baum/sync-dotfiles.zsh) to manage your
dotfiles and their dependencies.
