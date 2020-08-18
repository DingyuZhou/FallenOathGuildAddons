local addonName, namespace = ...

local editBox = {}

function editBox.create(name, autoFocus, text)
  local mainFrameName = name .. "EditBoxFrame"
  local editBoxName = name .. 'EditBox'
  local mainFrame = _G[mainFrameName]

  if not mainFrame then
    local f = CreateFrame("Frame", mainFrameName, UIParent)
    mainFrame = f

    f:SetPoint("CENTER")
    f:SetSize(600, 500)
    
    f:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
      edgeSize = 16,
      insets = { left = 8, right = 6, top = 8, bottom = 8 },
    })
    f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue
    
    -- Movable
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetScript("OnMouseDown", function(self, button)
      if button == "LeftButton" then
        self:StartMoving()
      end
    end)
    f:SetScript("OnMouseUp", f.StopMovingOrSizing)
    
    -- ScrollFrame
    local scrollFrameName = editBoxName .. "ScrollFrame"
    local sf = CreateFrame("ScrollFrame", scrollFrameName, f, "UIPanelScrollFrameTemplate")
    sf:SetPoint("LEFT", 16, 0)
    sf:SetPoint("RIGHT", -32, 0)
    sf:SetPoint("TOP", f, "TOP", 0, -20)
    sf:SetPoint("BOTTOM", f, "BOTTOM", 0, 20)
    
    -- EditBox
    local eb = CreateFrame("EditBox", editBoxName, sf)
    eb:SetSize(sf:GetSize())
    eb:SetMultiLine(true)
    eb:SetAutoFocus(autoFocus)
    eb:SetFontObject("ChatFontNormal")
    eb:SetScript("OnEscapePressed", function() f:Hide() end)
    sf:SetScrollChild(eb)
    
    -- Resizable
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
    f:Show()
  end
  
  if text then
    local editBox = _G[editBoxName]
    print(editBox)
    editBox:SetText(text)
  end

  mainFrame:Show()
end

namespace.editBox = editBox
