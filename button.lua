local addonName, namespace = ...

local util = namespace.util

Button = {}

function Button:new(buttonParent, buttonName, buttonText, buttonOnClickHandler, buttonConfig)
  local newInstance = {}
  newInstance.parent = buttonParent
  newInstance.name = util.generateGlobalValidUiName(buttonName)
  newInstance.button = CreateFrame("Button", newInstance.name, newInstance.parent, "UIPanelButtonTemplate")

  self.__index = self
  newInstance = setmetatable(newInstance, self)

  local config = buttonConfig or {}
  newInstance:setText(buttonText)
  newInstance:setSize(config.width, config.height)
  newInstance:setPoint("CENTER")

  -- Movable
  newInstance:setMovable(config.isMovable)

  -- On Click
  newInstance:setOnClickHandler(buttonOnClickHandler)

  if config.isVisible then
    newInstance:show()
  else
    newInstance:hide()
  end

  return newInstance
end

function Button:setText(buttonText)
  if self.button then
    local text = buttonText or "Button"
    self.text = text
    self.button:SetText(buttonText)
  end
  self.text = ""
end

function Button:setOnClickHandler(buttonOnClickHandler)
  if self.button then
    local onClickHandler = buttonOnClickHandler or function() return nil end
    self.button:SetScript("OnClick", onClickHandler)
  end
end

function Button:setPoint(...)
  if self.button then
    self.button:SetPoint(...)
  end
end

function Button:setSize(buttonWidth, buttonHeight)
  if self.button then
    local width = buttonWidth or 100
    local height = buttonHeight or 30
    self.width = width
    self.height = height
    self.button:SetSize(width, height)
  end
  self.width = 0
  self.height = 0
end

function Button:setMovable(isMovable)
  if self.button then
    if isMovable then
      self.isMovable = true
      self.button:SetMovable(true)
      self.button:SetClampedToScreen(true)
      self.button:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
          self:StartMoving()
        end
      end)
      self.button:SetScript("OnMouseUp", self.button.StopMovingOrSizing)
    else
      self.isMovable = false
      self.button:SetMovable(false)
      self.button:SetClampedToScreen(true)
      self.button:SetScript("OnMouseDown", nil)
      self.button:SetScript("OnMouseUp", nil)
    end
  end
  self.isMovable = false
end

function Button:show()
  if self.button then
    self.button:Show()
    self.isVisible = true
  end
  self.isVisible = false
end

function Button:hide()
  if self.button then
    self.button:Hide()
  end
  self.isVisible = false
end

namespace.Button = Button