local M = {}
local api = vim.api
local util = require "lspconfig.util"
local buffers = require'quarto.buffers'
local source = require'quarto.source'
local config = require'quarto.config'.config
local update_config = require'quarto.config'.update

---Registered client and source mapping.
M.cmp_client_source_map = {}

---Setup cmp-nvim-lsp source.
M.cmp_setup_source = function(qmdbufnr, bufnr)
  local callback = function()
    M.cmp_on_insert_enter(qmdbufnr, bufnr)
  end
  vim.api.nvim_create_autocmd('InsertEnter', {
    buffer = qmdbufnr,
    group = vim.api.nvim_create_augroup('cmp_quarto', { clear = false }),
    callback = callback
  })
end

---Refresh sources on InsertEnter.
-- adds a source for the hidden language buffer bufnr
M.cmp_on_insert_enter = function(qmdbufnr, bufnr)
  local cmp = require('cmp')
  local allowed_clients = {}

  -- register all active clients.
  for _, client in ipairs(vim.lsp.get_active_clients({bufnr = bufnr})) do
    allowed_clients[client.id] = client
    if not M.cmp_client_source_map[client.id] then
      local s = source.new(client, qmdbufnr, bufnr)
      if s:is_available() then
        P('register source for ' .. s.client.name)
        P(client.id)
        P(s.client.name)
        M.cmp_client_source_map[client.id] = cmp.register_source('quarto', s)
        P(M.cmp_client_source_map)
      end
    end
  end

  -- register all buffer clients (early register before activation)
  for _, client in ipairs(vim.lsp.buf_get_clients(0)) do
    allowed_clients[client.id] = client
    if not M.cmp_client_source_map[client.id] then
      local s = source.new(client, qmdbufnr, bufnr)
      if s:is_available() then
        M.cmp_client_source_map[client.id] = cmp.register_source('quarto', s)
      end
    end
  end

  -- unregister stopped/detached clients.
  for client_id, source_id in pairs(M.cmp_client_source_map) do
    if not allowed_clients[client_id] or allowed_clients[client_id]:is_stopped() then
      cmp.unregister_source(source_id)
      M.cmp_client_source_map[client_id] = nil
    end
  end
end


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
  if config.closePreviewOnExit then
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

M.activateLspFeatures = function()
  local qmdbufnr = api.nvim_get_current_buf()
  local bufnrs = buffers.updateLanguageBuffers(qmdbufnr)

  -- auto-close language files on qmd file close
  api.nvim_create_autocmd({ "QuitPre", "WinClosed" }, {
    buffer = 0,
    group = api.nvim_create_augroup("quartoAutoclose", {}),
    callback = function(_, _)
      for _, bufnr in ipairs(bufnrs) do
        if api.nvim_buf_is_loaded(bufnr) then
          -- delete tmp file
          local path = api.nvim_buf_get_name(bufnr)
          vim.fn.delete(path)
          -- remove buffer
          api.nvim_buf_delete(bufnr, { force = true })
        end
      end
    end
  })

  if config.lspFeatures.diagnostics.enabled then
    M.enableDiagnostics()
  end

  if config.lspFeatures.cmpSource.enabled then
    for _,bufnr in ipairs(bufnrs) do
      M.cmp_setup_source(qmdbufnr, bufnr)
    end

    api.nvim_create_autocmd({ "TextChangedI" }, {
      buffer = 0,
      group = api.nvim_create_augroup("quartoCmp", { clear = false }),
      callback = function(_, _)
        local bufnrs = buffers.updateLanguageBuffers(0)
      end
    })
  end

  local key = config.keymap.hover
  vim.api.nvim_set_keymap('n', key, ":lua require'quarto'.quartoHover()<cr>", { silent = true })
end

M.enableDiagnostics = function()
  -- update diagnostics on changes
  api.nvim_create_autocmd({ "CursorHold", "TextChanged" }, {
    buffer = 0,
    group = api.nvim_create_augroup("quartoLSPDiagnositcs", { clear = false }),
    callback = function(_, _)
      local bufnrs = buffers.updateLanguageBuffers(0)
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
  local qmdbufnr = api.nvim_get_current_buf()
  local bufnrs = buffers.updateLanguageBuffers(qmdbufnr)
  for _, bufnr in ipairs(bufnrs) do
    local uri = vim.uri_from_bufnr(bufnr)
    local position_params = vim.lsp.util.make_position_params()
    position_params.textDocument = {
      uri = uri
    }
    vim.lsp.buf_request(bufnr, "textDocument/hover", position_params, function(err, response, method, ...)
      if response ~= nil then
        vim.lsp.handlers["textDocument/hover"](err, response, method, ...)
      end
    end)
  end
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

-- setup
M.setup = function(opt)
  update_config(opt)
end

M.debug = function()
  package.loaded['quarto'] = nil
  quarto = require 'quarto'
  quarto.setup {
    debug = true,
    closePreviewOnExit = true,
    lspFeatures = {
      enabled = true,
      languages = { 'python', 'r', 'julia' },
      diagnostics = {
        enabled = true
      }
    }
  }
  quarto.activateLspFeatures()
end


return M
