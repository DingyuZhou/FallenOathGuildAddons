local addonName, namespace = ...

confirmDialog = {}

function confirmDialog.create(confirmDialogName, onAcceptHandler, confirmDialogConfig)
  local globalPromptDialogName = confirmDialogName .. "ConfirmDialog"
  local config = confirmDialogConfig or {}

  StaticPopupDialogs[globalPromptDialogName] = {
    text = config.text or "Are you sure?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = onAcceptHandler or (function() return nil end),
    timeout = config.timeout or 0,
    whileDead = config.whileDead or true,
    hideOnEscape = config.hideOnEscape or true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
  }

  local newPromptDialog = {}

  function newPromptDialog.show()
    StaticPopup_Show(globalPromptDialogName)
  end

  function newPromptDialog.hide()
    StaticPopup_Hide(globalPromptDialogName)
  end

  return newPromptDialog
end

namespace.confirmDialog = confirmDialog
