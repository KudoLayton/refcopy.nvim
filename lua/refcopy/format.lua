local M = {}

local function token_value(tokens, key)
  local value = tokens[key]
  if value == nil then
    return ""
  end
  return tostring(value)
end

function M.render(template, tokens)
  return (template:gsub("{([%w_]+)}", function(key)
    return token_value(tokens, key)
  end))
end

return M
