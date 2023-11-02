local M = {}

M.contains = function(list, x)
  for _, v in pairs(list) do
    if v == x then
      return true
    end
  end
  return false
end

M.replace_header_div = function(response)
  response.contents = response.contents:gsub('<div class="container">', "")
  return response
end

M.concat = function(ls)
  if type(ls) ~= "table" then
    return ls .. "\n\n"
  end
  local s = ""
  for _, l in ipairs(ls) do
    if l ~= "" then
      s = s .. "\n" .. l
    end
  end
  return s .. "\n"
end

return M
