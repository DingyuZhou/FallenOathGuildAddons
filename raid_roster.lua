local addonName, namespace = ...

local util = namespace.util

local RaidRoster = {}

function RaidRoster:getSingletonInstance()
  if not self.instance then
    local newInstance = {}

    -- Class syntax
    self.__index = self
    newInstance = setmetatable(newInstance, self)

    self.instance = newInstance
  end

  return self.instance
end

-- persistent state: _G.RAID_MEMBER_NAME_ARRAY
function RaidRoster:persistentlySaveRaidMemberNameArray(raidMemberNameArray)
  _G.RAID_MEMBER_NAME_ARRAY = util.shallowCopy(raidMemberNameArray)
end

function RaidRoster:getRaidMemberNameArray()
  if _G.RAID_MEMBER_NAME_ARRAY then
    return util.shallowCopy(_G.RAID_MEMBER_NAME_ARRAY)
  else
    return {}
  end
end

-- persistent state: _G.DKP_TYPE_ARRAY
function RaidRoster:persistentlySaveDkpTypeArray(dkpTypeArray)
  _G.DKP_TYPE_ARRAY = util.shallowCopy(dkpTypeArray)
end

function RaidRoster:getDkpTypeArray()
  if _G.DKP_TYPE_ARRAY then
    return util.shallowCopy(_G.DKP_TYPE_ARRAY)
  else
    return {}
  end
end

-- persistent state: _G.RAID_MEMBER_DKP_DETAIL_TABLE
function RaidRoster:persistentlySaveRaidMemberDkpDetailTable(raidMemberDkpDetailTable)
  _G.RAID_MEMBER_DKP_DETAIL_TABLE = util.shallowCopy(raidMemberDkpDetailTable)
end

function RaidRoster:getRaidMemberDkpDetailTable()
  if _G.RAID_MEMBER_DKP_DETAIL_TABLE then
    return util.shallowCopy(_G.RAID_MEMBER_DKP_DETAIL_TABLE)
  else
    return {}
  end
end

function RaidRoster:clearAll()
  self:persistentlySaveRaidMemberNameArray({})
  self:persistentlySaveDkpTypeArray({})
  self:persistentlySaveRaidMemberDkpDetailTable({})
end

function RaidRoster:isNewDkpType(newDkpType)
  local dkpTypeArray = self:getDkpTypeArray()
  local isNewDkpType = true
  for index = 1, #dkpTypeArray do
    if dkpTypeArray[index] == newDkpType then
      isNewDkpType = false
      break
    end
  end
  return isNewDkpType
end

function RaidRoster:insertDkpType(newDkpType)
  local dkpTypeArray = self:getDkpTypeArray()
  if self:isNewDkpType(newDkpType) then
    table.insert(dkpTypeArray, newDkpType)
  end
  self:persistentlySaveDkpTypeArray(dkpTypeArray)
  return dkpTypeArray
end

function RaidRoster:removeDkpType(dkpTypeToRemove)
  local dkpTypeArray = self:getDkpTypeArray()
  local newDkpTypeArray = {}
  for index = 1, #dkpTypeArray do
    if dkpTypeArray[index] ~= dkpTypeToRemove then
      table.insert(newDkpTypeArray, dkpTypeArray[index])
    end
  end
  self:persistentlySaveDkpTypeArray(newDkpTypeArray)
  return newDkpTypeArray
end

function RaidRoster:getRaidRoster()
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

function RaidRoster:areRaidMemberNamesSameAsPersistentlySavedOnes(raidMemberNameListString)
  local savedRaidMemberNameArray = self:getRaidMemberNameArray()
  if #savedRaidMemberNameArray == 0 then
    return false
  end
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

function RaidRoster:getMemberNameListStringAndDkpStringFromGlobalState()
  local dkpTypeArray = self:getDkpTypeArray()
  local raidMemberNameArray = self:getRaidMemberNameArray()
  local raidMemberDkpDetailTable = self:getRaidMemberDkpDetailTable()

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

function RaidRoster:generateRaidDkpDetailsAfterAddOneDkpType(newDkpType, raidMemberNameListString, onlineMemberPoints, offlineMemberPoints)
  -- Validations

  -- If there is a saved raidMemberNameArray, then always use it to generate raid DKP details to avoid accidentally change in the raid member name input box.
  local raidMemberNameArray = self:getRaidMemberNameArray()
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

  local roster = self:getRaidRoster()
  local raidMemberDkpDetailTable = self:getRaidMemberDkpDetailTable()
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

  self:insertDkpType(trimmedNewDkpType)

  -- RaidMemberNameArray and RaidMemberDkpDetailTable should have exactly same raid members
  self:persistentlySaveRaidMemberNameArray(raidMemberNameArray)
  self:persistentlySaveRaidMemberDkpDetailTable(newRaidMemberDkpDetailTable)

  local memberNameListStr, dkpStr = self:getMemberNameListStringAndDkpStringFromGlobalState()
  return memberNameListStr, dkpStr
end

function RaidRoster:generateRaidDkpDetailsAfterRemoveOneDkpType(dkpTypeToRemove)
  -- Validations
  local trimmedDkpTypeToRemove = util.trimString(dkpTypeToRemove)
  if trimmedDkpTypeToRemove == '' then
    return "", "Warning: please input valid DKP type first, and then try it again."
  end

  local newDkpTypeArray = self:removeDkpType(trimmedDkpTypeToRemove)
  if #newDkpTypeArray == 0 then
    self:clearAll()
  end

  local memberNameListStr, dkpStr = self:getMemberNameListStringAndDkpStringFromGlobalState()
  return memberNameListStr, dkpStr
end

namespace.RaidRoster = RaidRoster
