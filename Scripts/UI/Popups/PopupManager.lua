local PopupManager = {
    popups = {}
}

function PopupManager:AddPopup(popup)
    table.insert(self.popups, popup)
end

function PopupManager:RemovePopup(popup)
    for i, p in ipairs(self.popups) do
        if p == popup then
            table.remove(self.popups, i)
            break
        end
    end
end

function PopupManager:OrderToFront(popup)
    for i, p in ipairs(self.popups) do
        if p == popup then
            table.remove(self.popups, i)
            table.insert(self.popups, popup)
            break
        end
    end
    
end

Client.onTick.Add(function()
    if Input.GetKeyUp(Input.KeyCode.Escape) then
        local popup = PopupManager.popups[#PopupManager.popups]
        if not popup then return end
        
        popup:Close()
    end
end)

_G.PopupManager = PopupManager