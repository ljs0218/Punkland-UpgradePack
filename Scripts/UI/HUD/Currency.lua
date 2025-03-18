local UI_SETTINGS = LClient.Config.UI.HUD.Currency

local wrapper = HorizontalPanel()
wrapper.anchor = Anchor.TopCenter
wrapper.pivot = Point(0.5, 0)
wrapper.position = Point(0, 10)
wrapper.spacing = 6

local currencyControls = {}

for _, currencyId in pairs(UI_SETTINGS.ids) do
    local currencyPanel = HorizontalPanel()
    currencyPanel.spacing = 3
    currencyPanel.childAlign = 3

    local currencyIcon = Image(Currency.GetPath(currencyId), Rect(0, 0, 22, 22))
    currencyIcon.anchor = Anchor.MiddleLeft
    currencyIcon.pivot = Point(0, 0.5)
    currencyIcon.raycastTarget = false
    
    local currencyText = Text("1,000")
    currencyText.textAlign = TextAlign.MiddleLeft
    currencyText.textSize = 14
    currencyText.borderEnabled = true
    currencyText.borderDistance = Point(0.7, 0.7)
    currencyText.borderColor = Color.black
    currencyText.SetSizeFit(true, true)
    currencyText.raycastTarget = false

    currencyPanel.AddChild(currencyIcon)
    currencyPanel.AddChild(currencyText)
    currencyPanel.SetSizeFit(true, true)

    wrapper.AddChild(currencyPanel)

    currencyControls[tostring(currencyId)] = {
        panelControl = currencyPanel,
        textControl = currencyText
    }
end

wrapper.SetSizeFit(true, true)

LClient.Events.onEverySecond:Add(function()
    for currencyId, currencyControl in pairs(currencyControls) do
        currencyControl.textControl.text = LUtility.FormatNumber(Currency.GetAmount(tonumber(currencyId)))
        currencyControl.textControl.SetSizeFit(true, true)
        currencyControl.panelControl.SetSizeFit(true, true)
        currencyControl.panelControl.ForceRebuildLayoutImmediate()
    end
    wrapper.SetSizeFit(true, true)
    wrapper.ForceRebuildLayoutImmediate()
end)

LClient.Events.onShowUI:Add(function()
    wrapper.visible = true
end)

LClient.Events.onHideUI:Add(function()
    wrapper.visible = false
end)
