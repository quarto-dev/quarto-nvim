--- Code runner, configurable to use different engines.
local Runner = {}

local otterkeeper = require 'otter.keeper'
local config = require('quarto.config').config

local no_code_found = 'No code chunks found for the current language, which is detected based on the current code block. Is your cursor in a code block?'

local function overlaps_range(range, other)
  return range.from[1] <= other.to[1] and other.from[1] <= range.to[1]
end

---pull the code chunks that overlap the given range, removes cells with a language that's in the
---ignore list
---@param lang string?
---@param code_chunks table<string, CodeCell>
---@param range CodeRange
---@return CodeCell[]
local function extract_code_cells_in_range(lang, code_chunks, range)
  local chunks = {}

  if lang then
    for _, chunk in ipairs(code_chunks[lang]) do
      if overlaps_range(chunk.range, range) then
        table.insert(chunks, chunk)
      end
    end
  else
    for l, lang_chunks in pairs(code_chunks) do
      if vim.tbl_contains(config.codeRunner.never_run, l) then
        goto continue
      end
      for _, chunk in ipairs(lang_chunks) do
        if overlaps_range(chunk.range, range) then
          table.insert(chunks, chunk)
        end
      end
      ::continue::
    end
  end

  return chunks
end

-- type `Range` is already defined twice in nvim core
---@class CodeRange
---@field from table<integer>
---@field to table<integer>

---@class CodeCell
---@field lang string?
---@field text table<string>
---@field range CodeRange

---@class CodeRunner
---@field run function

---send code cell to the correct repl based on language, and user configuration
---@param cell CodeCell
---@param opts table?
local function send(cell, opts)
  opts = opts or { ignore_cols = false }
  local runner = config.codeRunner.default_method
  local ft_runners = config.codeRunner.ft_runners
  if cell.lang ~= nil and ft_runners[cell.lang] ~= nil then
    runner = ft_runners[cell.lang]
  end

  if runner ~= nil then
    require('quarto.runner.' .. runner).run(cell, opts.ignore_cols)
  else
    vim.notify("[Quarto] couldn't find appropriate code runner for language: " .. cell.lang, vim.log.levels.ERROR)
  end
end

---run the code chunks for the given language that overlap the given range
---@param range CodeRange a range, for with any overlapping code cells are run
---@param multi_lang boolean?
local function run(range, multi_lang)
  local buf = vim.api.nvim_get_current_buf()
  local lang = nil
  if not multi_lang then
    lang = otterkeeper.get_current_language_context()
  end

  otterkeeper.sync_raft(buf)
  local oa = otterkeeper.rafts[buf]
  if oa == nil then
    vim.notify("[Quarto] it seems that the code runner isn't initialized for this buffer.", vim.log.levels.ERROR)
    return
  end
  local chunks = otterkeeper.rafts[buf].code_chunks

  local filtered = extract_code_cells_in_range(lang, chunks, range)

  if #filtered == 0 then
    print(no_code_found)
    return
  end
  for _, chunk in ipairs(filtered) do
    send(chunk, { ignore_cols = true })
  end
end

---@param multi_lang boolean?
Runner.run_cell = function(multi_lang)
  local y = vim.api.nvim_win_get_cursor(0)[1] - 1
  local r = { y, 0 }
  local range = { from = r, to = r }

  run(range, multi_lang)
end

---@param multi_lang boolean?
Runner.run_above = function(multi_lang)
  local y = vim.api.nvim_win_get_cursor(0)[1] - 1
  local range = { from = { 0, 0 }, to = { y, 0 } }

  run(range, multi_lang)
end

---@param multi_lang boolean?
Runner.run_below = function(multi_lang)
  local y = vim.api.nvim_win_get_cursor(0)[1] - 1
  local range = { from = { y, 0 }, to = { math.huge, 0 } }

  run(range, multi_lang)
end

---@param multi_lang boolean?
Runner.run_all = function(multi_lang)
  local range = { from = { 0, 0 }, to = { math.huge, 0 } }

  run(range, multi_lang)
end

Runner.run_line = function()
  local buf = vim.api.nvim_get_current_buf()
  local lang = otterkeeper.get_current_language_context()
  local pos = vim.api.nvim_win_get_cursor(0)

  ---@type CodeCell
  local cell = {
    lang = lang,
    range = { from = { pos[1] - 1, 0 }, to = { pos[1], 0 } },
    text = vim.api.nvim_buf_get_lines(buf, pos[1] - 1, pos[1], false),
  }

  send(cell, { ignore_cols = true })
end

-- NOTE: This function will not work the same with molten as it does with slime. Generally, code
-- runners which run code based on the CodeCell range field, will not work when the user selects
-- code across cells. But it will work if a selection is entirely within a cell.
-- Also: This function cannot run multiple languages at once.
Runner.run_range = function()
  local lines = otterkeeper.get_language_lines_in_visual_selection(true)
  if lines == nil then
    print(no_code_found)
    return
  end

  local vstart = vim.fn.getpos "'<"
  local vend = vim.fn.getpos "'>"

  if vstart and vend then
    local range = { from = { vstart[2] - 1, vstart[1] }, to = { vend[2], vend[1] } }
    send { lang = otterkeeper.get_current_language_context(), range = range, text = lines }
  else
    print 'No visual selection'
  end
end

return Runner
