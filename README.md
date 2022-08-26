# quarto-nvim

Quarto-nvim provides tools for working on [quarto](https://quarto.org/) manuscripts in neovim.

## Setup

Install the plugin from GitHub with your favourite neovim plugin manager e.g.

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use { 'quarto-dev/quarto-nvim',
  requires = { {'nvim-lua/plenary.nvim'} }
}
```

or [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'quarto-dev/quarto-nvim'
```

## Usage

Use the command

```vim
QuartoPreview
```

or access the function from lua, e.g. to create a keybinding:

```lua
local quarto = require'quarto'
vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, {silent = true, noremap = true})
```

Then use the keyboard shortcut to open `quarto preview` for the current file or project in the active working directory in the neovim integrated terminal in a new tab.

## Configure

You can pass a lua table with options to the setup function.
It will be merged with the default options, which are shown below in the example
(i.e. if you are fine with the defaults you don't have to call the setup function).

```lua
require'quarto'.setup{
  closePreviewOnExit = true, -- close preview terminal on closing of qmd file buffer
}
```

## Recommended Plugins

Quarto works great with a number of existing plugins in the neovim ecosystem.
You can find semi-opinionated but still minimal
configurations for `nvim` and `tmux`,
for use with quarto, R and python in these two repositories:

- <https://github.com/jmbuhr/quarto-nvim-kickstarter>
- <https://github.com/jmbuhr/tmux-kickstarter>

