require('quarto.config')

vim.b.slime_cell_delimiter = '```'

-- TODO: Workaround while nvim-treesitter doesn't link those anymore
-- until our ouwn pandoc grammar is ready
vim.treesitter.language.register('markdown', { 'quarto', 'rmd' })

local quarto = require 'quarto'

if QuartoConfig.lspFeatures.enabled then
  quarto.activate()
end
