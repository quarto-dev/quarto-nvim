# quarto-nvim

Quarto-nvim provides tools for working on [quarto](https://quarto.org/) manuscripts in neovim.

## Setup

Install the plugin from GitHub with your favourite neovim plugin manager e.g.

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```
use { 'jmbuhr/quarto-nvim' }
```

or [vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'jmbuhr/quarto-nvim'
```

## Usage

Use one of the commands:

```
QPreviewFile
QPreviewProject
QRenderFile
QRenderProject
```

to open `quarto preview` / `render` for the current file
or project in the active working directory
in the neovim integrated terminal in a new tab
(use `gt` to go back to your source tab).

## Recommended Plugins

Quarto works great with a number of existing plugins
in the neovim ecosystem.
Here are a couple of recommendations:

- <https://github.com/jpalardy/vim-slime>
- <https://github.com/neovim/nvim-lspconfig>
- <https://github.com/nvim-treesitter/nvim-treesitter>
- <https://github.com/hrsh7th/nvim-cmp>
  - <https://github.com/hrsh7th/cmp-nvim-lsp>
  - <https://github.com/hrsh7th/cmp-buffer>
  - <https://github.com/hrsh7th/cmp-path>
  - <https://github.com/hrsh7th/cmp-calc>
  - <https://github.com/hrsh7th/cmp-emoji>
  - <https://github.com/f3fora/cmp-spell>
  - <https://github.com/kdheepak/cmp-latex-symbols>
  - <https://github.com/jc-doyle/cmp-pandoc-references>
- <https://github.com/L3MON4D3/LuaSnip>
  - <https://github.com/saadparwaiz1/cmp_luasnip>
  - <https://github.com/rafamadriz/friendly-snippets>

## Example editing experience

Showing
- autocompletion with `cmp`
  - buffer
  - citations!
  - paths
- snippets with `LuaSnip`
- Live preview with the `QPreviewFile` function from this plugin


https://user-images.githubusercontent.com/17450586/160104172-a35001b8-e28c-4a26-8bbd-c522560541cd.mp4



