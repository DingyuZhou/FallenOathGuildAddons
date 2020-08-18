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

namespace.util = util
