local M = {}

M.defaultConfig = {
  debug = false,
  closePreviewOnExit = true,
  lspFeatures = {
    enabled = true,
    chunks = "curly",
    languages = { "r", "python", "julia", "bash", "html" },
    diagnostics = {
      enabled = true,
      triggers = { "BufWritePost" },
    },
    completion = {
      enabled = true,
    },
  },
  codeRunner = {
    enabled = false,
    default_method = nil, -- "molten", "slime", or "iron"
    ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
                     -- Takes precedence over `default_method`
    never_run = { "yaml" }, -- filetypes which are never sent to a code runner
  },
  keymap = {
    hover = "K",
    definition = "gd",
    type_definition = "gD",
    rename = "<leader>lR",
    format = "<leader>lf",
    references = "gr",
    document_symbols = "gS",
  },
}

-- use defaultConfig if not setup
M.config = M.config or M.defaultConfig

return M
