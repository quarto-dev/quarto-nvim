local concat = require('quarto.tools').concat
local iron_send = require('iron.core').send

---Run the code cell with iron
---@param cell CodeCell
---@param _ boolean
local function run(cell, _)
  local text_lines = concat(cell.text)
  local lang = cell.lang or 'quarto'
  -- forward to iron.send
  -- first arg is filetype. if not supplied, iron.core.send would infer "quarto".
  -- Iron lets the user map a filetype to a repl binary, e.g. {"python" = "ipython", "r" = "radian"}
  -- so we can pass the cell.lang to get the same feel from a .qmd file.
  iron_send(lang, text_lines)
end

---@class CodeRunner
local M = { run = run }

return M
