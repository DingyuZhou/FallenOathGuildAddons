local addonName, namespace = ...

local util = namespace.util

local raidRoster = {}

-- set initial state
function raidRoster.resetAll()
  _G.FallenOathRaidDkpRecords = ""
  raidRoster.dkpTypeArray = {}
  raidRoster.memberNames = ""
  raidRoster.dkpRecords = {}
end
raidRoster.resetAll()

function raidRoster.insertDkpType(newDkpType)
  -- DKP Types
  local isNewDkpType = true
  for index = 1, #raidRoster.dkpTypeArray do
    if raidRoster.dkpTypeArray[index] == newDkpType then
      isNewDkpType = false
      break
    end
  end
  if isNewDkpType then
    table.insert(raidRoster.dkpTypeArray, newDkpType)
  end
end

function raidRoster.removeDkpType(dkpTypeToRemove)
  -- DKP Types
  local newDkpTypeArray = {}
  for index = 1, #raidRoster.dkpTypeArray do
    if raidRoster.dkpTypeArray[index] ~= dkpTypeToRemove then
      table.insert(newDkpTypeArray, raidRoster.dkpTypeArray[index])
    end
  end
  raidRoster.dkpTypeArray = newDkpTypeArray
end

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

function raidRoster.generateRaidDkp(newDkpType, memberNames, onlineMemberPoints, offlineMemberPoints)
  -- Validations
  local memberNameArray = util.splitString(memberNames)
  if #memberNameArray == 0 then
    return "", "Warning: please input valid raid member names first, and then try it again."
  end

  local trimmedNewDkpType = util.trimString(newDkpType)
  local numOnlineMemberPoints = tonumber(onlineMemberPoints)
  local numOfflineMemberPoints = tonumber(offlineMemberPoints)
  if trimmedNewDkpType == '' then
    return "", "Warning: please input valid DKP type first, and then try it again."
  end
  if not numOnlineMemberPoints then
    return "", "Warning: please input valid online raid member points first, and then try it again."
  end
  if not numOfflineMemberPoints then
    return "", "Warning: please input valid offline raid member points first, and then try it again."
  end

  -- adjust DKP Types
  raidRoster.insertDkpType(trimmedNewDkpType)

  local roster = raidRoster.getRaidRoster()

  for index = 1, #memberNameArray do
    local memberName = memberNameArray[index]
    local memberInfo = roster[memberName] or {}
    local memberStatus = "absent"
    local points = 0
    if memberInfo.class then
      if memberInfo.online then
        points = numOnlineMemberPoints
        memberStatus = memberInfo.class
      else
        points = numOfflineMemberPoints
        memberStatus = memberInfo.class .. " (offline)"
      end
    end
    if not raidRoster.dkpRecords[memberName] then
      raidRoster.dkpRecords[memberName] = {}
    end
    raidRoster.dkpRecords[memberName][trimmedNewDkpType] = { status = memberStatus, points = points }
    memberInfo.hasRecorded = true
  end

  for key, val in pairs(roster) do
    if val and (not val.hasRecorded) then
      local points = val.online and numOnlineMemberPoints or numOfflineMemberPoints
      if not raidRoster.dkpRecords[key] then
        raidRoster.dkpRecords[key] = {}
      end
      local memberStatus = val.online and val.class or val.class .. " (offline)"
      raidRoster.dkpRecords[key][trimmedNewDkpType] = { status = memberStatus, points = points }
      table.insert(memberNameArray, key)
    end
  end

  local newMemberNames = ""
  local dkpStr = "Name\t"

  for index = 1, #raidRoster.dkpTypeArray do
    local type = raidRoster.dkpTypeArray[index]
    dkpStr = dkpStr .. type .. "-Status\t" .. type .. "-Points\t"
  end
  dkpStr = dkpStr .. "TotalPoints" .. "\n"

  for index = 1, #memberNameArray do
    local memberName = memberNameArray[index]
    newMemberNames = newMemberNames .. memberName .. "\n"

    dkpStr = dkpStr .. memberName .. "\t"
    local totalDkpPoints = 0
    local dkpRecords = raidRoster.dkpRecords[memberName] or {}
    for index = 1, #raidRoster.dkpTypeArray do
      local type = raidRoster.dkpTypeArray[index]
      local record = dkpRecords[type] or {}
      dkpStr = dkpStr .. (record.status or "absent") .. "\t" .. (record.points or 0) .. "\t"
      totalDkpPoints = totalDkpPoints + (record.points or 0)
    end
    dkpStr = dkpStr .. tostring(totalDkpPoints) .. "\n"
  end

  raidRoster.memberNames = newMemberNames
  _G.FallenOathRaidDkpRecords = dkpStr
  return newMemberNames, dkpStr
end

function raidRoster.removeRaidDkpType(dkpTypeToRemove)
  -- Validations
  local trimmedDkpTypeToRemove = util.trimString(dkpTypeToRemove)
  if trimmedDkpTypeToRemove == '' then
    return "", "Warning: please input valid DKP type first, and then try it again."
  end

  local memberNameArray = util.splitString(raidRoster.memberNames)
  if #memberNameArray == 0 then
    raidRoster.resetAll()
    return "", ""
  end

  -- adjust DKP Types
  raidRoster.removeDkpType(trimmedDkpTypeToRemove)

  if #raidRoster.dkpTypeArray == 0 then
    raidRoster.resetAll()
    return "", ""
  end

  local newMemberNames = ""
  local dkpStr = "Name\t"

  for index = 1, #raidRoster.dkpTypeArray do
    local type = raidRoster.dkpTypeArray[index]
    dkpStr = dkpStr .. type .. "-Status\t" .. type .. "-Points\t"
  end
  dkpStr = dkpStr .. "TotalPoints" .. "\n"

  for index = 1, #memberNameArray do
    local memberName = memberNameArray[index]
    newMemberNames = newMemberNames .. memberName .. "\n"

    dkpStr = dkpStr .. memberName .. "\t"
    local totalDkpPoints = 0
    local dkpRecords = raidRoster.dkpRecords[memberName] or {}
    for index = 1, #raidRoster.dkpTypeArray do
      local type = raidRoster.dkpTypeArray[index]
      local record = dkpRecords[type] or {}
      dkpStr = dkpStr .. (record.status or "absent") .. "\t" .. (record.points or 0) .. "\t"
      totalDkpPoints = totalDkpPoints + (record.points or 0)
    end
    dkpStr = dkpStr .. tostring(totalDkpPoints) .. "\n"
  end

  _G.FallenOathRaidDkpRecords = dkpStr
  return newMemberNames, dkpStr
end

namespace.raidRoster = raidRoster
