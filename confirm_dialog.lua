local addonName, namespace = ...

local util = namespace.util

ConfirmDialog = {}

function ConfirmDialog:new(confirmDialogName, onAcceptHandler, confirmDialogConfig)
  local newInstance = {}
  local config = confirmDialogConfig or {}

  newInstance.name = util.generateGlobalValidUiName(confirmDialogName)
  StaticPopupDialogs[newInstance.name] = {
    text = config.text or "Are you sure?",
    button1 = config.acceptButtonText or "Yes",
    button2 = config.denyButtonText or "No",
    OnAccept = onAcceptHandler or (function() return nil end),
    timeout = config.timeout or 0,
    whileDead = config.whileDead or true,
    hideOnEscape = config.hideOnEscape or true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
  }

  -- Class syntax
  self.__index = self
  newInstance = setmetatable(newInstance, self)

  return newInstance
end

function ConfirmDialog:show()
  if self.name then
    StaticPopup_Show(self.name)
  end
end

function ConfirmDialog:hide()
  if self.name then
    StaticPopup_Hide(self.name)
  end
end

namespace.ConfirmDialog = ConfirmDialog
