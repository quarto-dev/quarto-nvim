local quarto = R'quarto'
local q = vim.treesitter.query
local api = vim.api
local bufnr = 14


local function lines(str)
  local result = {}
  for line in str:gmatch '[^\n]+' do
    table.insert(result, line)
  end
  return result
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


local language = 'python'
local text = get_language_content(bufnr, language)



-- TODO: it might be easier to get all the lines
-- not belonging to the language, copying the buffer
-- and replace those lines with spaces
local function get_non_language_lines(bufnr, language)
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
  for _, _, metadata in query:iter_matches(root, bufnr) do
    -- line numbers start at 0
    -- {start line, col, end line, col}
    table.insert(results,metadata.content[1])
  end

  return results

end

lines = get_non_language_lines(bufnr, language)
P(lines)

-- -- create new emtpy buffer
-- local buf = api.nvim_create_buf(true, false)
-- -- api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
--
-- for _,t in ipairs(text) do
--   -- does not write empty lines
--   api.nvim_buf_set_lines(buf, t.range[1], t.range[3], false, t.text)
-- end

