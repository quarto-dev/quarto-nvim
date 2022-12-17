local quarto = require'quarto'
local a = vim.api

a.nvim_create_user_command('QuartoPreview', quarto.quartoPreview, {})
a.nvim_create_user_command('QuartoClosePreview', quarto.quartoClosePreview, {})
a.nvim_create_user_command('QuartoDiagnostics', quarto.enableDiagnostics, {})
a.nvim_create_user_command('QuartoHelp', quarto.searchHelp, {nargs=1})

