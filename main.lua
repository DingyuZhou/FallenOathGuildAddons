local addonName, namespace = ...

local util = namespace.util
local raidRoster = namespace.raidRoster
local editBox = namespace.editBox

local sandbox = namespace.sandbox

-- sandbox.sayHelloWorld()

local roster = raidRoster.getRaidRoster()
print(util.toString(roster))

editBox.create("RaidRosterInput", true, "adsfafsfaf edfaew")
