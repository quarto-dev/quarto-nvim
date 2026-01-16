require 'quarto.config'

if vim.fn.has 'nvim-0.9.0' ~= 1 then
  local msg = [[
  quarto-dev/quarto-nvim and jmbuhr/otter.nvim require Neovim version >= 0.9.0 (https://github.com/neovim/neovim/releases/tag/stable).
  If you are unable to update Neovim, you can specify a specific version of the plugins involved instead of the latest stable version.
  How you do this will vary depending on your plugin manager, but you can see one example using `lazy.nvim` here:
  <https://github.com/jmbuhr/quarto-nvim-kickstarter/blob/nvim-0.8.3/lua/plugins/quarto.lua>
  ]]
  vim.notify_once(msg, vim.log.levels.WARN)
end

vim.api.nvim_create_user_command('QuartoPreview', require('quarto').quartoPreview, { nargs = '*' })
vim.api.nvim_create_user_command('QuartoPreviewNoWatch', require('quarto').quartoPreviewNoWatch, { nargs = '*' })
vim.api.nvim_create_user_command('QuartoUpdatePreview', require('quarto').quartoUpdatePreview, { nargs = '*' })
vim.api.nvim_create_user_command('QuartoClosePreview', require('quarto').quartoClosePreview, {})
vim.api.nvim_create_user_command('QuartoActivate', require('quarto').activate, {})
vim.api.nvim_create_user_command('QuartoHelp', require('quarto').searchHelp, { nargs = 1 })
