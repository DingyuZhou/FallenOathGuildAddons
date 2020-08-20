local addonName, namespace = ...

local util = {}

function util.generateGlobalValidUiName(seedUiName)
  local validUiName = seedUiName
  while _G[validUiName] do
    validUiName = validUiName .. math.random(0, 9)
  end
  return validUiName
end

function util.shallowCopy(original)
  local original_type = type(original)
  local copy
  if original_type == 'table' then
    copy = {}
    for original_key, original_value in pairs(original) do
      copy[original_key] = original_value
    end
  else -- number, string, boolean, etc
    copy = original
  end
  return copy
end

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

function util.trimString(inputStr)
  return (string.gsub(inputStr, "^%s*(.-)%s*$", "%1"))
end

namespace.util = util
