local addonName, namespace = ...

local util = namespace.util
local Button = namespace.Button
local MessageDialog = namespace.MessageDialog
local ConfirmDialog = namespace.ConfirmDialog
local raidRoster = namespace.raidRoster

local RaidDkpUi = {}

-- Need better refactoring
function RaidDkpUi:getSingletonInstance()
  if not self.instance then
    local newInstance = {}

    -- Class syntax
    self.__index = self
    newInstance = setmetatable(newInstance, self)

    local raidDkpUiName = "RaidDkpUi"
    newInstance.mainFrameName = util.generateGlobalValidUiName(raidDkpUiName .. "MainFrame")

    local inputBoxName = raidDkpUiName .. "InputBox"
    local outputBoxName = raidDkpUiName .. "OutputBox"
    local dkpTypeEditBoxName = raidDkpUiName .. "DkpTypeEditBox"
    local onlineMemberPointEditBoxName = raidDkpUiName .. "OnlineMemberPointEditBox"
    local offlineMemberPointEditBoxName = raidDkpUiName .. "OfflineMemberPointEditBox"
    local dkpGenerateButtonName = raidDkpUiName .. "DkpGenerateButton"
    local dkpGenerateConfirmDialogName = raidDkpUiName .. "dkpGenerateConfirmDialog"
    local removeDkpTypeButtonName = raidDkpUiName .. "RemoveDkpTypeButton"
    local removeDkpTypeConfirmDialogName = raidDkpUiName .. "RemoveDkpTypeConfirmDialog"
    local clearAllDkpButtonName = raidDkpUiName .. "ClearAllDkpButton"
    local clearAllDkpConfirmDialogName = raidDkpUiName .. "ClearAllDkpConfirmDialog"
    local closeButtonName = raidDkpUiName .. "CloseButton"

    local f = CreateFrame("Frame", newInstance.mainFrameName, UIParent)
    mainFrame = f
    mainFrame:Hide()

    f:SetPoint("CENTER")
    f:SetSize(1200, 700)

    -- Movable
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetScript("OnMouseDown", function(self, button)
      if button == "LeftButton" then
        self:StartMoving()
      end
    end)
    f:SetScript("OnMouseUp", f.StopMovingOrSizing)

    f:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    f:SetBackdropColor(1, 1, 1, 0.3)

    -- Input Box ScrollFrame
    local inputBoxScrollFrameName = inputBoxName .. "ScrollFrame"
    local ibsf = CreateFrame("ScrollFrame", inputBoxScrollFrameName, f, "UIPanelScrollFrameTemplate")
    ibsf:SetPoint("LEFT", 20, 0)
    ibsf:SetPoint("RIGHT", f, "LEFT", 200, 0)
    ibsf:SetPoint("TOP", f, "TOP", 0, -30)
    ibsf:SetPoint("BOTTOM", f, "BOTTOM", 0, 20)

    ibsf:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      insets = { left = -10, right = -30, top = -10, bottom = -10 }
    })

    local inputBoxHintText = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
    inputBoxHintText:SetPoint("TOPLEFT", ibsf, "TOPLEFT", -8, 25)
    inputBoxHintText:SetText("Raid Member Names")

    -- Input Box
    local ib = CreateFrame("EditBox", inputBoxName, ibsf)
    ib:SetSize(ibsf:GetSize())
    ib:SetMultiLine(true)
    ib:SetAutoFocus(true)
    ib:SetFontObject("ChatFontNormal")
    ib:SetScript("OnEscapePressed", function() f:Hide() end)
    ibsf:SetScrollChild(ib)

    -- Output Box ScrollFrame
    local outputBoxScrollFrameName = outputBoxName .. "ScrollFrame"
    local obsf = CreateFrame("ScrollFrame", outputBoxScrollFrameName, f, "UIPanelScrollFrameTemplate")
    obsf:SetPoint("LEFT", ibsf, "RIGHT", 60, 0)
    obsf:SetPoint("RIGHT", f, "RIGHT", -200, 0)
    obsf:SetPoint("TOP", f, "TOP", 0, -30)
    obsf:SetPoint("BOTTOM", f, "BOTTOM", 0, 20)

    obsf:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      insets = { left = -10, right = -30, top = -10, bottom = -10 }
    })

    local outputBoxHintText = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
    outputBoxHintText:SetPoint("TOPLEFT", obsf, "TOPLEFT", -8, 25)
    outputBoxHintText:SetText("Raid Member DKP Output")

    -- Output Box
    local ob = CreateFrame("EditBox", outputBoxName, obsf)
    ob:SetSize(obsf:GetSize())
    ob:SetMultiLine(true)
    ob:SetAutoFocus(false)
    ob:SetFontObject("ChatFontNormal")
    ob:SetScript("OnEscapePressed", function() f:Hide() end)
    obsf:SetScrollChild(ob)

    -- DKP Type Edit Box
    local dteb = CreateFrame("EditBox", dkpTypeEditBoxName, f)
    dteb:SetMultiLine(false)
    dteb:SetAutoFocus(false)
    dteb:SetFontObject("ChatFontNormal")
    dteb:SetScript("OnEscapePressed", function() f:Hide() end)
    dteb:SetText("")
    dteb:SetSize(120, 20)
    dteb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -60)
    dteb:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      insets = { left = -10, right = -10, top = -10, bottom = -10 }
    })

    local dkpTypeHintText = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
    dkpTypeHintText:SetPoint("TOPLEFT", dteb, "TOPLEFT", -8, 25)
    dkpTypeHintText:SetText("DKP Type")

    -- Online Member Points Edit Box
    local onlinePointEb = CreateFrame("EditBox", onlineMemberPointEditBoxName, f)
    onlinePointEb:SetMultiLine(false)
    onlinePointEb:SetAutoFocus(false)
    onlinePointEb:SetFontObject("ChatFontNormal")
    onlinePointEb:SetScript("OnEscapePressed", function() f:Hide() end)
    onlinePointEb:SetText("1")
    onlinePointEb:SetSize(120, 20)
    onlinePointEb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -130)
    onlinePointEb:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      insets = { left = -10, right = -10, top = -10, bottom = -10 }
    })

    local onlinePointHintText = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
    onlinePointHintText:SetPoint("TOPLEFT", onlinePointEb, "TOPLEFT", -8, 25)
    onlinePointHintText:SetText("Online Member Points")

    -- Offline Member Points Edit Box
    local offlinePointEb = CreateFrame("EditBox", offlineMemberPointEditBoxName, f)
    offlinePointEb:SetMultiLine(false)
    offlinePointEb:SetAutoFocus(false)
    offlinePointEb:SetFontObject("ChatFontNormal")
    offlinePointEb:SetScript("OnEscapePressed", function() f:Hide() end)
    offlinePointEb:SetText("0")
    offlinePointEb:SetSize(120, 20)
    offlinePointEb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -200)
    offlinePointEb:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      insets = { left = -10, right = -10, top = -10, bottom = -10 }
    })

    local offlinePointHintText = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
    offlinePointHintText:SetPoint("TOPLEFT", offlinePointEb, "TOPLEFT", -8, 25)
    offlinePointHintText:SetText("Offline Member Points")

    -- DKP Generate Button
    local dkpGenerateHandler = function()
      local newRaidMemberNames, dkpStr = raidRoster.generateRaidDkpDetailsAfterAddOneDkpType(dteb:GetText(), ib:GetText(), onlinePointEb:GetText(), offlinePointEb:GetText())
      if newRaidMemberNames == "" then
        if dkpStr ~= "" then
          -- has some warnings
          local msgDialog = MessageDialog:new(
            raidDkpUiName .. "WarningMessageDialog",
            dkpStr
          )
          msgDialog:show()
        else
          dteb:SetText("")
          ob:SetText("")
        end
      else
        dteb:SetText("")
        ib:SetText(newRaidMemberNames)
        ob:SetText(dkpStr)
      end
    end
    local dkpGenerateConfirmDialog = ConfirmDialog:new(dkpGenerateConfirmDialogName, dkpGenerateHandler, { text = "Ready to generate the DKP?" })
    local onClickDkpGenerateButton = function()
      local warningMessage = ""
      if raidRoster.areRaidMemberNamesSameAsPersistentlySavedOnes(ib:GetText()) then
        warningMessage = warningMessage .. "Warning! Detected that the input raid member names are different than saved ones.\n\nIf it is an accidentally change, please ignore this warning, and click 'Yes' in the following confirm dialog to generate DKP by using saved raid member names.\n\nOtherwise, please click 'No' in the following confirm dialog, and 'Clear All DKP' first before try it again."
      end
      local trimmedNewDkpType = util.trimString(dteb:GetText())
      if not raidRoster.isNewDkpType(trimmedNewDkpType) then
        if warningMessage ~= "" then
          warningMessage = warningMessage .. "\n\n----------\n\n"
        end
        warningMessage = warningMessage .. "Warning! This DKP type has been added before.\n\nIf you would like to override this DKP type, please ignore this warning, and click 'Yes' in the following confirm dialog to move forward.\n\nOtherwise, please  click 'No' in the following confirm dialog."
      end
      if warningMessage ~= "" then
        local msgDialog = MessageDialog:new(
          raidDkpUiName .. "DkpGenerateWarningMessageDialog",
          warningMessage,
          function() dkpGenerateConfirmDialog:show() end
        )
        msgDialog:show()
      else
        dkpGenerateConfirmDialog:show()
      end
    end
    local dkpGenerateButton = Button:new(f, dkpGenerateButtonName, "Generate DKP", onClickDkpGenerateButton, { isVisible = true, width = 130 })
    dkpGenerateButton:setPoint("TOPRIGHT", f, "TOPRIGHT", -20, -260)

    -- Remove DKP Type Button
    local dkpTypeRemoveHandler = function()
      local newRaidMemberNames, dkpStr = raidRoster.generateRaidDkpDetailsAfterRemoveOneDkpType(dteb:GetText())
      if newRaidMemberNames == "" then
        -- has some warnings
        if dkpStr ~= "" then
          -- has some warnings
          local msgDialog = MessageDialog:new(
            raidDkpUiName .. "WarningMessageDialog",
            dkpStr
          )
          msgDialog:show()
        else
          dteb:SetText("")
          ob:SetText("")
        end
      else
        dteb:SetText("")
        ib:SetText(newRaidMemberNames)
        ob:SetText(dkpStr)
      end
    end
    local removeDkpTypeConfirmDialog = ConfirmDialog:new(removeDkpTypeConfirmDialogName, dkpTypeRemoveHandler, { text = "Are you sure to remove DKP for this DKP type?" })
    local onClickRemoveDkpTypeButton = function()
      if raidRoster.areRaidMemberNamesSameAsPersistentlySavedOnes(ib:GetText()) then
        local msgDialog = MessageDialog:new(
          raidDkpUiName .. "DkpTypeRemoveWarningMessageDialog",
          "Warning! Detected that the input raid member names are different than saved ones.\n\nIf it is an accidentally change, please ignore this warning, and click 'Yes' in the following confirm dialog to remove the DKP type by using saved raid member names.\n\nOtherwise, please click 'No' in the following confirm dialog, and 'Clear All DKP' first before try it again.",
          function() removeDkpTypeConfirmDialog:show() end
        )
        msgDialog:show()
      else
        removeDkpTypeConfirmDialog:show()
      end
    end
    local removeDkpTypeButton = Button:new(f, removeDkpTypeButtonName, "Remove DKP Type", onClickRemoveDkpTypeButton, { isVisible = true, width = 130 })
    removeDkpTypeButton:setPoint("TOPRIGHT", f, "TOPRIGHT", -20, -300)

    -- Clear All DKP Button
    local clearAllDkpHandler = function()
      raidRoster.clearAll()
      ob:SetText("")
    end
    local clearAllDkpConfirmDialog = ConfirmDialog:new(clearAllDkpConfirmDialogName, clearAllDkpHandler, { text = "Are you sure to clear all DKP data?" })
    local clearAllDkpButton = Button:new(f, clearAllDkpButtonName, "Clear All DKP", function() clearAllDkpConfirmDialog:show() end, { isVisible = true, width = 130 })
    clearAllDkpButton:setPoint("TOPRIGHT", f, "TOPRIGHT", -20, -340)

    -- Close Button
    local closeButton = Button:new(f, closeButtonName, "Close", function() f:Hide() end, { isVisible = true, width = 130 })
    closeButton:setPoint("TOPRIGHT", f, "TOPRIGHT", -20, -380)

    -- Resizable
    f:SetResizable(true)
    f:SetMinResize(800, 450)

    local resizeButtonName = newInstance.mainFrameName .. "ResizeButton"
    local rb = CreateFrame("Button", resizeButtonName, f)
    rb:SetPoint("BOTTOMRIGHT", -6, 7)
    rb:SetSize(16, 16)

    rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

    rb:SetScript("OnMouseDown", function(self, button)
      if button == "LeftButton" then
        f:StartSizing("BOTTOMRIGHT")
        self:GetHighlightTexture():Hide() -- more noticeable
      end
    end)
    rb:SetScript("OnMouseUp", function(self, button)
      f:StopMovingOrSizing()
      self:GetHighlightTexture():Show()
      ib:SetSize(ibsf:GetSize())
      ob:SetSize(obsf:GetSize())
    end)

    newInstance.mainFrame = f
    newInstance.inputBox = ib
    newInstance.outputBox = ob
    newInstance.dkpTypeEditBox = dteb
    newInstance.onlineMemberPointEditBox = onlinePointEb
    newInstance.offlineMemberPointEditBox = offlinePointEb

    self.instance = newInstance
  end

  return self.instance
end

function RaidDkpUi:isVisible()
  if self.mainFrame then
    return self.mainFrame:IsVisible()
  else
    return false
  end
end

function RaidDkpUi:show()
  if self.mainFrame then
    return self.mainFrame:Show()
  end
end

function RaidDkpUi:hide()
  if self.mainFrame then
    return self.mainFrame:Hide()
  end
end

function RaidDkpUi:loadAndDisplayPersistentlySavedData()
  local memberNameListStr, dkpStr = raidRoster.getMemberNameListStringAndDkpStringFromGlobalState()
  self:setInputBoxText(memberNameListStr)
  self:setOutputBoxText(dkpStr)
end

function RaidDkpUi:setInputBoxText(text)
  if self.inputBox then
    self.inputBox:SetText(text)
  end
end

function RaidDkpUi:getInputBoxText()
  if self.inputBox then
    return self.inputBox:GetText()
  else
    return ""
  end
end

function RaidDkpUi:setOutputBoxText(text)
  if self.outputBox then
    self.outputBox:SetText(text)
  end
end

function RaidDkpUi:getOutputBoxText()
  if self.outputBox then
    return self.outputBox:GetText()
  else
    return ""
  end
end

function RaidDkpUi:getDkpType()
  if self.dkpTypeEditBox then
    return self.dkpTypeEditBox:GetText()
  else
    return ""
  end
end

function RaidDkpUi:getOnlineMemberPoints()
  if self.onlineMemberPointEditBox then
    return self.onlineMemberPointEditBox:GetText()
  else
    return ""
  end
end

function RaidDkpUi:getOfflineMemberPoints()
  if self.offlineMemberPointEditBox then
    return self.offlineMemberPointEditBox:GetText()
  else
    return ""
  end
end

namespace.RaidDkpUi = RaidDkpUi
