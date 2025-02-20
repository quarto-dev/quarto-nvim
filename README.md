# quarto-nvim

Quarto-nvim provides tools for working on [Quarto](https://quarto.org/) manuscripts in Neovim.
You can get started with Quarto [here](https://quarto.org/docs/get-started/).

## Walkthrough

The [get started section](https://quarto.org/docs/get-started/hello/neovim.html) also comes with a video version to walk you through.
The playlist is extended as more features are added, so join us for a "Coffee with Quarto and Neovim":

<https://youtu.be/3sj7clNowlA?list=PLabWm-zCaD1axcMGvf7wFxJz8FZmyHSJ7>

## Setup

You can install `quarto-nvim` from GitHub with your favourite Neovim plugin manager
like [lazy.nvim](https://github.com/folke/lazy.nvim),
[packer.nvim](https://github.com/wbthomason/packer.nvim) or [VimPlug](https://github.com/junegunn/vim-plug).

Example `lazy.nvim` plugin specification:

```lua
-- plugins/quarto.lua
return {
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
```

Because Quarto provides a lot of functionality through integration with existing plugins,
we recommend to experiment with the [quarto-nvim kickstarter configuration](https://github.com/jmbuhr/quarto-nvim-kickstarter)
and then pick the relevant parts from the
[`lua/plugins/quarto.lua`](https://github.com/jmbuhr/quarto-nvim-kickstarter/blob/main/lua/plugins/quarto.lua) file
to integrate it into your own existing configuration.

Plugins and their configuration to look out for in either of those files are:

```lua
{
    'quarto-dev/quarto-nvim',
    'jmbuhr/otter.nvim',
    'hrsh7th/nvim-cmp',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter'
}
```

Quarto-nvim requires the latest [Neovim stable version](https://github.com/neovim/neovim/releases/tag/stable) (>= `v0.10.0`).

## Usage

### Configure

You can pass a lua table with options to the setup function
as shown in [quarto-nvim-kickstarter/..quarto.lua](https://github.com/jmbuhr/quarto-nvim-kickstarter/blob/main/lua/plugins/quarto.lua)

It will be merged with the default options, which are shown below in the example.
If you want to use the defaults, simply call `setup` without arguments or with an empty table.

```lua
require('quarto').setup{
  debug = false,
  closePreviewOnExit = true,
  lspFeatures = {
    enabled = true,
    chunks = "curly",
    languages = { "r", "python", "julia", "bash", "html" },
    diagnostics = {
      enabled = true,
      triggers = { "BufWritePost" },
    },
    completion = {
      enabled = true,
    },
  },
  codeRunner = {
    enabled = true,
    default_method = "slime", -- "molten", "slime", "iron" or <function>
    ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
    -- Takes precedence over `default_method`
    never_run = { 'yaml' }, -- filetypes which are never sent to a code runner
  },
}
```

### Preview

Use the command

```vim
QuartoPreview
```

or access the function from lua, e.g. to create a keybinding:

```lua
local quarto = require('quarto')
quarto.setup()
vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, { silent = true, noremap = true })
```

Then use the keyboard shortcut to open `quarto preview` for the current file or project in the active working directory in the neovim integrated terminal in a new tab.

Note: While you can use `QuartoPreview` without configuring the plugin via `quarto.setup`,
other features strictly require it.

## Language support

`quarto-nvim` automatically activates `otter.nvim` for quarto files if language features are enabled.

### Demo

https://user-images.githubusercontent.com/17450586/209436101-4dd560f4-c876-4dbc-a0f4-b3a2cbff0748.mp4

### Usage

You can open the hover documentation for R, python and julia code chunks with `K`, got-to-definition with `gd` etc.
and get autocompletion via the lsp source for your completion plugin.

A list of currently available language server requests can be found in the [otter.nvim documentation](https://github.com/jmbuhr/otter.nvim?tab=readme-ov-file#lsp-methods-currently-implemented).

### R diagnostics configuration

To make diagnostics work with R you have to configure the linter a bit, since the language
buffers in the background separate code with blank links, which we want to ignore.
Otherwise you get a lot more diagnostics than you probably want.
Add file `.lintr` to your home folder and fill it with:

```
linters: linters_with_defaults(
    trailing_blank_lines_linter = NULL,
    trailing_whitespace_linter = NULL
  )
```

You can now also enable other lsp features, such as the show hover function
and shortcut, independent of showing diagnostics by enabling lsp features
but not enabling diagnostics.

### Other Edge Cases

Other languages might have similar issues (e.g. I see a lot of warnings about whitespace when activating diagnostics with `lua`).
If you come across them and have a fix, I will be very happy about a pull request!
Or, what might ultimately be the cleaner way of documenting language specific issues, an entry in the [wiki](https://github.com/quarto-dev/quarto-nvim/wiki).

## Running Code

Quarto-nvim doesn't run code for you, instead, it will interface with existing code running
plugins and tell them what to run. There are currently three such code running plugins that quarto
will work with:

1. [molten-nvim](https://github.com/benlubas/molten-nvim) - a code runner that supports the jupyter
   kernel, renders output below each code cell, and optionally renders images in the terminal.
2. [vim-slime](https://github.com/jpalardy/vim-slime) - a general purpose code runner with support
   for sending code to integrated nvim terminals, tmux panes, and many others.
3. [iron.nvim](https://github.com/Vigemus/iron.nvim) - general purpose code runner and library for
    within-neovim REPL interaction in splits or floating windows.

We recommend picking a code runner, setting it up based on its respective README and then coming back
to this point to learn how Quarto will augment that code runner.

This plugin enables easily sending code cells to your code runner.
There are two different ways to do this:
commands, covered below; and lua functions, covered right here.
_By default these functions will only run cells that are the same language as the current cell._

Quarto exposes code running functions through to runner module: `require('quarto.runner')`.
Those
functions are:

- `run_cell()` - runs the current cell
- `run_above(multi_lang)` - runs all the cells above the current one, **and** the current one, in order
- `run_below(multi_lang)` - runs all the cells below the current one, **and** the current one, in order
- `run_all(multi_lang)` - runs all the cells in the document
- `run_line(multi_lang)` - runs the line of code at your cursor
- `run_range()` - run code inside the visual range

Each function that takes the optional `multi_lang` argument will run cells of all languages when
called with the value `true`, and will only run cells that match the language of the current cell
otherwise. As a result, just calling `run_all()` will run all cells that match the language of the
current cell.

Here are some example run mappings:

```lua
local runner = require("quarto.runner")
vim.keymap.set("n", "<localleader>rc", runner.run_cell,  { desc = "run cell", silent = true })
vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
vim.keymap.set("n", "<localleader>rA", runner.run_all,   { desc = "run all cells", silent = true })
vim.keymap.set("n", "<localleader>rl", runner.run_line,  { desc = "run line", silent = true })
vim.keymap.set("v", "<localleader>r",  runner.run_range, { desc = "run visual range", silent = true })
vim.keymap.set("n", "<localleader>RA", function()
  runner.run_all(true)
end, { desc = "run all cells of all languages", silent = true })
```


## Available Commands

```vim
QuartoPreview
QuartoClosePreview
QuartoHelp <..>
QuartoActivate
QuartoDiagnostics
QuartoSend
QuartoSendAbove
QuartoSendBelow
QuartoSendAll
QuartoSendLine
```

## Recommended Plugins

Quarto works great with a number of plugins in the neovim ecosystem.
You can find my (@jmbuhr) personal (and thus up-to-date) configuration for use with Quarto, R and python here:

<https://github.com/jmbuhr/quarto-nvim-kickstarter>

But remember, the best config is always your own.
