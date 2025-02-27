local PunkPanel = {}

--- 펑크랜드 패널 디자인의 패널을 생성합니다.
--- @param rect Game.Scripts.Graphics.Rect
--- ```lua
--- local punkPanel = PunkPanel:new(Rect(position.x, position.y, 240, 132))
--- punkPanel.backgroundPanel.anchor = Anchor.TopRight
--- punkPanel.backgroundPanel.pivot = Point(1, 0)
--- punkPanel.topPanel.sizeDelta = Point(punkPanel.topPanel.width, 55)
--- punkPanel.closeButton.visible = false
--- punkPanel:Build() -- 서서히 커지는 애니메이션과 함께 패널을 생성합니다.
--- ```
function PunkPanel:new(rect)
    assert(typeof(rect) == "Game.Scripts.Graphics.Rect")

    local instance = {}
    
    local backgroundPanel = Image("Pictures/New_PunkGUI/0_panel.png", rect) {
        imageType = ImageType.Sliced,
        opacity = 242,
        scale = Point(0, 0),
    }
    
    local topPanel = Image("Pictures/New_PunkGUI/0_new_titlepanel.png", Rect(0, 1, backgroundPanel.width - 2, 43)) {
        anchor = Anchor.TopCenter,
        pivot = Point(0.5, 0),
        imageType = ImageType.Sliced,
    }

    local centerPanel = Panel(Rect(0, -1, backgroundPanel.width - 2, backgroundPanel.height - topPanel.height - 2)) {
        anchor = Anchor.BottomCenter,
        pivot = Point(0.5, 1),
        opacity = 0,
    }
    
    local closeButton = Button("", Rect(-14, 0.5, 16, 16)) {
        anchor = Anchor.MiddleRight,
        pivot = Point(1, 0.5),
    }
    closeButton.SetImage("Pictures/New_PunkGUI/0_close.png")

    topPanel.AddChild(closeButton)
    backgroundPanel.AddChild(topPanel)
    backgroundPanel.AddChild(centerPanel)

    instance.topPanel = topPanel
    instance.centerPanel = centerPanel
    instance.closeButton = closeButton
    instance.backgroundPanel = backgroundPanel

    self.__index = self
    return setmetatable(instance, self)
end

function PunkPanel:GetControl()
    return self.backgroundPanel
end

function PunkPanel:Build()
    Tween.DONumber(0, 1, 0.2, function (number)
        self.backgroundPanel.scale = Point(number, number)
    end)
end

return PunkPanel