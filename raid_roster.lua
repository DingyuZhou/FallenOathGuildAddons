local addonName, namespace = ...

local util = namespace.util

local raidRoster = {}

-- persistent state: _G.RAID_MEMBER_NAME_ARRAY
function raidRoster.persistentlySaveRaidMemberNameArray(raidMemberNameArray)
  _G.RAID_MEMBER_NAME_ARRAY = util.shallowCopy(raidMemberNameArray)
end

function raidRoster.getRaidMemberNameArray()
  if _G.RAID_MEMBER_NAME_ARRAY then
    return util.shallowCopy(_G.RAID_MEMBER_NAME_ARRAY)
  else
    return {}
  end
end

-- persistent state: _G.DKP_TYPE_ARRAY
function raidRoster.persistentlySaveDkpTypeArray(dkpTypeArray)
  _G.DKP_TYPE_ARRAY = util.shallowCopy(dkpTypeArray)
end

function raidRoster.getDkpTypeArray()
  if _G.DKP_TYPE_ARRAY then
    return util.shallowCopy(_G.DKP_TYPE_ARRAY)
  else
    return {}
  end
end

-- persistent state: _G.RAID_MEMBER_DKP_DETAIL_TABLE
function raidRoster.persistentlySaveRaidMemberDkpDetailTable(raidMemberDkpDetailTable)
  _G.RAID_MEMBER_DKP_DETAIL_TABLE = util.shallowCopy(raidMemberDkpDetailTable)
end

function raidRoster.getRaidMemberDkpDetailTable()
  if _G.RAID_MEMBER_DKP_DETAIL_TABLE then
    return util.shallowCopy(_G.RAID_MEMBER_DKP_DETAIL_TABLE)
  else
    return {}
  end
end

function raidRoster.clearAll()
  raidRoster.persistentlySaveRaidMemberNameArray({})
  raidRoster.persistentlySaveDkpTypeArray({})
  raidRoster.persistentlySaveRaidMemberDkpDetailTable({})
end

function raidRoster.insertDkpType(newDkpType)
  local dkpTypeArray = raidRoster.getDkpTypeArray()
  local isNewDkpType = true
  for index = 1, #dkpTypeArray do
    if dkpTypeArray[index] == newDkpType then
      isNewDkpType = false
      break
    end
  end
  if isNewDkpType then
    table.insert(dkpTypeArray, newDkpType)
  end
  raidRoster.persistentlySaveDkpTypeArray(dkpTypeArray)
  return dkpTypeArray
end

function raidRoster.removeDkpType(dkpTypeToRemove)
  local dkpTypeArray = raidRoster.getDkpTypeArray()
  local newDkpTypeArray = {}
  for index = 1, #dkpTypeArray do
    if dkpTypeArray[index] ~= dkpTypeToRemove then
      table.insert(newDkpTypeArray, dkpTypeArray[index])
    end
  end
  raidRoster.persistentlySaveDkpTypeArray(newDkpTypeArray)
  return newDkpTypeArray
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

function raidRoster.areRaidMemberNamesSameAsPersistentlySavedOnes(raidMemberNameListString)
  local savedRaidMemberNameArray = raidRoster.getRaidMemberNameArray()
  local raidMemberNameArray = util.splitString(raidMemberNameListString)
  if #savedRaidMemberNameArray ~= #raidMemberNameArray then
    return true
  end
  for index = 1, #savedRaidMemberNameArray do
    if savedRaidMemberNameArray[index] ~= raidMemberNameArray[index] then
      return true
    end
  end
  return false
end

function raidRoster.getMemberNameListStringAndDkpStringFromGlobalState()
  local dkpTypeArray = raidRoster.getDkpTypeArray()
  local raidMemberNameArray = raidRoster.getRaidMemberNameArray()
  local raidMemberDkpDetailTable = raidRoster.getRaidMemberDkpDetailTable()

  if #raidMemberNameArray == 0 or #dkpTypeArray == 0 then
    return "", ""
  end

  local memberNameListStr = ""
  local dkpStr = "Name\t"

  for index = 1, #dkpTypeArray do
    local type = dkpTypeArray[index]
    dkpStr = dkpStr .. type .. "-Status\t" .. type .. "-Points\t"
  end
  dkpStr = dkpStr .. "TotalPoints" .. "\n"

  for index = 1, #raidMemberNameArray do
    local memberName = raidMemberNameArray[index]
    memberNameListStr = memberNameListStr .. memberName .. "\n"

    dkpStr = dkpStr .. memberName .. "\t"
    local totalDkpPoints = 0
    local dkpRecords = raidMemberDkpDetailTable[memberName] or {}
    for index = 1, #dkpTypeArray do
      local type = dkpTypeArray[index]
      local record = dkpRecords[type] or {}
      dkpStr = dkpStr .. (record.status or "absent") .. "\t" .. (record.points or 0) .. "\t"
      totalDkpPoints = totalDkpPoints + (record.points or 0)
    end
    dkpStr = dkpStr .. tostring(totalDkpPoints) .. "\n"
  end

  return memberNameListStr, dkpStr
end

function raidRoster.generateRaidDkpDetailsAfterAddOneDkpType(newDkpType, raidMemberNameListString, onlineMemberPoints, offlineMemberPoints)
  -- Validations

  -- If there is a saved raidMemberNameArray, then always use it to generate raid DKP details to avoid accidentally change in the raid member name input box.
  local raidMemberNameArray = raidRoster.getRaidMemberNameArray()
  if #raidMemberNameArray == 0 then
    raidMemberNameArray = util.splitString(raidMemberNameListString)
    if #raidMemberNameArray == 0 then
      return "", "Warning: please input valid raid member names first, and then try it again."
    end
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

  local roster = raidRoster.getRaidRoster()
  local raidMemberDkpDetailTable = raidRoster.getRaidMemberDkpDetailTable()
  local newRaidMemberDkpDetailTable = {}

  for index = 1, #raidMemberNameArray do
    local memberName = raidMemberNameArray[index]
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
    if raidMemberDkpDetailTable[memberName] then
      newRaidMemberDkpDetailTable[memberName] = util.shallowCopy(raidMemberDkpDetailTable[memberName])
    else
      newRaidMemberDkpDetailTable[memberName] = {}
    end
    newRaidMemberDkpDetailTable[memberName][trimmedNewDkpType] = { status = memberStatus, points = points }
    memberInfo.hasRecorded = true
    roster[memberName] = memberInfo
  end

  for key, val in pairs(roster) do
    if val and (not val.hasRecorded) then
      local points = val.online and numOnlineMemberPoints or numOfflineMemberPoints
      if raidMemberDkpDetailTable[key] then
        newRaidMemberDkpDetailTable[key] = util.shallowCopy(raidMemberDkpDetailTable[key])
      else
        newRaidMemberDkpDetailTable[key] = {}
      end
      local memberStatus = val.online and val.class or val.class .. " (offline)"
      newRaidMemberDkpDetailTable[key][trimmedNewDkpType] = { status = memberStatus, points = points }
      table.insert(raidMemberNameArray, key)
    end
  end

  raidRoster.insertDkpType(trimmedNewDkpType)
  raidRoster.persistentlySaveRaidMemberNameArray(raidMemberNameArray)
  raidRoster.persistentlySaveRaidMemberDkpDetailTable(newRaidMemberDkpDetailTable)

  local memberNameListStr, dkpStr = raidRoster.getMemberNameListStringAndDkpStringFromGlobalState()
  return memberNameListStr, dkpStr
end

function raidRoster.generateRaidDkpDetailsAfterRemoveOneDkpType(dkpTypeToRemove)
  -- Validations
  local trimmedDkpTypeToRemove = util.trimString(dkpTypeToRemove)
  if trimmedDkpTypeToRemove == '' then
    return "", "Warning: please input valid DKP type first, and then try it again."
  end

  local newDkpTypeArray = raidRoster.removeDkpType(trimmedDkpTypeToRemove)
  if #newDkpTypeArray == 0 then
    raidRoster.clearAll()
  end

  local memberNameListStr, dkpStr = raidRoster.getMemberNameListStringAndDkpStringFromGlobalState()
  return memberNameListStr, dkpStr
end

namespace.raidRoster = raidRoster
