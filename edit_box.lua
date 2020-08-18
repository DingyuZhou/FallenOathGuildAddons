local addonName, namespace = ...

local editBox = {}

function editBox.create(editBoxParent, editBoxName, editBoxConfig)
  local mainFrameName = editBoxName .. "EditBoxFrame"
  local newEditBoxName = editBoxName .. 'EditBox'
  local mainFrame = _G[mainFrameName]
  local config = editBoxConfig or {}

  if not mainFrame then
    local f = CreateFrame("Frame", mainFrameName, editBoxParent)
    mainFrame = f

    if config.isAtCenter then f:SetPoint("CENTER") end

    local width = config.width or 300
    local height = config.height or 500
    f:SetSize(width, height)
    
    f:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
      edgeSize = 16,
      insets = { left = 8, right = 6, top = 8, bottom = 8 },
    })
    f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
    
    -- Movable
    if config.isMovable then
      f:SetMovable(true)
      f:SetClampedToScreen(true)
      f:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
          self:StartMoving()
        end
      end)
      f:SetScript("OnMouseUp", f.StopMovingOrSizing)
    end
    
    -- ScrollFrame
    local scrollFrameName = newEditBoxName .. "ScrollFrame"
    local sf = CreateFrame("ScrollFrame", scrollFrameName, f, "UIPanelScrollFrameTemplate")
    sf:SetPoint("LEFT", 16, 0)
    sf:SetPoint("RIGHT", -32, 0)
    sf:SetPoint("TOP", f, "TOP", 0, -20)
    sf:SetPoint("BOTTOM", f, "BOTTOM", 0, 20)
    
    -- EditBox
    local eb = CreateFrame("EditBox", newEditBoxName, sf)
    eb:SetSize(sf:GetSize())
    eb:SetMultiLine(true)
    if config.isAutoFocus then
      eb:SetAutoFocus(config.isAutoFocus)
    end
    eb:SetFontObject("ChatFontNormal")
    -- eb:SetScript("OnEscapePressed", function() f:Hide() end)
    sf:SetScrollChild(eb)
    
    -- Resizable
    if config.isResizable then
      f:SetResizable(true)
      f:SetMinResize(150, 100)
      
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
        eb:SetWidth(sf:GetWidth())
      end)
    end
  end
  
  local newEditBox = _G[newEditBoxName]
  if config.text then
    newEditBox:SetText(config.text)
  end

  if config.isVisible then
    mainFrame:Show()
  else
    mainFrame:Hide()
  end

  function mainFrame:SetText(text)
    newEditBox:SetText(text)
  end

  function mainFrame:GetText(text)
    return newEditBox:GetText(text)
  end

  return mainFrame, newEditBox
end

namespace.editBox = editBox
