vim.b.slime_cell_delimiter = "```"

local quarto = require'quarto'

local function set_keymaps()
  local b = 0
  local function set(lhs, rhs)
    vim.api.nvim_buf_set_keymap(b, 'n', lhs, rhs, { silent = true, noremap = true })
  end
  set(quarto.config.keymap.definition, ":lua require'otter'.ask_definition()<cr>")
  set(quarto.config.keymap.type_definition, ":lua require'otter'.ask_type_definition()<cr>")
  set(quarto.config.keymap.hover, ":lua require'otter'.ask_hover()<cr>")
  set(quarto.config.keymap.rename, ":lua require'otter'.ask_rename()<cr>")
  set(quarto.config.keymap.references, ":lua require'otter'.ask_references()<cr>")
  set(quarto.config.keymap.document_symbols, ":lua require'otter'.ask_document_symbols()<cr>")
end

if quarto.config.lspFeatures.enabled then
  quarto.activate()
  set_keymaps()
  -- set the keymap again if a language server attaches
  -- directly to this buffer
  -- because it probably overwrites these in `LspAttach`
  -- TODO: make this more robust
  -- This currently only works if 'LspAttach' is used
  -- directly, e.g. in LazyVim
  -- It does no work if the `on_attach` callback
  -- is used in the lspconfig setup
  -- because this gets executed after the `LspAttach` autocommand
  -- <https://github.com/neovim/neovim/blob/d0d132fbd055834cbecb3d4e3a123a6ea8f099ec/runtime/lua/vim/lsp.lua#L1702-L1711>
  vim.api.nvim_create_autocmd("LspAttach", {
    buffer = vim.api.nvim_get_current_buf(),
    group = vim.api.nvim_create_augroup('QuartoKeymapSetup', {}),
    callback = set_keymaps,
  })
end

