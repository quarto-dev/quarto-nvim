local M = {}
local a = vim.api
local q = vim.treesitter.query
local util = require "lspconfig.util"

local defaultConfig = {
  closePreviewOnExit = true,
}

M.setup = function(opt)
  M.config = vim.tbl_deep_extend('force', defaultConfig, opt or {})
end


local function contains(list, x)
  for _, v in pairs(list) do
    if v == x then return true end
  end
  return false
end

function M.quartoPreview()
  -- find root directory / check if it is a project
  local buffer_path = a.nvim_buf_get_name(0)
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
  if mode == "file" and not contains(quarto_extensions, file_extension) then
    vim.notify("Not a quarto file, ends in " .. file_extension .. " exiting.")
    return
  end

  -- run command in embedded terminal
  -- in a new tab and go back to the buffer
  vim.cmd('tabedit term://' .. cmd)
  local quartoOutputBuf = vim.api.nvim_get_current_buf()
  vim.cmd('tabprevious')


  -- close preview terminal on exit of the quarto buffer
  if M.config.closePreviewOnExit then
    a.nvim_create_autocmd({ "QuitPre", "WinClosed" }, {
      buffer = a.nvim_get_current_buf(),
      group = a.nvim_create_augroup("quartoPreview", {}),
      callback = function(_, _)
        if a.nvim_buf_is_loaded(quartoOutputBuf) then
          a.nvim_buf_delete(quartoOutputBuf, { force = true })
        end
      end
    })
  end
end




-- lps support
local function lines(str)
  local result = {}
  for line in str:gmatch '[^\n]+' do
    table.insert(result, line)
  end
  return result
end

local function spaces(n)
  local s = {}
  for i=1,n do
    s[i] = ' '
  end
  return s
end

local function get_language_content(bufnr, language)
  -- get and parse AST
  local language_tree = vim.treesitter.get_parser(bufnr, 'markdown')
  local syntax_tree = language_tree:parse()
  local root = syntax_tree[1]:root()

  -- create capture
  local query = vim.treesitter.parse_query('markdown',
  string.gsub([[
  (fenced_code_block
    (info_string
      (language) @lang
      (#eq? @lang $language)
    )
    (code_fence_content) @code (#offset! @code)
  )
  ]], "%$(%w+)", {language=language})
  )

  -- get text ranges
  local results = {}
  for _, captures, metadata in query:iter_matches(root, bufnr) do
    local text = q.get_node_text(captures[2], bufnr)
    -- line numbers start at 0
    -- {start line, col, end line, col}
    local result = {range = metadata.content[1],
                    text = lines(text)}
    table.insert(results, result)
  end

  return results
end


local function update_language_buffer(qmd_bufnr, language)
  local language_lines = get_language_content(qmd_bufnr, language)
  local nmax = a.nvim_buf_line_count(qmd_bufnr)
  local qmd_path = a.nvim_buf_get_name(qmd_bufnr)
  local postfix
  if language == 'python' then
    postfix = '.py'
  elseif language == 'r' then
    postfix = '.R'
  end

  -- create buffer filled with spaces
  local bufname_lang = qmd_path..postfix
  local bufuri_lang = 'file://'..bufname_lang
  local bufnr_lang = vim.uri_to_bufnr(bufuri_lang)
  a.nvim_buf_set_name(bufnr_lang, bufname_lang)
  a.nvim_buf_set_lines(bufnr_lang, 0, -1, false, {})
  a.nvim_buf_set_lines(bufnr_lang, 0, nmax, false, spaces(nmax))

  -- write langue lines
  for _,t in ipairs(language_lines) do
    a.nvim_buf_set_lines(bufnr_lang, t.range[1], t.range[3], false, t.text)
  end
  return bufnr_lang
end


M.attach_lang = function (bufnr_qmd, lang)
  local bufnr_py = update_language_buffer(bufnr_qmd, lang)
  return bufnr_py
end


M.send_hover_request = function (bufnr_lang)
  local cursor = a.nvim_win_get_cursor(0)
  local params = {
    textDocument = {
      uri = "file://"..a.nvim_buf_get_name(bufnr_lang)
    },
    position = {
      line = cursor[1] - 1,
      character = cursor[2],
    }
  }
  local clients = vim.lsp.buf_get_clients(bufnr_lang)
end

-- local attach_docs = function()
--   local bufnr_py = M.attach_py(0)
--   P('attached py buffer')
--   P(bufnr_py)
--   local get_hover = function ()
--     M.send_hover_request(bufnr_py)
--   end
--   nmap('K', get_hover)
-- end

M.debug = function()
  local qmd_buf = a.nvim_get_current_buf()
  local py_buf = M.attach_lang(qmd_buf, 'python')
  local r_buf = M.attach_lang(qmd_buf, 'r')

  local ns  = a.nvim_create_namespace('quarto')
  local py_diag = vim.diagnostic.get(py_buf)
  local r_diag = vim.diagnostic.get(r_buf)

  local py_extmarks = a.nvim_buf_get_extmarks(py_buf, ns, 0, -1, {})
  local r_extmarks = a.nvim_buf_get_extmarks(r_buf, ns, 0, -1, {})
  local pos = a.nvim_win_get_cursor(0)

  vim.diagnostic.reset(ns, qmd_buf)
  vim.diagnostic.set(ns, qmd_buf, r_diag, {})


  a.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = qmd_buf,
    group = a.nvim_create_augroup("quartoUpdate", {}),
    callback = function(_, _)
      py_buf = M.attach_lang(qmd_buf, 'python')
      r_buf = M.attach_lang(qmd_buf, 'r')
    end
  })

  -- print('py: '..py_buf..' r: '..r_buf)
end



return M
