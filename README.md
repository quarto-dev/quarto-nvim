# quarto-nvim

Quarto-nvim provides tools for working on [quarto](https://quarto.org/) manuscripts in neovim.

## Setup

Install the plugin from GitHub with your favourite neovim plugin manager e.g.

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use { 'jmbuhr/quarto-nvim' }
```

or [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'jmbuhr/quarto-nvim'
```

## Usage

Use one of the commands:

```vim
:lua require"quarto".quartoPreview()
```

Or create a keybinding for it from your `init.lua`:

```lua
local quarto = require'quarto'
vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, {silent = true, noremap = true})
```

Then use the keyboard shortcut
to open `quarto preview` / `render` for the current file
or project in the active working directory
in the neovim integrated terminal in a new tab.

## Recommended Plugins

Quarto works great with a number of existing plugins in the neovim ecosystem.
You can find semi-opinionated but still minimal
configurations for `nvim` and `tmux`,
for use with quarto, R and python in these two repositories:

- <https://github.com/jmbuhr/quarto-nvim-kickstarter>
- <https://github.com/jmbuhr/tmux-kickstarter>

