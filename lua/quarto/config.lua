local M = {}

local defaultConfig = {
  debug = false,
  closePreviewOnExit = true,
  lspFeatures = {
    enabled = false,
    languages = { 'r', 'python', 'julia' },
    diagnostics = {
      enabled = true,
    },
    cmpSource = {
      enabled = true,
    },
  },
  keymap = {
    hover = 'K',
  }
}

M.config = defaultConfig

M.update = function(opt)
  M.config = vim.tbl_deep_extend('force', defaultConfig, opt or {})
end

return M

