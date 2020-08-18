local addonName, namespace = ...

local util = namespace.util

local raidRoster = {}

function raidRoster.getRaidRoster()
  local roster = {}
  local memberCount = GetNumGroupMembers();
  for i = 1, memberCount do
    local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i)
    if (name) then
      roster[name] = { name = name, class = class, zone = zone, online = online }
    end
  end
  return roster
end

function raidRoster.generateRaidDkp(dkpNote, memberNames, onlineMemberPoints, offlineMemberPoints)
  local roster = raidRoster.getRaidRoster()

  local memberNameArray = util.splitString(memberNames)

  if #memberNameArray == 0 then
    return "", "Warning: please input valid raid member names first, and then try to generate DKP again."
  end

  local dkpStr = "Member Name\tMemberStatus\t" .. dkpNote .. "\n"
  for index = 1, #memberNameArray do
    local memberName = memberNameArray[index]
    local memberInfo = roster[memberName] or {}
    local memberStatus = "absent"
    local points = 0
    if memberInfo.class then
      if memberInfo.online then
        points = onlineMemberPoints
        memberStatus = memberInfo.class
      else
        points = offlineMemberPoints
        memberStatus = memberInfo.class .. " (offline)"
      end
    end
    dkpStr = dkpStr .. memberName .. "\t" .. memberStatus .. "\t" .. tostring(points) .. "\n"
    memberInfo.hasRecorded = true
  end

  for key, val in pairs(roster) do
    if val and (not val.hasRecorded) then
      local points = val.online and onlineMemberPoints or offlineMemberPoints
      dkpStr = dkpStr .. val.name .. "\t" .. val.class .. "\t" .. tostring(points) .. "\n"
      table.insert(memberNameArray, val.name)
    end
  end

  local newMemberNames = ''
  for index = 1, #memberNameArray do
    local memberName = memberNameArray[index]
    newMemberNames = newMemberNames .. memberName .. "\n"
  end

  return newMemberNames, dkpStr
end

namespace.raidRoster = raidRoster
