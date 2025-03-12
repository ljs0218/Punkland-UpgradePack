local Popup = require("UI/Components/Popup")
local DragArea = require("UI/Components/DragArea")
local ItemSlot = require("UI/Components/ItemSlot")
local ItemPopup = require("UI/Components/ItemPopup")
local PunkPanel = require("UI/Components/PunkPanel")

local UI_SETTINGS = LClient.Config.UI.CustomEquip
local CustomEquip = LClient.CustomEquip

local json_parse = json.parse

CustomEquipUI = {
    popup = nil,
    slotControls = {}
}

function CustomEquipUI:Open()
    if self.popup then
        return
    end

    self.slotControls = {} -- 장비 슬롯 컨트롤을 저장할 테이블

    local punkPanel = PunkPanel:new(Rect(-300, 50, UI_SETTINGS.size.x, UI_SETTINGS.size.y))
    local profilePopup = Popup:new(punkPanel.backgroundPanel, "Profile")
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

    for slotId, slotPosition in pairs(UI_SETTINGS.slotPosition) do
        local slotControl = ItemSlot:new(Rect(slotPosition.x, slotPosition.y, 45, 45))
        local slotButton = slotControl:GetControl()
        slotButton.anchor = Anchor.MiddleCenter
        slotButton.pivot = Point(0.5, 0.5)

        local equippedItem = CustomEquip.GetEquipItem(slotId)
        if equippedItem then
            slotControl:SetItem(equippedItem)
            slotControl:SetEquipped(true)
        end

        slotButton.onClick.Add(function ()
            local itemPopup = ItemPopup:new(CustomEquip.GetEquipItem(slotId))
            itemPopup:SetButton("해제", function ()
                CustomEquip.UnequipItem(slotId)
                itemPopup:Close()
            end)
        end)

        punkPanel.centerPanel.AddChild(slotButton)

        self.slotControls[slotId] = slotControl
    end

    profilePopup:Build()
    punkPanel:Build()

    self.popup = profilePopup
end

function CustomEquipUI:Close()
    if self.popup then
        self.popup:Close()
        self.popup = nil
    end
end

function CustomEquipUI:GetSlotControl(slotId)
    return self.slotControls[slotId]
end

Client.GetTopic("CustomEquip.EquipItem").Add(function (slotId, titem)
    local isSuccess, titem = pcall(json_parse, titem)

    if not isSuccess then
        error("Failed to parse item data")
        return
    end

    CustomEquip.Set(slotId, titem)

    local slotControl = CustomEquipUI:GetSlotControl(slotId)
    if slotControl then
        slotControl:SetItem(titem)
        slotControl:SetEquipped(true)
    end
end)

Client.GetTopic("CustomEquip.UnequipItem").Add(function (slotId)
    CustomEquip.Set(slotId, nil)
    
    local slotControl = CustomEquipUI:GetSlotControl(slotId)
    if slotControl then
        slotControl:SetItem(nil)
        slotControl:SetEquipped(false)
    end
end)

LClient.Events.onKeyDown.Add(function (key)
    if key == "i" then
        ScreenUI.ShowPopup("Bag")
    end
end)

LClient.Events.onMyPlayerUnitCreated.Add(function ()
    Client.onTick.Add(function ()
        if ScreenUI.IsShowPopup("Bag") then
            CustomEquipUI:Open()
        else
            CustomEquipUI:Close()
        end
    end)
end)