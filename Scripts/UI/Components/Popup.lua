local typeof = typeof
local string_startsWith = string.startsWith

local EventHandler = require("Utils/EventHandler")

local Popup = {
    onUpdate = EventHandler:new(),
    onClose = EventHandler:new(),
}

--- 팝업 생성자
--- 사용 예시:
--- ```lua
--- local popup = Popup:new(control)
--- popup.onUpdate:Add(function(delta)
---     print(delta)
--- end)
--- 
--- popup.onClose:Add(function()
---    print("Popup closed")
--- end)
--- 
--- popup:Build()
--- @param control Game.Scripts.UI.Control
function Popup:new(control, id)
    assert(string_startsWith(typeof(control), "Game.Scripts.UI"))

    local instance = {
        id = id,
        onUpdate = EventHandler:new(),
        onClose = EventHandler:new(),
        control = control,
    }
    self.__index = self

    return setmetatable(instance, self)
end

function Popup:GetControl()
    return self.control
end

function Popup:Build()
    if self.onUpdate:Count() > 0 then -- Update 이벤트가 등록되어 있으면
        self.onTick = function(delta)
            self.onUpdate:Fire(delta)
        end
        Client.onTick.Add(self.onTick)
    end

    self.control.showOnTop = true

    PopupManager:AddPopup(self)
end

function Popup:Close()
    if self.onTick then
        Client.onTick.Remove(self.onTick) -- Update 이벤트 제거
    end
    self.onClose:Fire()                   -- Close 이벤트 발생
    self.control.Destroy()                -- 팝업 제거

    PopupManager:RemovePopup(self)
end

return Popup