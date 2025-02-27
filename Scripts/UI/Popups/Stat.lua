local Popup = require("UI/Components/Popup")
local DragArea = require("UI/Components/DragArea")
local PunkPanel = require("UI/Components/PunkPanel")

UIStat = {}

function UIStat:Open()
    local punkPanel = PunkPanel:new(Rect(0, 0, 312, 412))
    local statPopup = Popup:new(punkPanel.backgroundPanel, "Stat")
    local titleText = Text("스텟") {
        anchor = Anchor.MiddleCenter,
        pivot = Point(0.5, 0.5),
        textSize = 14,
    }
    titleText.SetSizeFit(true, true)

    punkPanel.topPanel.AddChild(titleText)
    punkPanel.backgroundPanel.anchor = Anchor.TopLeft
    punkPanel.backgroundPanel.pivot = Point(0, 0)
    punkPanel.backgroundPanel.position = Point(Client.width * 0.5 - punkPanel.backgroundPanel.width * 0.5, Client.height * 0.5 - punkPanel.backgroundPanel.height * 0.5)
    punkPanel.closeButton.visible = false

    local dragArea = DragArea:new(statPopup)
    punkPanel.backgroundPanel.AddChild(dragArea:GetControl())

    local closeButton = Button("", Rect(-12, 12, 16, 16)) {
        anchor = Anchor.TopRight,
        pivot = Point(1, 0),
    }
    closeButton.SetImage("Pictures/New_PunkGUI/0_close.png")

    closeButton.onClick.Add(function()
        statPopup:Close()
    end)
    dragArea:GetControl().AddChild(closeButton)

    statPopup:Build()
    punkPanel:Build()
end

LClient.Events.onKeyDown:Add(function (key)
    if key == "s" then
        UIStat:Open()
    end
end)