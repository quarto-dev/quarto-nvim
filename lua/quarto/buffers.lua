local tools = require'quarto.tools'
local config = require'quarto.config'.config
local lines = tools.lines
local spaces = tools.spaces
local api = vim.api

M = {}

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
  for _, lang in ipairs(config.lspFeatures.languages) do
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

return M
