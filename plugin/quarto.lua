local quarto = require'quarto'
local a = vim.api

-- debug
quarto.setup{
  lspFeatures = {
    enabled = true,
    languages = { 'python' }
  }
}

a.nvim_create_user_command('QuartoPreview', quarto.quartoPreview, {})
a.nvim_create_user_command('QuartoClosePreview', quarto.quartoClosePreview, {})
a.nvim_create_user_command('QuartoDiagnostics', quarto.enableDiagnostics, {})
a.nvim_create_user_command('QuartoHelp', quarto.searchHelp, {nargs=1})


-- a.nvim_create_autocmd({ "BufEnter" }, {
--   pattern = '*.qmd',
--   group = a.nvim_create_augroup('quarto', {}),
--   callback = function(args)
--     -- use markdown ft until quarto ft is more widespread
--     a.nvim_buf_set_option(0,'filetype', 'markdown')
--     require'quarto'.enableDiagnostics()
--   end
-- })

