local M = {}

M.contains = function(list, x)
  for _, v in pairs(list) do
    if v == x then return true end
  end
  return false
end

M.replace_header_div = function(response)
  response.contents = response.contents:gsub('<div class="container">', '')
  return response
end

return M
