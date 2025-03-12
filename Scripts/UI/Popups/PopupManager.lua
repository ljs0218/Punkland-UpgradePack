local PopupManager = {
    popups = {},
    popup_ids = {},
}

function PopupManager:AddPopup(popup)
    if self.popup_ids[popup.id] then -- 이미 등록된 팝업이면
        self.popup_ids[popup.id]:Close() -- 닫기
    end

    table.insert(self.popups, popup)
    self.popup_ids[popup.id] = popup
end

function PopupManager:RemovePopup(popup)
    for i, p in ipairs(self.popups) do
        if p == popup then
            table.remove(self.popups, i)
            self.popup_ids[popup.id] = nil
            break
        end
    end
end

function PopupManager:OrderToFront(popup)
    self:RemovePopup(popup)
    self:AddPopup(popup)
end

LClient.Events.onKeyDown.Add(function (key)
    if key == "esc" then
        local popup = PopupManager.popups[#PopupManager.popups]
        if not popup then return end
        
        popup:Close()
    end
end)

_G.PopupManager = PopupManager