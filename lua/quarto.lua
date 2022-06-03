local M = {}
local api = vim.api
local util = require"lspconfig.util"

local function contains(list, x)
  for _, v in pairs(list) do
    if v == x then return true end
  end
  return false
end


-- from emacs:
-- quarto-preview resets preview
-- get port from stdout
-- get quarto-mode-preview-url from stdout
-- does not watch inputs
-- posts to the servers instead: l 275
-- has a websocket back to emacs
-- secret uuid as command in quarto,
-- send this as GET command to quarto server to rerender
-- it's a new one now, check quarto-cli
-- or set the environment variable QUARTO_RENDER_TOKEN
-- and then the server uses this
-- param is complete path for file
-- watch response
-- non 200: user wants to render file in a different project
-- kill process, start new project

function M.quartoPreview()
  -- Modelled after quarto-emacs:
  -- <https://github.com/quarto-dev/quarto-emacs/blob/main/quarto-mode.el>

  -- find root directory / check if it is a project
  local buffer_path = api.nvim_buf_get_name(0)
  print(buffer_path)
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
  if mode == "file" and not file_extension then
    vim.notify("Not in a file. exiting.")
    return
  end
  if mode == "file" and not contains(quarto_extensions, file_extension) then
    vim.notify("Not a quarto file, ends in " .. file_extension .. " exiting.")
    return
  end

  -- run command in embedded terminal
  -- in a new tab and go back to the buffer
  vim.cmd('tabedit term://' .. command)
  vim.cmd('tabprevious')

end





M.setup = function ()
  api.nvim_create_user_command('QuartoPreview', require'quarto'.quartoPreview, {})
  -- print("hi")
end





return M

