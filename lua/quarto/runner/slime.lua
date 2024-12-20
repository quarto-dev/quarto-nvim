local concat = require('quarto.tools').concat

---Run the code cell with slime
---@param cell CodeCell
---@param _ boolean
local function run(cell, _)
  local text_lines = concat(cell.text)
  vim.fn['slime#send'](text_lines)
end

---@class CodeRunner
local M = { run = run }

return M
