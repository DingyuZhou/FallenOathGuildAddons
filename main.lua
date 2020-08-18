local addonName, namespace = ...

local util = namespace.util
local raidRoster = namespace.raidRoster
local button = namespace.button
local editBox = namespace.editBox

local sandbox = namespace.sandbox

-- sandbox.sayHelloWorld()

local inputBox = editBox.create(UIParent, "RaidRosterInput", true)
local outputBox, outputBoxEditBox = editBox.create(UIParent, "RaidRosterOutput", false)

function printRaidRoster()
  local roster = raidRoster.getRaidRoster()
  outputBoxEditBox:SetText(util.toString(roster))
end

local printRaidRosterButton = button.create(UIParent, "printRaidRoster", "Print Raid Roster", printRaidRoster, 150)

function startAddon()
  inputBox:Show()
  outputBox:Show()
  printRaidRosterButton:Show()
end

local addonButton = button.create(UIParent, "addonButton", "Fallen Oath", startAddon)
addonButton:Show()
