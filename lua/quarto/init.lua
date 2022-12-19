local M = {}
local api = vim.api
local util = require "lspconfig.util"
local source = require'quarto.source'
local tools = require'quarto.tools'
local lines = tools.lines
local spaces = tools.spaces
local api = vim.api

M.defaultConfig = {
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


local function get_language_content(bufnr)
  -- get and parse AST
  local language_tree = vim.treesitter.get_parser(bufnr, 'markdown')
  local syntax_tree = language_tree:parse()
  local root = syntax_tree[1]:root()

  -- create capture
  local query = vim.treesitter.parse_query('markdown',
    [[
    (fenced_code_block
    (info_string
      (language) @lang
    )
    (code_fence_content) @code (#offset! @code)
    )
    ]]
  )

  -- get text ranges
  local results = {}
  for pattern, match, metadata in query:iter_matches(root, bufnr) do
    local lang
    for id, node in pairs(match) do
      local name = query.captures[id]
      local text = vim.treesitter.query.get_node_text(node, 0)
      if name == 'lang' then
        lang = text
      end
      if name == 'code' then
        local row1, col1, row2, col2 = node:range() -- range of the capture
        local result = {
          range = { from = { row1, col1 }, to = { row2, col2 } },
          lang = lang,
          text = lines(text)
        }
        if results[lang] == nil then
          results[lang] = {}
        end
        table.insert(results[lang], result)
      end
    end
  end

  return results
end

M.updateLanguageBuffers = function(qmd_bufnr)
  local language_content = get_language_content(qmd_bufnr)
  local bufnrs = {}
  for _, lang in ipairs(M.config.lspFeatures.languages) do
    local language_lines = language_content[lang]
    if language_lines ~= nil then
      local postfix
      if lang == 'python' then
        postfix = '.py'
      elseif lang == 'r' then
        postfix = '.R'
      elseif lang == 'julia' then
        postfix = '.jl'
      end

      local nmax = language_lines[#language_lines].range['to'][1] -- last code line
      local qmd_path = api.nvim_buf_get_name(qmd_bufnr)

      -- create buffer filled with spaces
      local bufname_lang = qmd_path .. '-tmp' .. postfix
      local bufuri_lang = 'file://' .. bufname_lang
      local bufnr_lang = vim.uri_to_bufnr(bufuri_lang)
      table.insert(bufnrs, bufnr_lang)
      api.nvim_buf_set_name(bufnr_lang, bufname_lang)
      api.nvim_buf_set_option(bufnr_lang, 'filetype', lang)
      api.nvim_buf_set_lines(bufnr_lang, 0, -1, false, {})
      api.nvim_buf_set_lines(bufnr_lang, 0, nmax, false, spaces(nmax))

      -- write language lines
      for _, t in ipairs(language_lines) do
        api.nvim_buf_set_lines(bufnr_lang, t.range['from'][1], t.range['to'][1], false, t.text)
      end
    end
  end
  return bufnrs
end

---Registered client and source mapping.
M.cmp_client_source_map = {}

---Setup cmp-nvim-lsp source.
M.cmp_setup_source = function(qmdbufnr, bufnr)
  local callback = function()
    M.cmp_on_insert_enter(qmdbufnr, bufnr)
  end
  vim.api.nvim_create_autocmd('InsertEnter', {
    buffer = qmdbufnr,
    group = vim.api.nvim_create_augroup('cmp_quarto'..bufnr, { clear = true }),
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
      local s = source.new(client, qmdbufnr, bufnr, M.updateLanguageBuffers)
      if s:is_available() then
        P('register source for ' .. s.client.name)
        M.cmp_client_source_map[client.id] = cmp.register_source('quarto', s)
      end
    end
  end

  -- register all buffer clients (early register before activation)
  for _, client in ipairs(vim.lsp.buf_get_clients(0)) do
    allowed_clients[client.id] = client
    if not M.cmp_client_source_map[client.id] then
      local s = source.new(client, qmdbufnr, bufnr, M.updateLanguageBuffers)
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

M.activateLspFeatures = function()
  local qmdbufnr = api.nvim_get_current_buf()
  local bufnrs = M.updateLanguageBuffers(qmdbufnr)

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

  if M.config.lspFeatures.diagnostics.enabled then
    M.enableDiagnostics()
  end

  if M.config.lspFeatures.cmpSource.enabled then
    for _,bufnr in ipairs(bufnrs) do
      M.cmp_setup_source(qmdbufnr, bufnr)
    end

    api.nvim_create_autocmd({ "TextChangedI" }, {
      buffer = 0,
      group = api.nvim_create_augroup("quartoCmp", { clear = false }),
      callback = function(_, _)
        local bufnrs = M.updateLanguageBuffers(0)
      end
    })
  end

  local key = M.config.keymap.hover
  vim.api.nvim_set_keymap('n', key, ":lua require'quarto'.quartoHover()<cr>", { silent = true })
end

M.enableDiagnostics = function()
  -- update diagnostics on changes
  api.nvim_create_autocmd({ "CursorHold", "TextChanged" }, {
    buffer = 0,
    group = api.nvim_create_augroup("quartoLSPDiagnositcs", { clear = false }),
    callback = function(_, _)
      local bufnrs = M.updateLanguageBuffers(0)
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
  local bufnrs = M.updateLanguageBuffers(qmdbufnr)
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
  M.config = vim.tbl_deep_extend('force', M.defaultConfig, opt or {})
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
