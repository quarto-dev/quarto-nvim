M = {}

M.contains = function(list, x)
  for _, v in pairs(list) do
    if v == x then return true end
  end
  return false
end


M.lines = function(str)
  local result = {}
  for line in str:gmatch '([^\n]*)\n?' do
    table.insert(result, line)
  end
  result[#result] = nil
  return result
end

M.spaces = function(n)
  local s = {}
  for i = 1, n do
    s[i] = ' '
  end
  return s
end

return M

