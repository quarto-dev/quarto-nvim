local a = vim.api

a.nvim_create_user_command('QuartoPreview', require'quarto'.quartoPreview, {})


a.nvim_create_autocmd({ "BufEnter" }, {
  pattern = '*.qmd',
  group = a.nvim_create_augroup('quarto', {}),
  callback = function(args)
    require'quarto'.enableDiagnostics()
  end
})

