local UIManager = {
    visible = true
}

function UIManager:SetVisible(isVisible)
    self.visible = isVisible
    if isVisible then
        LClient.Events.onShowUI:Fire()
    else
        LClient.Events.onHideUI:Fire()
    end
end

LClient.Events.onShowUI:Add(function ()
    ScreenUI.quickSlotVisible = true
end)

LClient.Events.onHideUI:Add(function ()
    ScreenUI.quickSlotVisible = false
end)

-- HUD 로드
require("UI/HUD/HUD")
require("UI/HUD/Menu")
require("UI/HUD/Gage")
require("UI/HUD/Dpad")
require("UI/HUD/Chat")
require("UI/HUD/Currency")

-- Popup 로드
require("UI/Popups/PopupManager")
require("UI/Popups/CustomEquip")  
require("UI/Popups/Stat")
require("UI/Popups/Shop")
require("UI/Popups/ShopBuy")

return UIManager