MainMenu = {}

MainMenu.frame = VerticalPanel(Rect(-6, 0, 208, 266))
MainMenu.frame.anchor = 2
MainMenu.frame.pivotX = 1
MainMenu.frame.pivotY = 0
MainMenu.frame.childControlWidth = true
MainMenu.frame.childControlHeight = true
MainMenu.frame.childForceExpandWidth = true
MainMenu.frame.childForceExpandHeight = true
MainMenu.frame.SetSizeFit(false, true)

MainMenu.frame_bg = Image("Pictures/mainmenu/icon_bg2.png", Rect(0, 0, 0, 0))
MainMenu.frame_bg.anchor = 15
MainMenu.frame_bg.imageType = 1
MainMenu.frame_bg.ignoreLayout = true
MainMenu.frame.AddChild(MainMenu.frame_bg)

MainMenu.menu_grid = GridPanel(Rect(0, 0, 0, 0))
MainMenu.menu_grid.contentSizeFitterEnabled = false
MainMenu.menu_grid.padding = RectOff(13, 13, 10, 10)
MainMenu.menu_grid.spacing = Point(2, 16)
MainMenu.menu_grid.cellSize = Point(44, 46)
MainMenu.menu_grid.childAlign = 0
MainMenu.menu_item = {}
MainMenu.menu_icon = {
    "Pictures/mainmenu/icon_bag.png",
    "Pictures/mainmenu/icon_notice.png",
    "Pictures/mainmenu/icon_cube.png",
    "Pictures/mainmenu/icon_menu.png",
    "Pictures/mainmenu/icon_profile.png",
    "Pictures/mainmenu/icon_skill.png",
    "Pictures/mainmenu/Icon_player.png",
    "Pictures/mainmenu/icon_message.png",
    "Pictures/mainmenu/icon_party.png",
    "Pictures/mainmenu/icon_guild.png",
    "Pictures/mainmenu/icon_mail.png",
    "Pictures/mainmenu/icon_book.png",
    "Pictures/mainmenu/icon_nft_storage.png",
    "Pictures/mainmenu/icon_play_setting.png",
    "Pictures/mainmenu/icon_smith.png",
    "Pictures/mainmenu/icon_setting.png",
    "Pictures/mainmenu/icon_end_game.png"
}
MainMenu.menu_text = {
    "가방",
    "공지",
    "큐브샵",
    "",
    "프로필",
    "스킬",
    "플레이어",
    "메세지",
    "파티",
    "클랜",
    "우편함",
    "성장",
    "NFT",
    "플레이",
    "제작",
    "설정",
    "게임종료"
}

for i = 1, #MainMenu.menu_icon, 1 do
    MainMenu.menu_item[i] = Button("", Rect(0, 0, 44, 46))
    MainMenu.menu_item[i].SetButtonColors(
        Color(0, 0, 0, 0),
        Color(0, 0, 0, 0),
        Color(255, 255, 255, 128),
        Color(0, 0, 0, 0),
        Color(0, 0, 0, 0)
    )
    local icon = Image(MainMenu.menu_icon[i], Rect(0, 0, 32, 32))
    icon.anchor = 1
    icon.pivotX = 0.5
    icon.pivotY = 0
    MainMenu.menu_item[i].AddChild(icon)
    local label = Text(MainMenu.menu_text[i], Rect(0, 0, 44, 14))
    label.anchor = 7
    label.pivotX = 0.5
    label.pivotY = 1
    label.textAlign = 4
    label.textSize = 11
    label.borderDistance = Point(1, 1)
    label.borderEnabled = true
    MainMenu.menu_item[i].AddChild(label)
    MainMenu.menu_grid.AddChild(MainMenu.menu_item[i])
end
MainMenu.frame.AddChild(MainMenu.menu_grid)

MainMenu.frame.visible = false

function MainMenu:show()
    MainMenu.frame.visible = true
    MainMenu.frame.showOnTop = true
end

function MainMenu:hide()
    MainMenu.frame.visible = false
end

-- 가방
MainMenu.menu_item[1].onClick.Add(
    function()
        ScreenUI.ShowPopup("Bag")
        MainMenu:hide()
    end
)

-- 공지
MainMenu.menu_item[2].onClick.Add(
    function()
        ScreenUI.ShowPopup("EventPage")
        MainMenu:hide()
    end
)

-- 큐브
MainMenu.menu_item[3].onClick.Add(
    function()
        ScreenUI.ShowPopup("CubeShop")
        MainMenu:hide()
    end
)

-- 닫기
MainMenu.menu_item[4].onClick.Add(
    function()
        MainMenu:hide()
    end
)

-- 프로필
MainMenu.menu_item[5].onClick.Add(
    function()
        ScreenUI.ShowPopup("PlayerInfo")
        MainMenu:hide()
    end
)

-- 스킬
MainMenu.menu_item[6].onClick.Add(
    function()
        ScreenUI.ShowPopup("Skills")
        MainMenu:hide()
    end
)

-- 플레이어
MainMenu.menu_item[7].onClick.Add(
    function()
        ScreenUI.ShowPopup("Players")
        MainMenu:hide()
    end
)

-- 메시지
MainMenu.menu_item[8].onClick.Add(
    function()
        ScreenUI.ShowPopup("Messages")
        MainMenu:hide()
    end
)

-- 파티
MainMenu.menu_item[9].onClick.Add(
    function()
        ScreenUI.ShowPopup("Party")
        MainMenu:hide()
    end
)

--클랜
MainMenu.menu_item[10].onClick.Add(
    function()
        ScreenUI.ShowPopup("Clan")
        MainMenu:hide()
    end
)

--우편함
MainMenu.menu_item[11].onClick.Add(
    function()
        ScreenUI.ShowPopup("Mailbox")
        MainMenu:hide()
    end
)

-- 고급
MainMenu.menu_item[12].onClick.Add(
    function()
        -- GUI_Main_open()
        Client.ShowCenterLabel("업데이트 예정입니다.")
        MainMenu:hide()
    end
)

-- NFT 창고
MainMenu.menu_item[13].onClick.Add(
    function()
        --ScreenUI.ShowPopup("Messages")
        Client.ShowCenterLabel("업데이트 예정입니다.")
        MainMenu:hide()
    end
)

-- 플레이 설정
MainMenu.menu_item[14].onClick.Add(
    function()
        Client.ShowCenterLabel("업데이트 예정입니다.")
        -- Client.FireEvent("Play", "Play")
        MainMenu:hide()
    end
)

-- 제작
MainMenu.menu_item[15].onClick.Add(
    function()
        Client.ShowCenterLabel("업데이트 예정입니다.")
        -- Client.FireEvent("making", "making")
        MainMenu:hide()
    end
)

-- 설정
MainMenu.menu_item[16].onClick.Add(
    function()
        ScreenUI.ShowPopup("GameSettings")
        MainMenu:hide()
    end
)

-- 게임종료
MainMenu.menu_item[17].onClick.Add(
    function()
        Client.ShowYesNoAlert(
            "정말 종료할까요?",
            function(isYes)
                if isYes == 1 then
                    Client.Quit()
                else
                end
            end
        )
    end
)
