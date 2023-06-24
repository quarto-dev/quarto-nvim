vim.b.slime_cell_delimiter = "```"

local q = require'quarto'
if q.config.lspFeatures.enabled and vim.bo.buftype ~= 'terminal' then
  q.activate()

  vim.api.nvim_buf_set_keymap(0, 'n', q.config.keymap.definition, ":lua require'otter'.ask_definition()<cr>",
    { silent = true })
  vim.api.nvim_buf_set_keymap(0, 'n', q.config.keymap.hover, ":lua require'otter'.ask_hover()<cr>",
    { silent = true })
  vim.api.nvim_buf_set_keymap(0, 'n', q.config.keymap.rename, ":lua require'otter'.ask_rename()<cr>",
    { silent = true })
  vim.api.nvim_buf_set_keymap(0, 'n', q.config.keymap.references, ":lua require'otter'.ask_references()<cr>",
    { silent = true })
end
