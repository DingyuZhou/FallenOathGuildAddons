local addonName, namespace = ...

local Button = namespace.Button
local raidDkpUi = namespace.raidDkpUi

-- local sandbox = namespace.sandbox
-- sandbox.sayHelloWorld()

local newRaidDkpUi = raidDkpUi:create()

function toggleAddon()
  if newRaidDkpUi:IsVisible() then
    newRaidDkpUi:Hide()
  else
    newRaidDkpUi:Show()
  end
end

local addonButton = Button:new(UIParent, "addonButton", "Fallen Oath", toggleAddon, { isMovable = true })
addonButton:show()
