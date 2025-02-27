local Mask = require("UI/Components/Mask")
local Popup = require("UI/Components/Popup")
local PunkPanel = require("UI/Components/PunkPanel")

local ShopUI = ShopUI

function ShopUI.Buy(productId)
    local punkPanel = PunkPanel:new(Rect(0, 0, 306, 260))
    local shopPopup = Popup:new(punkPanel.backgroundPanel, "ShopBuy")
    local maskControl = Mask:new(shopPopup, false)
    local titleText = Text("아이템 개수 입력") {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),
        textSize = 14,
    }
    titleText.SetSizeFit(true, true)

    punkPanel.topPanel.AddChild(titleText)
    punkPanel.backgroundPanel.anchor = Anchor.MiddleCenter
    punkPanel.backgroundPanel.pivot = Point(0.5, 0.5)

    shopPopup.onClose:Add(function()
        maskControl:Close()
    end)

    punkPanel.closeButton.onClick.Add(function()
        shopPopup:Close()
    end)

    punkPanel.centerPanel.color = Color.blue
    punkPanel.centerPanel.opacity = 50

    punkPanel.centerPanel.width = punkPanel.centerPanel.width - 30
    punkPanel.centerPanel.height = punkPanel.centerPanel.height - 30
    punkPanel.centerPanel.position = Point(punkPanel.centerPanel.position.x, punkPanel.centerPanel.position.y - 15)

    local function CreateButton(text, anchor, pivot, sizeDelta, textSize)
        local button = Button(text) {
            anchor = anchor,
            pivot = pivot,
            sizeDelta = sizeDelta,
            textSize = textSize,
        }
        button.SetImage("Pictures/New_PunkGUI/0_button3.png")
        return button
    end

    local plus10Button = CreateButton("+10", Anchor.BottomLeft, Point(0, 1), Point(88, 30), 13)
    local plus100Button = CreateButton("+100", Anchor.BottomCenter, Point(0.5, 1), Point(88, 30), 13)
    local maxButton = CreateButton("MAX", Anchor.BottomRight, Point(1, 1), Point(88, 30), 13)
    plus10Button.position = Point(plus10Button.x, -45)
    plus100Button.position = Point(plus100Button.x, -45)
    maxButton.position = Point(maxButton.x, -45)

    local confirmButton = CreateButton("확인", Anchor.BottomLeft, Point(0, 1), Point(132, 35), 13)
    local cancelButton = CreateButton("취소", Anchor.BottomRight, Point(1, 1), Point(132, 35), 13)

    cancelButton.onClick.Add(function ()
        shopPopup:Close()
    end)

    punkPanel.centerPanel.AddChild(plus10Button)
    punkPanel.centerPanel.AddChild(plus100Button)
    punkPanel.centerPanel.AddChild(maxButton)
    punkPanel.centerPanel.AddChild(confirmButton)
    punkPanel.centerPanel.AddChild(cancelButton)

    maskControl:SetOpacity(150)
    maskControl:GetControl().AddChild(punkPanel.backgroundPanel)

    shopPopup:Build()
    punkPanel:Build()
end

LClient.Events.onMyPlayerUnitCreated:Add(function ()
    ShopUI.Buy(1)
end)