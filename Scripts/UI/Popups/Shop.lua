local Popup = require("UI/Components/Popup")
local DragArea = require("UI/Components/DragArea")
local ItemPopup = require("UI/Components/ItemPopup")
local PunkPanel = require("UI/Components/PunkPanel")

local Client_GetItem = Client.GetItem

local UI_SETTINGS = LClient.Config.UI.Shop

UIShop = {}

local categories = {
    "카테고리A",
    "카테고리B",
    "카테고리C",
    "카테고리D",
    "카테고리E",
    "카테고리F",
    "카테고리G",
    "카테고리H",
    "카테고리I",
}

local subcategories = {
    { "카테고리A", "카테고리B", "카테고리C", "카테고리D", "카테고리E" },
}

local products = {
    [1] = {
        dataID = 1,
        price = 1000,
        currencyId = 1,
        description = "상품A 설명",
    },
    [2] = {
        dataID = 1,
        price = 1000,
        currencyId = 2,
        description = "상품B 설명",
        limitType = "", -- 제한 타입 (Daily, Weekly, Monthly, Account, Level, Var) (일일, 주간, 월간, 계정, 변수)
        limitCount = 3, -- 제한 횟수
    },
    [3] = {
        dataID = 1,
        price = 1000,
        currencyId = 3,
        description = "상품C 설명",
    },
    [4] = {
        dataID = 1,
        price = 1000,
        currencyId = 4,
        description = "상품D 설명",
    },
}

local function InitCategory(categoryScroll)
    local contentPanel = VerticalPanel()
    categoryScroll.content = contentPanel
    categoryScroll.AddChild(contentPanel)

    for _, category in pairs(categories) do
        local categoryButton = Button("", Rect(0, 0, categoryScroll.width, UI_SETTINGS.categorySize.y)) {
            opacity = 0,
        }
        local categoryText = Text(category) {
            anchor = Anchor.MiddleCenter,
            pivot = Point(0.5, 0.5),
            textSize = 14,
            textAlign = TextAlign.MiddleCenter,
        }
        local selectedBar = Panel(Rect(0, 0, 1, categoryButton.height - 4)) {
            anchor = Anchor.MiddleRight,
            pivot = Point(1, 0.5),
            color = Color(245, 171, 12),
        }

        categoryButton.onClick.Add(function()
            print(category)
        end)

        categoryButton.AddChild(selectedBar)
        categoryButton.AddChild(categoryText)
        contentPanel.AddChild(categoryButton)
    end

    contentPanel.SetSizeFit(true, true)

    return categoryScroll
end

local function InitSubCategory(subCategoryScroll)
    local contentPanel = HorizontalPanel()
    subCategoryScroll.content = contentPanel
    subCategoryScroll.AddChild(contentPanel)

    for _, subCategory in pairs(subcategories[1]) do
        local subCategoryButton = Button("", Rect(0, 0, UI_SETTINGS.categorySize.x, UI_SETTINGS.categorySize.y)) {
            opacity = 0,
        }
        local subCategoryText = Text(subCategory) {
            anchor = Anchor.MiddleCenter,
            pivot = Point(0.5, 0.5),
            textSize = 14,
            textAlign = TextAlign.MiddleCenter,
        }
        local selectedBar = Panel(Rect(0, 0, UI_SETTINGS.categorySize.x - 8, 1)) {
            anchor = Anchor.BottomCenter,
            pivot = Point(0.5, 1),
            color = Color(245, 171, 12),
        }

        subCategoryButton.onClick.Add(function()
            print("서브카테고리 " .. subCategory)
        end)

        subCategoryButton.AddChild(subCategoryText)
        subCategoryButton.AddChild(selectedBar)
        contentPanel.AddChild(subCategoryButton)
    end

    contentPanel.SetSizeFit(true, true)

    return subCategoryScroll
end

local function InitProduct(productScroll)
    local spacing = UI_SETTINGS.productSpacing
    local width = productScroll.height * 0.5 - (spacing * 0.5)
    local height = productScroll.height * 0.5 - (spacing * 0.5)

    local contentPanel = GridPanel()
    contentPanel.constraint = 1
    contentPanel.constraintCount = 2
    contentPanel.cellSize = Point(width, height)
    contentPanel.spacing = Point(spacing, spacing)

    productScroll.content = contentPanel
    productScroll.AddChild(contentPanel)

    for productId, product in ipairs(products) do
        local gameItem = Client_GetItem(product.dataID)

        local productButton = Button("", Rect(0, 0, 0, 0))
        productButton.SetImage("Pictures/New_PunkGUI/0_panel.png")

        local pricePanel = Image("Pictures/New_PunkGUI/0_new_titlepanel.png", Rect(0, -1, width - 2, 36)) {
            anchor = Anchor.BottomCenter,
            pivot = Point(0.5, 1),
        }

        local infoPanel = Panel(Rect(0, 0, width, height - pricePanel.height)) {
            anchor = Anchor.TopCenter,
            pivot = Point(0.5, 0),
            opacity = 0,
        }

        local nameText = Text(gameItem.name) {
            anchor = Anchor.TopCenter,
            position = Point(0, 12),
            pivot = Point(0.5, 0),
            textSize = 14,
        }
        nameText.SetSizeFit(true, true)
        
        local limitText = Text("계정 제한 0/1") {
            anchor = Anchor.BottomCenter,
            position = Point(0, -12),
            pivot = Point(0.5, 1),
            textSize = 12,
        }
        limitText.SetSizeFit(true, true)

        local bling_image = Image("Pictures/New_PunkGUI/0_bling.png", Rect(0, 0, infoPanel.height * 0.8, infoPanel.height * 0.8)) {
            anchor = Anchor.MiddleCenter,
            pivot = Point(0.5, 0.5),
            opacity = 60,
        }
        local iconImage = Image("", Rect(0, 0, infoPanel.height * 0.4, infoPanel.height * 0.4)) {
            anchor = Anchor.MiddleCenter,
            pivot = Point(0.5, 0.5),
        }
        iconImage.SetImageID(gameItem.imageID)

        productButton.onClick.Add(function()
            print("상품 " .. gameItem.name)
            local itemPopup = ItemPopup:new({ dataID = product.dataID })
            itemPopup:SetButton("구매하기", function ()
                itemPopup:Close()
                ShopUI.Buy(productId)
            end)
        end)

        infoPanel.AddChild(bling_image)
        infoPanel.AddChild(nameText)
        infoPanel.AddChild(iconImage)
        infoPanel.AddChild(limitText)
        productButton.AddChild(infoPanel)
        productButton.AddChild(pricePanel)
        contentPanel.AddChild(productButton)
    end

    contentPanel.SetSizeFit(true, true)
end

ShopUI = {}

function ShopUI:Open()
    local punkPanel = PunkPanel:new(Rect(0, 0, 800, 480))
    local shopPopup = Popup:new(punkPanel.backgroundPanel, "Shop")
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

    local categoryScroll = ScrollPanel(Rect(0, 0, UI_SETTINGS.categorySize.x, 430 - UI_SETTINGS.categorySize.y)) {
        anchor = Anchor.BottomLeft,
        pivot = Point(0, 1),
        horizontal = false,
        opacity = 0,
    }
    punkPanel.centerPanel.AddChild(categoryScroll)

    local subCategoryScroll = ScrollPanel(Rect(0, 0, 800 - categoryScroll.width, 48)) {
        anchor = Anchor.TopRight,
        pivot = Point(1, 0),
        vertical = false,
        opacity = 0,
    }
    punkPanel.centerPanel.AddChild(subCategoryScroll)

    local productScroll = ScrollPanel(
        Rect(
            -UI_SETTINGS.productScrollPadding,
            -UI_SETTINGS.productScrollPadding,
            800 - categoryScroll.width - UI_SETTINGS.productScrollPadding * 2,
            punkPanel.centerPanel.height - subCategoryScroll.height - UI_SETTINGS.productScrollPadding * 2
        )
    ) {
        anchor = Anchor.BottomRight,
        pivot = Point(1, 1),
        vertical = false,
        opacity = 0,
    }
    punkPanel.centerPanel.AddChild(productScroll)

    InitCategory(categoryScroll)
    InitSubCategory(subCategoryScroll)
    InitProduct(productScroll)

    shopPopup:Build()
    punkPanel:Build()
end

LClient.Events.onKeyDown:Add(function(key)
    if key == "`" then
        ShopUI:Open()
    end
end)
