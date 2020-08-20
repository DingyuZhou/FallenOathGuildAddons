local addonName, namespace = ...

local util = namespace.util

MessageDialog = {}

function MessageDialog:new(messageDialogName, messageText, onAcceptHandler, messageDialogConfig)
  local newInstance = {}
  local config = messageDialogConfig or {}

  newInstance.name = util.generateGlobalValidUiName(messageDialogName)
  StaticPopupDialogs[newInstance.name] = {
    text = messageText or "",
    button1 = config.buttonText or "OK",
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

function MessageDialog:show()
  if self.name then
    StaticPopup_Show(self.name)
  end
end

function MessageDialog:hide()
  if self.name then
    StaticPopup_Hide(self.name)
  end
end

namespace.MessageDialog = MessageDialog
