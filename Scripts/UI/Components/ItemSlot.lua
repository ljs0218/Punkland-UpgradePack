local ItemSlot = {}

function ItemSlot:new(rect)
    assert(typeof(rect) == "Game.Scripts.Graphics.Rect")

    local instance = {}

    local slotButton = Button("", rect)
    slotButton.SetImage("Pictures/New_PunkGUI/0_slot_new.png")

    local iconText = Image("", Rect(0, 0, rect.width - 6, rect.height - 6)) {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),
        opacity = 0,
    }

    local equipText = Text("", Rect(0, 0, rect.width - 6, rect.height - 6)) {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),

        textSize = 14,
        textAlign = TextAlign.UpperRight,

        color = Color(0, 250, 0),
        borderEnabled = true,
        borderColor = Color.black,
    }

    slotButton.AddChild(iconText)
    slotButton.AddChild(equipText)

    instance.iconText = iconText
    instance.equipText = equipText
    instance.slotButton = slotButton

    self.__index = self
    return setmetatable(instance, self)
end

function ItemSlot:GetControl()
    return self.slotButton
end

function ItemSlot:SetItem(titem)
    if not titem then
        self.iconText.opacity = 0
        self.equipText.text = ""
        return
    end
    
    if titem.dataID then
        local gameItem = Client.GetItem(titem.dataID)
        if gameItem then
            self.iconText.SetImageID(gameItem.imageID)
            self.iconText.opacity = 255
        end
    end
end

function ItemSlot:SetEquipped(isEquipped)
    if isEquipped then
        self.equipText.text = "E"
    else
        self.equipText.text = ""
    end
end

return ItemSlot