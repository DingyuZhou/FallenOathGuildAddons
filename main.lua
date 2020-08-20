local addonName, namespace = ...

local Button = namespace.Button
local RaidDkpUi = namespace.RaidDkpUi

-- local sandbox = namespace.sandbox
-- sandbox.sayHelloWorld()

local addonButton = Button:new(UIParent, "addonButton", "Fallen Oath", nil, { isMovable = true })

addonButton:registerEvent("ADDON_LOADED")
addonButton:setScript(
  "OnEvent",
  function(self, eventName, addonName)
    if eventName == "ADDON_LOADED" and addonName == "FallenOathGuildAddons" then
      local raidDkpUiSingletonInstance = RaidDkpUi:getSingletonInstance()

      addonButton:setOnClickHandler(
        function()
          if raidDkpUiSingletonInstance:isVisible() then
            raidDkpUiSingletonInstance:hide()
          else
            raidDkpUiSingletonInstance:show()
          end
        end
      )

      addonButton:show()
    end
  end
)
