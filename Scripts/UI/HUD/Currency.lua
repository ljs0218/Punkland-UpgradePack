local UI_SETTINGS = LClient.Config.UI.HUD.Currency

local wrapper = HorizontalPanel()
wrapper.anchor = Anchor.TopCenter
wrapper.pivot = Point(0.5, 0)
wrapper.position = Point(0, 4)
wrapper.spacing = 4

for _, currencyId in pairs(UI_SETTINGS.ids) do
    local currencyPanel = HorizontalPanel()
    currencyPanel.spacing = 4
    currencyPanel.childAlign = 3
    local currencyIcon = Image(Currency.GetPath(currencyId), Rect(0, 0, 22, 22))
    currencyIcon.anchor = Anchor.MiddleLeft
    currencyIcon.pivot = Point(0, 0.5)
    local currencyText = Text("1,000")
    currencyText.textAlign = TextAlign.MiddleLeft
    currencyText.textSize = 14
    currencyText.borderEnabled = true
    currencyText.borderColor = Color.black
    currencyText.SetSizeFit(true, true)

    currencyPanel.AddChild(currencyIcon)
    currencyPanel.AddChild(currencyText)
    currencyPanel.SetSizeFit(true, true)
    
    wrapper.AddChild(currencyPanel)
end

wrapper.SetSizeFit(true, true)

LClient.Events.onEverySecond:Add(function ()
    
end)

--[[
gameMoney = unit.gameMoney,
        varDatas = varDatas,
]]
