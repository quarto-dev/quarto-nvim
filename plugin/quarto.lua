local quarto = require'quarto'
local config = require'quarto.config'.config
local a = vim.api

a.nvim_create_user_command('QuartoPreview', quarto.quartoPreview, {})
a.nvim_create_user_command('QuartoClosePreview', quarto.quartoClosePreview, {})
a.nvim_create_user_command('QuartoDiagnostics', quarto.enableDiagnostics, {})
a.nvim_create_user_command('QuartoActivate', quarto.activateLspFeatures, {})
a.nvim_create_user_command('QuartoHelp', quarto.searchHelp, {nargs=1})
a.nvim_create_user_command('QuartoHover', quarto.quartoHover, {})

a.nvim_create_autocmd({"BufEnter"}, {
  pattern = {"*.qmd"},
  callback = function ()
    if config.lspFeatures.enabled then
      quarto.activateLspFeatures()
      if config.lspFeatures.diagnostics.enabled then
        quarto.enableDiagnostics()
      end
    end
  end,
})
