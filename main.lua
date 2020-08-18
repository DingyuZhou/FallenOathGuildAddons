local addonName, namespace = ...

local util = namespace.util
local raidRoster = namespace.raidRoster
local sandbox = namespace.sandbox

-- sandbox.sayHelloWorld()

local roster = raidRoster.getRaidRoster()
print(util.toString(roster))
