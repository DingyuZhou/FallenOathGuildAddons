local addonName, namespace = ...

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

local addonButton = button:create(UIParent, "addonButton", "Fallen Oath", toggleAddon, { isMovable = true })
addonButton:Show()
