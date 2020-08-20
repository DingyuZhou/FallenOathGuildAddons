local addonName, namespace = ...

local util = namespace.util

local EditBox = {}

-- TODO: need better refactoring
function EditBox:new(editBoxName, editBoxConfig)
  local newInstance = {}

  newInstance.name = util.generateGlobalValidUiName(editBoxName)
  local mainFrameName = newInstance.name .. "EditBoxMainFrame"
  local newEditBoxName = newInstance.name .. 'EditBox'

  local config = editBoxConfig or {}

  local f = CreateFrame("Frame", mainFrameName, UIParent)
  mainFrame = f

  f:SetPoint("CENTER")

  local width = config.width or 300
  local height = config.height or 500
  f:SetSize(width, height)

  f:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
    edgeSize = 16,
    insets = { left = 6, right = 6, top = 8, bottom = 8 },
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
  sf:SetPoint("LEFT", f, "LEFT", 16, 0)
  sf:SetPoint("RIGHT", f, "RIGHT", -32, 0)
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
  eb:SetScript("OnEscapePressed", function() f:Hide() end)
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

  if config.text then
    eb:SetText(config.text)
  end

  if config.isVisible then
    f:Show()
  else
    f:Hide()
  end

  newInstance.mainFrame = f
  newInstance.editBox = eb

  -- Class syntax
  self.__index = self
  newInstance = setmetatable(newInstance, self)

  return newInstance
end

function EditBox:isVisible()
  if self.mainFrame then
    return self.mainFrame:IsVisible()
  else
    return false
  end
end

function EditBox:show()
  if self.mainFrame then
    return self.mainFrame:Show()
  end
end

function EditBox:hide()
  if self.mainFrame then
    return self.mainFrame:Hide()
  end
end

function EditBox:setPoint(...)
  if self.mainFrame then
    self.mainFrame:SetPoint(...)
  end
end

function EditBox:setText(text)
  if self.editBox then
    self.editBox:SetText(text)
  end
end

function EditBox:getText()
  if self.editBox then
    return self.editBox:GetText()
  else
    return ""
  end
end

namespace.EditBox = EditBox
