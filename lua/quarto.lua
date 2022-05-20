local M = {}
local api = vim.api
local util = require("lspconfig.util")

local function contains(list, x)
  for _, v in pairs(list) do
    if v == x then return true end
  end
  return false
end

function M.quartoPreview()
  -- Modelled after quarto-emacs:
  -- <https://github.com/quarto-dev/quarto-emacs/blob/main/quarto-mode.el>

  -- find root directory / check if it is a project
  local buffer_path = vim.api.nvim_buf_get_name(0)
  local root_dir = util.root_pattern("_quarto.yml")(buffer_path)
  local command
  local mode
  if root_dir then
    mode = "project"
    command = 'quarto preview'
  else
    mode = "file"
    command = 'quarto preview ' .. buffer_path
  end

  local quarto_extensions = { ".qmd", ".Rmd", ".ipynb", ".md" }
  local file_extension = buffer_path:match("^.+(%..+)$")
  if mode == "file" and not contains(quarto_extensions, file_extension) then
    vim.notify("Not a quarto file, ends in " .. file_extension .. " exiting.")
    return
  end

  -- run command in embedded terminal
  -- in a new tab and go back to the buffer
  vim.cmd('tabedit term://' .. command)
  vim.cmd('tabprevious')

end


return M
