
---@class QuartoConfig
QuartoConfig = {
  debug = false,
  closePreviewOnExit = true,
  lspFeatures = {
    enabled = true,
    chunks = 'curly',
    languages = nil, -- nil means all languages found in the document
    diagnostics = {
      enabled = true,
      triggers = { 'BufWritePost' },
    },
    completion = {
      enabled = true,
    },
  },
  codeRunner = {
    enabled = true,
    default_method = 'slime', -- "molten", "slime", "iron" or <function>
    ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
    -- Takes precedence over `default_method`
    never_run = { 'yaml' }, -- filetypes which are never sent to a code runner
  },
}
