local typeof = typeof

local DragArea = {}

--- DragArea 생성자
--- 마우스 드래그로 팝업을 이동할 수 있는 영역을 생성합니다.
--- 사용 예시:
--- ```lua
--- local dragArea = DragArea:new(popup)
--- control.AddChild(dragArea:GetControl())
--- ```
--- @param rect Game.Scripts.Graphics.Rect
function DragArea:new(popup, rect)
    assert(type(popup) == "table")
    if not rect then
        rect = Rect(0, 0, popup:GetControl().width, 42)
    end

    assert(typeof(rect) == "Game.Scripts.Graphics.Rect")

    local instance = {}
    instance.popup = popup
    --- @type Game.Scripts.UI.Button
    --- 드래그 버튼
    instance.control = Button("", rect) {
        anchor = Anchor.TopCenter,
        pivot = Point(0.5, 0),
        opacity = 0,
    }

    self.__index = self

    local newObj = setmetatable(instance, self)
    newObj:Bind()

    return newObj
end

function DragArea:GetControl()
    return self.control
end

function DragArea:Bind()
    local target = self.popup:GetControl()
    local oldPos = Point(0, 0)

    local function onMouseDrag()
        local newPos = Input.mousePosition
        local dx = oldPos.x - newPos.x
        local dy = oldPos.y - newPos.y
        if dx == 0 and dy == 0 then return end -- 움직임이 감지되지 않았을 때

        local pos = target.position
        local newControlPos = Point(pos.x - dx, pos.y - dy)

        -- 화면 밖으로 나가지 않도록 제한
        if newControlPos.x < 0 then newControlPos.x = 0 end
        if newControlPos.y < 0 then newControlPos.y = 0 end
        if (Client.height - target.height) - newControlPos.y < 0 then
            newControlPos.y = Client.height - target.height
        end
        if (Client.width - target.width) - newControlPos.x < 0 then
            newControlPos.x = Client.width - target.width
        end

        target.position = newControlPos
        oldPos = newPos
    end

    self.control.onMouseDown.Add(function()
        target.showOnTop = false
        target.showOnTop = true
        oldPos = Input.mousePosition
        Client.onTick.Add(onMouseDrag)

        PopupManager:OrderToFront(self.popup)
    end)

    self.control.onMouseUp.Add(function()
        Client.onTick.Remove(onMouseDrag)
    end)

    target.AddChild(self:GetControl())
end

return DragArea
