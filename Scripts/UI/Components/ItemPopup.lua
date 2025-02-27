local Mask = require("UI/Components/Mask")
local PunkPanel = require("UI/Components/PunkPanel")

local Client_GetItem = Client.GetItem

local ItemPopup = {}

--- 아이템 정보 팝업을 생성합니다.
--- 사용 예시:
--- ```lua
--- local itemPopup = ItemPopup:new(titem)
--- itemPopup:SetButtonA("출력", function ()
---     print(titem)
---     itemPopup:Close()
--- end)
---```
function ItemPopup:new(titem, position)
    local instance = {}
    local maskControl = Mask:new()

    position = position or Input.mousePosition
    position.x = position.x - Client.width

    local punkPanel = PunkPanel:new(Rect(position.x, position.y, 240, 132))
    punkPanel.backgroundPanel.anchor = Anchor.TopRight
    punkPanel.backgroundPanel.pivot = Point(1, 0)
    punkPanel.topPanel.sizeDelta = Point(punkPanel.topPanel.width, 55)
    punkPanel.closeButton.visible = false

    local gameItem = Client_GetItem(titem.dataID)

    local topWrapper = Panel(Rect(0, 0, 216, punkPanel.topPanel.height)) {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),
        opacity = 0,
    }

    local iconImage = Image("", Rect(0, 0, 38, 38)) {
        anchor = Anchor.MiddleLeft,
        pivot = Point(0, 0.5),
    }
    iconImage.SetImageID(gameItem.imageID)

    local infoWrapper = Panel(Rect(0, 0, topWrapper.width - iconImage.width, topWrapper.height)) {
        anchor = Anchor.MiddleRight,
        pivot = Point(1, 0.5),
        opacity = 0,
    }

    local nameText = Text(gameItem.name, Rect(0, 9, 0, 0)) {
        anchor = Anchor.TopCenter,
        pivot = Point(0.5, 0),
        textSize = 14,
    }
    nameText.SetSizeFit(true, true)

    local function formatAvailability(flag, text)
        return flag and string.format("<color=#00FFFF>%s</color>", text) or
            string.format("<color=#808080>%s</color>", text)
    end

    local canText = Text(
        string.format("%s     %s     %s     %s",
            formatAvailability(gameItem.canTrade, "거래"),
            formatAvailability(gameItem.canDrop, "드랍"),
            formatAvailability(gameItem.canStorage, "창고"),
            formatAvailability(gameItem.canSell, "판매")
        ),
        Rect(0, -8, 0, 0)
    ) {
        anchor = Anchor.BottomCenter,
        pivot = Point(0.5, 1),
        textSize = 12,
    }
    canText.SetSizeFit(true, true)

    local descText = Text(gameItem.desc, Rect(0, 10, 216, 0)) {
        anchor = Anchor.TopCenter,
        pivot = Point(0.5, 0),
        textSize = 13,
    }

    if titem.options and #titem.options > 0 then
        descText.text = descText.text .. "\n\n" .. LUtility.OptionsToText(titem.options)
    end

    descText.SetSizeFit(false, true)
    descText.ForceRebuildLayoutImmediate()

    punkPanel.centerPanel.sizeDelta = Point(punkPanel.centerPanel.width,
        punkPanel.centerPanel.height + descText.height - 12)
    punkPanel.backgroundPanel.sizeDelta = Point(punkPanel.backgroundPanel.width,
        punkPanel.backgroundPanel.height + descText.height)

    local function createButton(text, rect, anchor, pivot)
        local button = Button(text, rect) {
            anchor = anchor,
            pivot = pivot,
            textSize = 13,
        }
        button.SetImage("Pictures/New_PunkGUI/0_button3.png")
        return button
    end

    local buttonA = createButton("", Rect(-2, -10, 106, 35), Anchor.BottomCenter, Point(1, 1)) { visible = false }
    local buttonB = createButton("", Rect(2, -10, 106, 35), Anchor.BottomCenter, Point(0, 1)) { visible = false }

    topWrapper.AddChild(iconImage)
    topWrapper.AddChild(infoWrapper)
    infoWrapper.AddChild(nameText)
    infoWrapper.AddChild(canText)
    punkPanel.topPanel.AddChild(topWrapper)

    punkPanel.centerPanel.AddChild(descText)
    punkPanel.centerPanel.AddChild(buttonA)
    punkPanel.centerPanel.AddChild(buttonB)

    instance.control = punkPanel
    instance.buttonA = buttonA
    instance.buttonB = buttonB

    maskControl:GetControl().AddChild(punkPanel.backgroundPanel)
    punkPanel:Build()

    self.__index = self
    return setmetatable(instance, self)
end

function ItemPopup:GetControl()
    return self.control:GetControl()
end

function ItemPopup:SetButtonA(text, callback)
    self.buttonA.text = text
    self.buttonA.onClick.Add(callback)
    self.buttonA.visible = true
end

function ItemPopup:SetButtonB(text, callback)
    self.buttonB.text = text
    self.buttonB.onClick.Add(callback)
    self.buttonB.visible = true
end

function ItemPopup:Close()
    self.control:GetControl().Destroy()
end

return ItemPopup
