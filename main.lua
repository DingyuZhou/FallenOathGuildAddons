local addonName, namespace = ...

local util = namespace.util
local raidRoster = namespace.raidRoster
local button = namespace.button
local editBox = namespace.editBox
local raidDkpUi = namespace.raidDkpUi

local sandbox = namespace.sandbox

-- sandbox.sayHelloWorld()

local inputBox = editBox.create(UIParent, "RaidRosterInput", { isAtCenter = true, isAutoFocus = true, isMovable = true })
local outputBox = editBox.create(UIParent, "RaidRosterOutput", { isAtCenter = true, isAutoFocus = false, isMovable = true })

function printRaidDkpResults()
  local newMemberNames, dkpStr = raidRoster.generateRaidDkp(inputBox:GetText(), 2, 1)
  inputBox:SetText(newMemberNames)
  outputBox:SetText(dkpStr)
end

local generateRaidDkpButton = button.create(UIParent, "generateRaidDkpButton", "Generate DKP", printRaidDkpResults, { width = 120 })

local newRaidDkpUi = raidDkpUi.create()

function toggleAddon()
  if newRaidDkpUi:IsVisible() then
    newRaidDkpUi:Hide()
  else
    newRaidDkpUi:Show()
  end
end

local addonButton = button.create(UIParent, "addonButton", "Fallen Oath", toggleAddon, { isMovable = true })
addonButton:Show()
