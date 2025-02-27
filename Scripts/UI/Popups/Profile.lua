local Popup = require("UI/Components/Popup")
local DragArea = require("UI/Components/DragArea")
local ItemSlot = require("UI/Components/ItemSlot")
local ItemPopup = require("UI/Components/ItemPopup")
local PunkPanel = require("UI/Components/PunkPanel")

local UI_SETTINGS = LClient.Config.UI.CustomEquip
local CustomEquip = LClient.CustomEquip

local json_parse = json.parse

Profile = {
    slotControls = {}
}

function Profile:Open()
    self.slotControls = {} -- 장비 슬롯 컨트롤을 저장할 테이블

    local punkPanel = PunkPanel:new(Rect(-300, 50, UI_SETTINGS.size.x, UI_SETTINGS.size.y))
    local profilePopup = Popup:new(punkPanel.backgroundPanel)
    local titleText = Text(UI_SETTINGS.title) {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),
        textSize = 14,
    }
    titleText.SetSizeFit(true, true)

    punkPanel.topPanel.AddChild(titleText)
    punkPanel.backgroundPanel.anchor = Anchor.TopRight
    punkPanel.backgroundPanel.pivot = Point(1, 0)
    punkPanel.closeButton.visible = false

    for equipType, slotPosition in pairs(UI_SETTINGS.slotPosition) do
        local slotControl = ItemSlot:new(Rect(slotPosition.x, slotPosition.y, 45, 45))
        local slotButton = slotControl:GetControl()
        slotButton.anchor = Anchor.MiddleCenter
        slotButton.pivot = Point(0.5, 0.5)

        local equippedItem = CustomEquip.GetEquipItem(equipType)
        if equippedItem then
            slotControl:SetItem(equippedItem)
            slotControl:SetEquipped(true)
        end

        slotButton.onClick.Add(function ()
            local itemPopup = ItemPopup:new(CustomEquip.GetEquipItem(equipType))
            itemPopup:SetButtonA("해제", function ()
                CustomEquip.UnequipItem(equipType)
                itemPopup:Close()
            end)
        end)

        punkPanel.centerPanel.AddChild(slotButton)

        self.slotControls[equipType] = slotControl
    end

    profilePopup:Build()
    punkPanel:Build()
end

function Profile:GetSlotControl(equipType)
    return self.slotControls[equipType]
end

Client.GetTopic("CustomEquip.EquipItem").Add(function (equipType, titem)
    local isSuccess, titem = pcall(json_parse, titem)

    if not isSuccess then
        error("Failed to parse item data")
        return
    end

    CustomEquip.Set(equipType, titem)

    local slotControl = Profile:GetSlotControl(equipType)
    if slotControl then
        slotControl:SetItem(titem)
        slotControl:SetEquipped(true)
    end
end)

Client.GetTopic("CustomEquip.UnequipItem").Add(function (equipType)
    CustomEquip.Set(equipType, nil)
    
    local slotControl = Profile:GetSlotControl(equipType)
    if slotControl then
        slotControl:SetItem(nil)
        slotControl:SetEquipped(false)
    end
end)

LClient.Events.onKeyDown:Add(function (key)
    if key == "p" then
        ScreenUI.ShowPopup("Bag")
        Profile:Open()
    end
end)

LClient.Events.onMyPlayerUnitCreated:Add(function ()
    ChatUI.visible = true
end)