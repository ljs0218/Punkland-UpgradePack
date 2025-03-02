local Mask = require("UI/Components/Mask")
local Popup = require("UI/Components/Popup")
local PunkPanel = require("UI/Components/PunkPanel")

local Client_GetItem = Client.GetItem

local ShopUI = ShopUI

function ShopUI.Buy(productId)
    local product = Shop.GetProduct(productId)
    local gameItem = Client_GetItem(product.dataID)
    local currency = Currency.Get(product.currencyId)

    local count = 1

    local punkPanel = PunkPanel:new(Rect(0, 0, 306, 260))
    local shopPopup = Popup:new(punkPanel.backgroundPanel, "ShopBuy")
    local maskControl = Mask:new(shopPopup, false)
    local titleText = Text("아이템 개수 입력") {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),
        textSize = 14,
    }
    titleText.SetSizeFit(true, true)

    punkPanel.topPanel.height = 45
    punkPanel.topPanel.AddChild(titleText)
    punkPanel.backgroundPanel.anchor = Anchor.MiddleCenter
    punkPanel.backgroundPanel.pivot = Point(0.5, 0.5)

    shopPopup.onClose:Add(function()
        maskControl:Close()
    end)

    punkPanel.closeButton.onClick.Add(function()
        shopPopup:Close()
    end)

    punkPanel.centerPanel.width = punkPanel.centerPanel.width - 30
    punkPanel.centerPanel.height = punkPanel.centerPanel.height - 30
    punkPanel.centerPanel.position = Point(punkPanel.centerPanel.position.x, punkPanel.centerPanel.position.y - 15)

    local itemPanel = Panel(Rect(0, -3, punkPanel.centerPanel.width, 60)) { opacity = 0 }
    local iconImage = Image("", Rect(0, 0, 60, 60)) {
        anchor = Anchor.MiddleLeft,
        pivot = Point(0, 0.5),
    }
    iconImage.SetImageID(gameItem.imageID)
    local nameText = Text(gameItem.name) {
        anchor = Anchor.MiddleLeft,
        pivot = Point(0, 1.5),
        position = Point(74, -3),
        textSize = 15,
    }
    nameText.SetSizeFit(true, true)
    local countText = Text("") {
        anchor = Anchor.BottomRight,
        pivot = Point(1, 1),
        textSize = 16,
        borderEnabled = true,
        borderColor = Color.black,
    }
    countText.SetSizeFit(true, true)
    iconImage.AddChild(countText)
    local priceIText = Text("개당 가격") {
        anchor = Anchor.MiddleLeft,
        pivot = Point(0, 0.5),
        position = Point(74, 0),
        textSize = 13,
    }
    priceIText.SetSizeFit(true, true)
    local priceText = Text("<color=#D7A504>500 골드</color>") {
        anchor = Anchor.MiddleRight,
        pivot = Point(1, 0.5),
        position = Point(0, 0),
        textSize = 13,
    }
    priceText.SetSizeFit(true, true)

    local totalPriceIText = Text("총 가격") {
        anchor = Anchor.MiddleLeft,
        pivot = Point(0, -0.5),
        position = Point(74, 2),
        textSize = 13,
    }
    totalPriceIText.SetSizeFit(true, true)
    local totalPriceText = Text("<color=#D7A504>500 골드</color>") {
        anchor = Anchor.MiddleRight,
        pivot = Point(1, -0.5),
        position = Point(0, 2),
        textSize = 13,
    }
    totalPriceText.SetSizeFit(true, true)

    priceText.text = string.format(
        "<color=%s>%s %s</color>",
        currency.color,
        LUtility.FormatNumber(product.price),
        currency.name
    )
    totalPriceText.text = ""

    itemPanel.AddChild(iconImage)
    itemPanel.AddChild(nameText)
    itemPanel.AddChild(priceIText)
    itemPanel.AddChild(priceText)
    itemPanel.AddChild(totalPriceIText)
    itemPanel.AddChild(totalPriceText)

    local countField = InputField(Rect(0, -86, punkPanel.centerPanel.width, 35)) {
        anchor = Anchor.BottomCenter,
        pivot = Point(0.5, 1),
    }

    local function getMaxCount()
        return math.floor(Currency.GetAmount(product.currencyId) / product.price)
    end

    local function refreshCount(newCount)
        if newCount == nil or newCount == "" then
            return
        end

        if newCount == 0 then
            newCount = 1
        end

        local maxCount = getMaxCount()
        if newCount > maxCount then
            newCount = maxCount
        end

        count = newCount
        
        totalPriceText.text = string.format(
            "<color=%s>%s %s</color>",
            currency.color,
            LUtility.FormatNumber(count * product.price),
            currency.name
        )
        countField.text = count
        if count > 1 then
            countText.text = count
        else
            countText.text = ""
        end
    end
    refreshCount(1)

    countField.placeholder = "아이템 개수를 입력하세요"
    countField.placeholderControl.fontStyle = 0
    countField.placeholderControl.textAlign = TextAlign.MiddleCenter
    countField.textAlign = TextAlign.MiddleCenter
    countField.contentType = 1
    countField.characterLimit = 4
    countField.color = Color.white
    countField.imagePath = "Pictures/New_PunkGUI/0_slot_new.png"
    countField.onValueChanged.Add(function()
        refreshCount(tonumber(countField.text))
    end)

    local minusButton = Button("-", Rect(5, 0, 25, 25)) {
        anchor = Anchor.MiddleLeft,
        pivot = Point(0, 0.5),
        textSize = 17,
    }
    minusButton.SetImage("Pictures/New_PunkGUI/0_panel.png")
    minusButton.onClick.Add(function ()
        countField.text = count - 1
    end)
    local plusButton = Button("+", Rect(-5, 0, 25, 25)) {
        anchor = Anchor.MiddleRight,
        pivot = Point(1, 0.5),
        textSize = 17,
    }
    plusButton.SetImage("Pictures/New_PunkGUI/0_panel.png")
    plusButton.onClick.Add(function ()
        countField.text = count + 1
    end)

    countField.AddChild(minusButton)
    countField.AddChild(plusButton)

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

    plus10Button.onClick.Add(function ()
        countField.text = count + 10
    end)

    plus100Button.onClick.Add(function ()
        countField.text = count + 100
    end)

    maxButton.onClick.Add(function ()
        countField.text = getMaxCount()
    end)

    local confirmButton = CreateButton("확인", Anchor.BottomLeft, Point(0, 1), Point(132, 35), 13)
    local cancelButton = CreateButton("취소", Anchor.BottomRight, Point(1, 1), Point(132, 35), 13)

    confirmButton.onClick.Add(function ()
        Shop.Buy(productId, count)
    end)

    cancelButton.onClick.Add(function()
        shopPopup:Close()
    end)

    punkPanel.centerPanel.AddChild(itemPanel)
    punkPanel.centerPanel.AddChild(countField)
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

LClient.Events.onMyPlayerUnitCreated:Add(function()
    ShopUI.Buy(1)
end)
