local M = {}
local api = vim.api
local util = require "lspconfig.util"
local tools = require 'quarto.tools'
local otter = require 'otter'

M.defaultConfig = {
  debug = false,
  closePreviewOnExit = true,
  lspFeatures = {
    enabled = false,
    languages = { 'r', 'python', 'julia' },
    diagnostics = {
      enabled = true,
      triggers = { "BufWrite" }
    },
    completion = {
      enabled = false,
    },
  },
  keymap = {
    hover = 'K',
    definition = 'gd'
  }
}

function M.quartoPreview()
  -- find root directory / check if it is a project
  local buffer_path = api.nvim_buf_get_name(0)
  local root_dir = util.root_pattern("_quarto.yml")(buffer_path)
  local cmd
  local mode
  if root_dir then
    mode = "project"
    cmd = 'quarto preview'
  else
    mode = "file"
    cmd = 'quarto preview ' .. buffer_path
  end

  local quarto_extensions = { ".qmd", ".Rmd", ".ipynb", ".md" }
  local file_extension = buffer_path:match("^.+(%..+)$")
  if mode == "file" and not file_extension then
    vim.notify("Not in a file. exiting.")
    return
  end
  if mode == "file" and not tools.contains(quarto_extensions, file_extension) then
    vim.notify("Not a quarto file, ends in " .. file_extension .. " exiting.")
    return
  end

  -- run command in embedded terminal
  -- in a new tab and go back to the buffer
  vim.cmd('tabedit term://' .. cmd)
  local quartoOutputBuf = vim.api.nvim_get_current_buf()
  vim.cmd('tabprevious')
  api.nvim_buf_set_var(0, 'quartoOutputBuf', quartoOutputBuf)


  -- close preview terminal on exit of the quarto buffer
  if M.config.closePreviewOnExit then
    api.nvim_create_autocmd({ "QuitPre", "WinClosed" }, {
      buffer = api.nvim_get_current_buf(),
      group = api.nvim_create_augroup("quartoPreview", {}),
      callback = function(_, _)
        if api.nvim_buf_is_loaded(quartoOutputBuf) then
          api.nvim_buf_delete(quartoOutputBuf, { force = true })
        end
      end
    })
  end
end

function M.quartoClosePreview()
  local success, quartoOutputBuf = pcall(api.nvim_buf_get_var, 0, 'quartoOutputBuf')
  if not success then return end
  if api.nvim_buf_is_loaded(quartoOutputBuf) then
    api.nvim_buf_delete(quartoOutputBuf, { force = true })
  end
end

M.enableDiagnostics = function()
  local main_nr = api.nvim_get_current_buf()
  api.nvim_create_autocmd(M.config.lspFeatures.diagnostics.triggers, {
    buffer = main_nr,
    group = api.nvim_create_augroup("quartoLSPDiagnositcs", { clear = false }),
    callback = function(_, _)
      local bufnrs = otter.sync_raft(main_nr)
      for _, bufnr in ipairs(bufnrs) do
        local diag = vim.diagnostic.get(bufnr)
        local ns = api.nvim_create_namespace('quarto-lang-' .. bufnr)
        vim.diagnostic.reset(ns, 0)
        vim.diagnostic.set(ns, 0, diag, {})
      end
    end
  })
end

M.quartoHover = function()
  local main_nr = api.nvim_get_current_buf()
  otter.send_request(main_nr, "textDocument/hover", function(response)
    local ok, filtered_response = pcall(tools.replace_header_div, response)
    if ok then
      return filtered_response
    else
      return response
    end
  end
  )
end


M.quartoDefinition = function()
  local main_nr = api.nvim_get_current_buf()
  local main_uri = vim.uri_from_bufnr(main_nr)
  otter.send_request(main_nr, "textDocument/definition", function(response)
    if response.uri ~= nil then
      if require'otter.tools.functions'.is_otterpath(response.uri) then
          response.uri = main_uri
      end
      return response
    end
    end
  )
end


M.searchHelp = function(cmd_input)
  local topic = cmd_input.args
  local url = 'https://quarto.org/?q=' .. topic .. '&show-results=1'
  local sysname = vim.loop.os_uname().sysname
  local cmd
  if sysname == "Linux" then
    cmd = 'xdg-open "' .. url .. '"'
  elseif sysname == "Darwin" then
    cmd = 'open "' .. url .. '"'
  else
    print('sorry, I do not know how to make windows open a url with the default browser. This feature currently only works on linux and mac.')
    return
  end
  vim.fn.jobstart(cmd)
end

M.activate = function()
  otter.activate(M.config.lspFeatures.languages, M.config.lspFeatures.completion.enabled)
end

-- setup
M.setup = function(opt)
  M.config = vim.tbl_deep_extend('force', M.defaultConfig, opt or {})

  api.nvim_create_autocmd({"BufEnter"}, {
    pattern = {"*.qmd"},
    callback = function ()
      if M.config.lspFeatures.enabled then
        M.activate()

        vim.api.nvim_buf_set_keymap(0, 'n', M.config.keymap.definition, ":lua require'quarto'.quartoDefinition()<cr>", { silent = true })
        vim.api.nvim_buf_set_keymap(0, 'n', M.config.keymap.hover, ":lua require'quarto'.quartoHover()<cr>", { silent = true })

        if M.config.lspFeatures.diagnostics.enabled then
          M.enableDiagnostics()
        end
      end
    end,
  })
end


return M
