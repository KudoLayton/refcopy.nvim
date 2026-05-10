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

function M.resolve(formats, default_name, requested_name)
  local name = requested_name
  if name == nil or name == "" then
    name = default_name
  end

  local template = formats and formats[name]
  if template == nil then
    return nil, ("refcopy.nvim: unknown format '%s'"):format(name)
  end

  return template, nil, name
end

return M
