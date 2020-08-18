local addonName, namespace = ...

local button = namespace.button
local confirmDialog = namespace.confirmDialog
local raidRoster = namespace.raidRoster

local raidDkpUi = {}

function raidDkpUi.create(dkpTypeRemoveHandler)
  local raidDkpUiName = "RaidDkpUi"
  local mainFrameName = raidDkpUiName .. "MainFrame"
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
  local mainFrame = _G[mainFrameName]

  if mainFrame then
    mainFrame:Hide()
  else
    local f = CreateFrame("Frame", mainFrameName, UIParent)
    mainFrame = f
    mainFrame:Hide()

    f:SetPoint("CENTER")
    f:SetSize(1200, 700)
    
    -- f:SetBackdrop({
    --   bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    --   edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
    --   edgeSize = 16,
    --   insets = { left = 8, right = 6, top = 8, bottom = 8 },
    -- })
    
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
    local dneb = CreateFrame("EditBox", dkpTypeEditBoxName, f)
    dneb:SetMultiLine(false)
    dneb:SetAutoFocus(false)
    dneb:SetFontObject("ChatFontNormal")
    dneb:SetScript("OnEscapePressed", function() f:Hide() end)
    dneb:SetText("集合分")
    dneb:SetSize(120, 20)
    dneb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -60)
    dneb:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      insets = { left = -10, right = -10, top = -10, bottom = -10 }
    })

    local dkpTypeHintText = f:CreateFontString(f, "OVERLAY", "GameTooltipText")
    dkpTypeHintText:SetPoint("TOPLEFT", dneb, "TOPLEFT", -8, 25)
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
      local newMemberNames, dkpStr = raidRoster.generateRaidDkp(dneb:GetText(), ib:GetText(), onlinePointEb:GetText(), offlinePointEb:GetText())
      ib:SetText(newMemberNames)
      ob:SetText(dkpStr)
    end
    local dkpGenerateConfirmDialog = confirmDialog.create(dkpGenerateConfirmDialogName, dkpGenerateHandler, { text = "Ready to generate the DKP?" })
    local dkpGenerateButton = button.create(f, dkpGenerateButtonName, "Generate DKP", dkpGenerateConfirmDialog.show or (function() return nil end), { isVisible = true, width = 130 })
    dkpGenerateButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -260)

    -- Remove DKP Type Button
    local dkpTypeRemoveHandler = function()
      local newMemberNames, dkpStr = raidRoster.removeRaidDkpType(dneb:GetText())
      if newMemberNames ~= '' then
        ib:SetText(newMemberNames)
      end
      ob:SetText(dkpStr)
    end
    local removeDkpTypeConfirmDialog = confirmDialog.create(removeDkpTypeConfirmDialogName, dkpTypeRemoveHandler, { text = "Are you sure to remove DKP for this DKP type?" })
    local removeDkpTypeButton = button.create(f, removeDkpTypeButtonName, "Remove DKP Type", removeDkpTypeConfirmDialog.show or (function() return nil end), { isVisible = true, width = 130 })
    removeDkpTypeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -300)

    -- Clear All DKP Button
    local clearAllDkpHandler = function()
      raidRoster.resetAll()
      ob:SetText("")
    end
    local clearAllDkpConfirmDialog = confirmDialog.create(clearAllDkpConfirmDialogName, clearAllDkpHandler, { text = "Are you sure to clear all DKP data?" })
    local clearAllDkpButton = button.create(f, clearAllDkpButtonName, "Clear All DKP", clearAllDkpConfirmDialog.show or (function() return nil end), { isVisible = true, width = 130 })
    clearAllDkpButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -340)

    -- Close Button
    local closeButton = button.create(f, closeButtonName, "Close", function() f:Hide() end, { isVisible = true, width = 130 })
    closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -380)
    
    -- Resizable
    f:SetResizable(true)
    f:SetMinResize(800, 400)
    
    local resizeButtonName = mainFrameName .. "ResizeButton"
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
  end

  -- Interfaces
  local inputBox = _G[inputBoxName]
  local outputBox = _G[outputBoxName]
  local dkpTypeEditBox = _G[dkpTypeEditBoxName]
  local onlineMemberPointEditBox = _G[onlineMemberPointEditBoxName]
  local offlineMemberPointEditBox = _G[offlineMemberPointEditBoxName]

  function mainFrame:setInputBoxText(text)
    inputBox:SetText(text)
  end

  function mainFrame:getInputBoxText()
    return inputBox:GetText()
  end

  function mainFrame:setOutputBoxText(text)
    outputBox:SetText(text)
  end

  function mainFrame:getOutputBoxText()
    return outputBox:GetText()
  end

  function mainFrame:getDkpType()
    return dkpTypeEditBox:GetText()
  end

  function mainFrame:getOnlineMemberPoints()
    return onlineMemberPointEditBox:GetText()
  end

  function mainFrame:getOfflineMemberPoints()
    return offlineMemberPointEditBox:GetText()
  end

  return mainFrame
end

namespace.raidDkpUi = raidDkpUi
