local HUD = {}

HUD.menu_button = {}
HUD.menu_button_icon = {
    "Pictures/mainmenu/icon_bag.png",
    "Pictures/mainmenu/icon_notice.png",
    "Pictures/mainmenu/icon_cube.png",
    "Pictures/mainmenu/icon_menu.png"
}
for i = 1, 4, 1 do
    HUD.menu_button[i] = Button("", Rect(-163 + (46 * (i - 1)), 10, 32, 32))
    HUD.menu_button[i].anchor = 2
    HUD.menu_button[i].pivotX = 1
    HUD.menu_button[i].pivotY = 0
    HUD.menu_button[i].SetImage(HUD.menu_button_icon[i])
end

-- bag
HUD.menu_button[1].onClick.Add(
    function()
        if ScreenUI.IsShowPopup("Bag") then
            ScreenUI.HidePopup("Bag")
        else
            ScreenUI.ShowPopup("Bag")
        end
    end
)

-- notice
HUD.menu_button[2].onClick.Add(
    function()
        ScreenUI.ShowPopup("EventPage")
    end
)

-- cube
HUD.menu_button[3].onClick.Add(
    function()
        ScreenUI.ShowPopup("CubeShop")
    end
)

-- menu
HUD.menu_button[4].onClick.Add(
    function()
        MainMenu:show()
    end
)

LClient.Events.onShowUI:Add(function ()
    for _, button in pairs(HUD.menu_button) do
        button.visible = true
    end
end)

LClient.Events.onHideUI:Add(function ()
    for _, button in pairs(HUD.menu_button) do
        button.visible = false
    end
end)