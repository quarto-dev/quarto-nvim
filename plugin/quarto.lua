local quarto = require'quarto'
local a = vim.api

a.nvim_create_user_command('QuartoPreview', quarto.quartoPreview, {})
a.nvim_create_user_command('QuartoClosePreview', quarto.quartoClosePreview, {})
a.nvim_create_user_command('QuartoDiagnostics', quarto.enableDiagnostics, {})
a.nvim_create_user_command('QuartoHelp', quarto.searchHelp, {nargs=1})
a.nvim_create_user_command('QuartoHover', quarto.quartoHover, {})

a.nvim_create_autocmd({"BufEnter"}, {
  pattern = {"*.qmd"},
  callback = function ()
    quarto = require'quarto'
    if quarto.config.lspFeatures.enabled then
      quarto.enableDiagnostics()
    end
  end,
})
