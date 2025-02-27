local Mask = {}

function Mask:new(popup, canClose)
    if canClose == nil then -- 기본 값은 true
        canClose = true
    end

    local instance = {}

    local maskButton = Button("", Rect(0, 0, Client.width, Client.height)) {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),
        opacity = 0,
        showOnTop = true,
    }

    local maskPanel = Panel(Rect(0, 0, maskButton.width, maskButton.height)) {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),
        color = Color(0, 0, 0, 0),
    }

    instance.control = maskButton
    instance.maskPanel = maskPanel
    instance.popup = popup
    instance.onResize = function ()
        maskButton.sizeDelta = Point(Client.width, Client.height)
        maskPanel.sizeDelta = Point(maskButton.width, maskButton.height)
    end

    maskButton.onClick.Add(function ()
        if not canClose then
            return
        end

        if popup then
            popup:Close()
        else
            instance:Close()
        end
    end)

    maskButton.AddChild(maskPanel)

    Client.onResize.Add(instance.onResize)

    self.__index = self
    return setmetatable(instance, self)
end

function Mask:GetControl()
    return self.control
end

function Mask:SetOpacity(opacity)
    self.maskPanel.SetOpacity(opacity)
end

function Mask:Close()
    Client.onResize.Remove(self.onResize)
    self.control.Destroy()
end

return Mask