local Mask = {}

function Mask:new()
    local instance = {}

    local maskButton = Button("", Rect(0, 0, Client.width, Client.height)) {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),
        color = Color(0, 0, 0, 0),
        showOnTop = true,
    }
    maskButton.onClick.Add(function ()
        instance:Close()
    end)

    instance.control = maskButton
    instance.onResize = function ()
        maskButton.sizeDelta = Point(Client.width, Client.height)
    end

    Client.onResize.Add(instance.onResize)

    self.__index = self
    return setmetatable(instance, self)
end

function Mask:GetControl()
    return self.control
end

function Mask:Close()
    Client.onResize.Remove(self.onResize)
    self.control.Destroy()
end

return Mask