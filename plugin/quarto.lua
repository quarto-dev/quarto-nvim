local a = vim.api

a.nvim_create_user_command('QuartoPreview', require'quarto'.quartoPreview, {})
a.nvim_create_user_command('QuartoDiagnostics', require'quarto'.enableDiagnostics, {})

-- a.nvim_create_autocmd({ "BufEnter" }, {
--   pattern = '*.qmd',
--   group = a.nvim_create_augroup('quarto', {}),
--   callback = function(args)
--     -- use markdown ft until quarto ft is more widespread
--     a.nvim_buf_set_option(0,'filetype', 'markdown')
--     require'quarto'.enableDiagnostics()
--   end
-- })

