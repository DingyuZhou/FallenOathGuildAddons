local addonName, namespace = ...

local util = {}

function util.toString(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. util.toString(v) .. ', '
    end
    return s .. '}'
  else
    return tostring(o)
  end
end

function util.splitString(inputStr, separator)
  local sep = separator or "%s"
  local array = {}
  local index = 1
  for str in string.gmatch(inputStr, "([^"..sep.."]+)") do
    array[index] = str
    index = index + 1
  end
  return array
end

namespace.util = util
