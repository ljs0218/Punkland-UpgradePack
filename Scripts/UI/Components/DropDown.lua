local EventHandler = require("Utils/EventHandler")

local DropDown = {
    --- @type Game.Scripts.UI.Button
    button = nil,
    --- @type Game.Scripts.UI.VerticalPanel
    dropDown = nil,
    --- @type string[]
    items = nil,
    --- @type number
    --- 선택된 아이템의 인덱스
    selectedIndex = 0,
    --- @type string
    --- 선택된 아이템의 이름
    selectedItem = nil,
    --- @type boolean
    interactable = true,
    --- @type Game.Scripts.UI.Text
    label = nil,

    onValueChanged = nil,
}

--- DropDown 생성자
--- 사용 예시:
--- ```lua
--- local dropDown = DropDown:new(Rect(10, 60, 160, 32), {
---     "Item 1",
---     "Item 2",
---     "Item 3",
--- })
--- 
--- dropDown.onValueChanged:Add(function()
---    print(dropDown.selectedIndex, dropDown.selectedItem)
--- end)
--- 
--- control.AddChild(dropDown:GetControl())
--- ```
--- @param rect Game.Scripts.Graphics.Rect
--- @param items string[]
function DropDown:new(rect, items)
    assert(typeof(rect) == "Game.Scripts.Graphics.Rect")

    items = items or { "Option A", "Option B", "Option C" }
    assert(type(items) == "table")
    assert(#items > 0)

    local instance = setmetatable({}, self)
    self.__index = self

    instance.onValueChanged = EventHandler:new()
    instance.interactable = true -- 상호작용 가능 여부
    instance.selectedIndex = 0
    instance.selectedItem = nil
    instance.items = items

    -- 버튼 생성
    instance.button = Button("", rect)
    instance.button.SetImage("Pictures/New_PunkGUI/0_panel.png")

    -- 라벨 생성
    instance.label = Text(
        items[1],
        Rect(6, 0, rect.width, rect.height)
    ) {
        textAlign = TextAlign.MiddleLeft,
    }
    instance.arrow = Image("Pictures/New_PunkGUI/0_down.png", Rect(-2, 0, 13, 13)) {
        anchor = Anchor.MiddleRight,
        pivot = Point(1, 0.5),
        position = Point(-6, 0),
    }
    instance.label.anchor = Anchor.MiddleCenter
    instance.label.pivot = Point(0.5, 0.5)

    instance.button.AddChild(instance.arrow)
    instance.button.AddChild(instance.label)

    -- 버튼 클릭 시 드롭다운 표시
    instance.button.onClick.Add(function()
        if instance.interactable then
            instance:ShowDropDown()
        end
    end)

    return instance
end

function DropDown:GetControl()
    --- @type Game.Scripts.UI.Button
    return self.button
end

function DropDown:ShowDropDown()
    if self.dropDown then
        self.dropDown.Destroy()
        self.dropDown = nil
        return
    end

    self.dropDown = VerticalPanel() {
        anchor = Anchor.BottomCenter,
        pivot = Point(0.5, 0),
    }

    for i, item in ipairs(self.items) do
        local button = Button(item, Rect(0, 0, self.button.width, 32))
        button.anchor = Anchor.MiddleCenter
        button.pivot = Point(0.5, 0.5)
        button.SetImage("Pictures/New_PunkGUI/0_panel.png")
        button.SetButtonColors(
            Color(255, 255, 255),
            Color(200, 200, 200),
            Color(120, 120, 120),
            Color(255, 255, 255),
            Color(255, 255, 255)
        )

        button.onClick.Add(function()
            self.label.text = item
            self.selectedIndex = i
            self.selectedItem = item
            self.onValueChanged:Fire()

            self.dropDown.Destroy()
            self.dropDown = nil
        end)

        self.dropDown.AddChild(button)
    end

    self.dropDown.SetSizeFit(true, true)
    self.dropDown.ForceRebuildLayoutImmediate()

    self.button.AddChild(self.dropDown)
end

function DropDown:AddItem(item)
    table.insert(self.items, item)
end

function DropDown:RemoveItem(index)
    table.remove(self.items, index)
end

return DropDown
