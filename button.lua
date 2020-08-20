local addonName, namespace = ...

button = {}

function button:create(buttonParent, buttonName, buttonText, buttonOnClickHandler, buttonConfig)
  local newButtonName = buttonName .. 'Button'
  local newButton = _G[newButtonName]
  local config = buttonConfig or {}

  if not newButton then
    local b = CreateFrame("Button", newButtonName, buttonParent, "UIPanelButtonTemplate")
    newButton = b

    b:SetText(buttonText)

    b:SetPoint("CENTER")

    local width = config.width or 100
    local height = config.height or 30
    b:SetSize(width, height)

    -- Movable
    if config.isMovable then
      b:SetMovable(true)
      b:SetClampedToScreen(true)
      b:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
          self:StartMoving()
        end
      end)
      b:SetScript("OnMouseUp", b.StopMovingOrSizing)
    end

    -- On Click
    local onClickFn = buttonOnClickHandler or function() return nil end
    b:SetScript("OnClick", onClickFn)
  end

  if config.isVisible then
    newButton:Show()
  else
    newButton:Hide()
  end

  return newButton
end

namespace.button = button