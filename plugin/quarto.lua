local quarto = require'quarto'
local api = vim.api

api.nvim_create_user_command('QuartoPreview', quarto.quartoPreview, {})
api.nvim_create_user_command('QuartoClosePreview', quarto.quartoClosePreview, {})
api.nvim_create_user_command('QuartoDiagnostics', quarto.enableDiagnostics, {})
api.nvim_create_user_command('QuartoActivate', quarto.activateLspFeatures, {})
api.nvim_create_user_command('QuartoHelp', quarto.searchHelp, {nargs=1})
api.nvim_create_user_command('QuartoHover', quarto.quartoHover, {})

