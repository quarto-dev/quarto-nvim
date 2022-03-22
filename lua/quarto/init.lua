local M = {}
local api = vim.api

function M.previewFile()
  local filepath = api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) or ''
  local filename = filepath:match("^.+/(.+)$")
  local command = 'quarto preview ' .. filename
  vim.cmd('tabedit term://' .. command)
end


function M.renderFile()
  local filepath = api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) or ''
  local filename = filepath:match("^.+/(.+)$")
  local command = 'quarto render ' .. filename
  vim.cmd('tabedit term://' .. command)
end


function M.previewProject()
  local command = 'quarto preview'
  vim.cmd('tabedit term://' .. command)
end

function M.renderProject()
  local command = 'quarto render'
  vim.cmd('tabedit term://' .. command)
end

function M.setup()
  vim.cmd [[
    command! QPreviewFile lua require'quarto-nvim'.previewFile()
    command! QPreviewProject lua require'quarto-nvim'.previewProject()
    command! QRenderFile lua require'quarto-nvim'.renderFile()
    command! QRenderProject lua require'quarto-nvim'.renderProject()
  ]]
end


return M
