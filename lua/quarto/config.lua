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
    enabled = true,
    ft_runners = {}, -- filetype to runner, allowing different runners for different languages
    never_run = { "yaml" }, -- filetypes to never try to run
    default_method = "molten-nvim", -- or 'yarepl' or 'vim-slime'
    -- TODO: implement auto target switching
    -- auto_target_switching = false, -- automatically try to send the code to the correct place instead of asking every time
    -- this should be implemented by just remembering where each language was sent, and not
    -- prompting the user every time
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
M.config = M.defaultConfig

return M
