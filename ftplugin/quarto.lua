vim.b.slime_cell_delimiter = '```'

-- TODO: Workaround while nvim-treesitter doesn't link those anymore
-- until our ouwn pandoc grammar is ready
-- vim.treesitter.language.register("markdown", { "quarto", "rmd" })

vim.bo.commentstring = "<!-- %s -->"

local config = require('quarto.config').config
local quarto = require 'quarto'

if config.lspFeatures.enabled then
  quarto.activate()
end
