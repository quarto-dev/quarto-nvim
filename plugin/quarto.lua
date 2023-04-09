if vim.fn.has("nvim-0.9.0") ~= 1 then
  local msg =
  [[quarto-dev/quarto-nvim and jmbuhr/otter.nvim require Neovim version >= 0.9.0 (https://github.com/neovim/neovim/releases/tag/stable). Please upgrade to get access to the latest features and performance improvements.]]
  local displayed = vim.notify_once(msg, vim.log.levels.WARN)
  if displayed then
    return msg
  end
  return
end

local quarto = require 'quarto'
local api = vim.api

api.nvim_create_user_command('QuartoPreview', quarto.quartoPreview, {})
api.nvim_create_user_command('QuartoClosePreview', quarto.quartoClosePreview, {})
api.nvim_create_user_command('QuartoDiagnostics', quarto.enableDiagnostics, {})
api.nvim_create_user_command('QuartoActivate', quarto.activate, {})
api.nvim_create_user_command('QuartoHelp', quarto.searchHelp, { nargs = 1 })
api.nvim_create_user_command('QuartoHover', quarto.quartoHover, {})

vim.treesitter.language.register('markdown', 'quarto')

