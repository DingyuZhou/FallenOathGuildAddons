local addonName, namespace = ...

local util = namespace.util
local raidRoster = namespace.raidRoster
local button = namespace.button
local editBox = namespace.editBox

local sandbox = namespace.sandbox

-- sandbox.sayHelloWorld()

local inputBox, inputBoxEditBox = editBox.create(UIParent, "RaidRosterInput", true)
local outputBox, outputBoxEditBox = editBox.create(UIParent, "RaidRosterOutput", false)

function printRaidDkpResults()
  local newMemberNames, dkpStr = raidRoster.generateRaidDkp(inputBoxEditBox:GetText(), 2, 1)
  inputBoxEditBox:SetText(newMemberNames)
  outputBoxEditBox:SetText(dkpStr)
end

local generateRaidDkpButton = button.create(UIParent, "generateRaidDkpButton", "Generate DKP", printRaidDkpResults, 120)

function toggleAddon()
  if generateRaidDkpButton:IsVisible() then
    inputBox:Hide()
    outputBox:Hide()
    generateRaidDkpButton:Hide()
  else
    inputBox:Show()
    outputBox:Show()
    generateRaidDkpButton:Show()
  end
end

local addonButton = button.create(UIParent, "addonButton", "Fallen Oath", toggleAddon)
addonButton:Show()
