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
  - if you use [kitty terminal](https://sw.kovidgoyal.net/kitty/), images are
    also shown as previews
- `rgi/:RGI`: Live search though all files that is well integrated with Vim's native
  search (see showcase above)
- `cdf`: Tracks your working directory history and lets you switch to any
  directory *fast*
  - this works especially well because we tend to work in the same set of
    directories and because `cdf` keeps the most recent ones in the top
- `:BUF` to switch, open and delete buffers in Vim

## Configuration

This plugin has some configuration options that enable you to customize your
experience. You can set all options as variables in your `.zshrc`; it is not
necessary to export them manually. See [`options.zsh`](./options.zsh) for the
full list of customizable options.

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
