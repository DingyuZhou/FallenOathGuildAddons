local addonName, namespace = ...

local raidRoster = {}

function raidRoster.getRaidRoster()
  local roster = {}
  local memberCount = GetNumGroupMembers();
  for i = 1, memberCount do
    local name, rank, subgroup, level, class = GetRaidRosterInfo(i)
    if (name) then
      roster[name] = { name = name, class = class }
    end
  end
  return roster
end

namespace.raidRoster = raidRoster
