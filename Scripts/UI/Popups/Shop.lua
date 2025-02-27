local Popup = require("UI/Components/Popup")
local DragArea = require("UI/Components/DragArea")
local PunkPanel = require("UI/Components/PunkPanel")

UIShop = {}

local categories = {
    "아이템",
    "장비",
    "소모품",
    "기타",
}

local function InitCategory(categoryScroll)
    local verticalPanel = VerticalPanel()
    categoryScroll.content = verticalPanel
    categoryScroll.AddChild(verticalPanel)

    for _, category in pairs(categories) do
        local categoryButton = Button("", Rect(0, 0, categoryScroll.width, 42)) {
            opacity = 0,
        }
        local categoryText = Text(category) {
            anchor = Anchor.MiddleCenter,
            pivot = Point(0.5, 0.5),
            textSize = 14,
            textAlign = TextAlign.MiddleCenter,
        }
        local selectedBar = Panel(Rect(0, 0, 2, categoryButton.height - 4)) {
            anchor = Anchor.MiddleRight,
            pivot = Point(1, 0.5),
            color = Color(245, 171, 12),
        }

        categoryButton.onClick.Add(function()
            print(category)
        end)

        categoryButton.AddChild(selectedBar)
        categoryButton.AddChild(categoryText)
        verticalPanel.AddChild(categoryButton)
    end

    verticalPanel.SetSizeFit(true, true)

    return categoryScroll
end

function UIShop:Open()
    local punkPanel = PunkPanel:new(Rect(0, 0, 800, 480))
    local shopPopup = Popup:new(punkPanel.backgroundPanel)
    local titleText = Text("상점") {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),
        textSize = 14,
    }
    titleText.SetSizeFit(true, true)

    punkPanel.topPanel.AddChild(titleText)
    punkPanel.backgroundPanel.anchor = Anchor.MiddleCenter
    punkPanel.backgroundPanel.pivot = Point(0.5, 0.5)
    punkPanel.closeButton.onClick.Add(function()
        shopPopup:Close()
    end)

    local categoryWrapper = ScrollPanel(Rect(0, 0, 126, 430)) {
        anchor = Anchor.MiddleLeft,
        pivot = Point(0, 0.5),
        horizontal = false,
        opacity = 0,
    }
    punkPanel.centerPanel.AddChild(categoryWrapper)
    
    InitCategory(categoryWrapper)

    shopPopup:Build()
    punkPanel:Build()
end

LClient.Events.onKeyDown:Add(function (key)
    if key == "`" then
        UIShop:Open()
    end
end)