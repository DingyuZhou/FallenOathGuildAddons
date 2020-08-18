local addonName, namespace = ...

button = {}

function button.create(buttonParent, buttonName, buttonText, buttonOnClick, buttonWidth, buttonHeight)
  local newButtonName = buttonName .. 'Button'
  local newButton = _G[newButtonName]

  if not newButton then
    local b = CreateFrame("Button", newButtonName, buttonParent, "UIPanelButtonTemplate")
    newButton = b
    b:Hide()

    b:SetText(buttonText)

    b:SetPoint("CENTER")

    local width = buttonWidth or 100
    local height = buttonHeight or 30
    b:SetSize(width, height)
    
    -- Movable
    b:SetMovable(true)
    b:SetClampedToScreen(true)
    b:SetScript("OnMouseDown", function(self, button)
      if button == "LeftButton" then
        self:StartMoving()
      end
    end)
    b:SetScript("OnMouseUp", b.StopMovingOrSizing)

    -- On Click
    local onClickFn = buttonOnClick or function() return nil end
    b:SetScript("OnClick", onClickFn)
  end
  
  return newButton
end

namespace.button = button