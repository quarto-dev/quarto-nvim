---Run the code cell with molten
---@param cell CodeCell
---@param ignore_cols boolean
local function run(cell, ignore_cols)
  local range = cell.range
  if ignore_cols then
    vim.fn.MoltenEvaluateRange(range.from[1] + 1, range.to[1])
  else
    vim.fn.MoltenEvaluateRange(range.from[1] + 1, range.to[1], range.from[2] + 1, range.to[2] + 1)
  end
end

---@class CodeRunner
local M = { run = run }

return M
