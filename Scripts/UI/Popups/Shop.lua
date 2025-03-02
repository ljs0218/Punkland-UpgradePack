local Popup = require("UI/Components/Popup")
local DragArea = require("UI/Components/DragArea")
local ItemPopup = require("UI/Components/ItemPopup")
local PunkPanel = require("UI/Components/PunkPanel")

local ipairs = ipairs
local Client_GetItem = Client.GetItem

local SHOP_DATA = Shop.GetData()
local UI_SETTINGS = LClient.Config.UI.Shop

local LIMIT_TYPES = {
    Daily = "일일",
    Weekly = "주간",
    Monthly = "월간",
    Account = "계정",
}

UIShop = {}

local function ClearScrollContent(scroll)
    if scroll.content then
        scroll.content.Destroy()
    end
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
    
    self.categoryScroll = categoryScroll
    self.subCategoryScroll = subCategoryScroll
    self.productScroll = productScroll
    self:RefreshCategory()

    shopPopup:Build()
    punkPanel:Build()
end


function ShopUI:RefreshProducts(productIds)
    local spacing = UI_SETTINGS.productSpacing
    local width = self.productScroll.height * 0.5 - (spacing * 0.5)
    local height = self.productScroll.height * 0.5 - (spacing * 0.5)

    ClearScrollContent(self.productScroll)

    local contentPanel = GridPanel()
    contentPanel.constraint = 1
    contentPanel.constraintCount = 2
    contentPanel.cellSize = Point(width, height)
    contentPanel.spacing = Point(spacing, spacing)

    self.productScroll.content = contentPanel
    self.productScroll.AddChild(contentPanel)

    for i, productId in ipairs(productIds) do
        local product = Shop.GetProduct(productId)
        local gameItem = Client_GetItem(product.dataID)

        local productButton = Button("", Rect(0, 0, 0, 0))
        productButton.SetImage("Pictures/New_PunkGUI/0_panel.png")

        local pricePanel = Image("Pictures/New_PunkGUI/0_new_titlepanel.png", Rect(0, -1, width - 2, 36)) {
            anchor = Anchor.BottomCenter,
            pivot = Point(0.5, 1),
        }

        local priceWrapper = HorizontalPanel()
        priceWrapper.anchor = Anchor.MiddleCenter
        priceWrapper.pivot = Point(0.5, 0.5)
        priceWrapper.childAlign = 4
        priceWrapper.spacing = 4

        local priceIcon = Image(Currency.GetPath(product.currencyId), Rect(0, 0, 24, 24)) {
            anchor = Anchor.MiddleLeft,
            pivot = Point(0, 0.5),
        }
        local priceText = Text(LUtility.FormatNumber(product.price)) {
            anchor = Anchor.MiddleLeft,
            pivot = Point(0, 0.5),
            textAlign = TextAlign.MiddleLeft,
        }
        priceText.SetSizeFit(true, true)
        priceWrapper.AddChild(priceIcon)
        priceWrapper.AddChild(priceText)
        priceWrapper.SetSizeFit(true, true)
        pricePanel.AddChild(priceWrapper)

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

        local limitText = Text() {
            anchor = Anchor.BottomCenter,
            position = Point(0, -12),
            pivot = Point(0.5, 1),
            textSize = 12,
        }
        if product.limitType and LIMIT_TYPES[product.limitType] then
            limitText.text = LIMIT_TYPES[product.limitType] .. " 제한 " .. 0 .. "/" .. product.limitCount
        end
        limitText.SetSizeFit(true, true)

        local bling_image = Image("Pictures/New_PunkGUI/0_bling.png",
            Rect(0, 0, infoPanel.height * 0.8, infoPanel.height * 0.8)) {
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
            local itemPopup = ItemPopup:new({ dataID = product.dataID })
            itemPopup:SetButton("구매하기", function()
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

function ShopUI:RefreshSubCategory(subCategoryIds)
    ClearScrollContent(self.subCategoryScroll)

    local contentPanel = HorizontalPanel()
    self.subCategoryScroll.content = contentPanel
    self.subCategoryScroll.AddChild(contentPanel)

    local oldSelectedBar = nil
    for i, subCategoryId in ipairs(subCategoryIds) do
        local subCategory = SHOP_DATA.subCategories[subCategoryId]
        local subCategoryButton = Button("", Rect(0, 0, UI_SETTINGS.categorySize.x, UI_SETTINGS.categorySize.y)) {
            opacity = 0,
        }
        local subCategoryText = Text(subCategory.name) {
            anchor = Anchor.MiddleCenter,
            pivot = Point(0.5, 0.5),
            textSize = 14,
            textAlign = TextAlign.MiddleCenter,
        }
        subCategoryText.SetSizeFit(true, true)
        local selectedBar = Panel(Rect(0, 0, UI_SETTINGS.categorySize.x - 8, 1)) {
            anchor = Anchor.BottomCenter,
            pivot = Point(0.5, 1),
            color = Color(255, 255, 255),
        }

        subCategoryButton.onClick.Add(function()
            if oldSelectedBar then
                oldSelectedBar.color = Color.white
            end
            selectedBar.color = Color(245, 171, 12)
            oldSelectedBar = selectedBar
            ShopUI:RefreshProducts(subCategory.productIds)
        end)

        subCategoryButton.AddChild(subCategoryText)
        subCategoryButton.AddChild(selectedBar)
        contentPanel.AddChild(subCategoryButton)

        if i == 1 then -- 처음 생성된 버튼 클릭 처리
            subCategoryButton.onClick.Call()
        end

        contentPanel.AddChild(subCategoryButton)
    end

    contentPanel.SetSizeFit(true, true)
end

function ShopUI:RefreshCategory()
    ClearScrollContent(self.categoryScroll)

    local contentPanel = VerticalPanel()
    self.categoryScroll.content = contentPanel
    self.categoryScroll.AddChild(contentPanel)

    local oldSelectedBar = nil
    for i, category in ipairs(SHOP_DATA.categories) do
        local categoryButton = Button("", Rect(0, 0, self.categoryScroll.width, UI_SETTINGS.categorySize.y)) {
            opacity = 0,
        }
        local selectedBar = Panel(Rect(0, 0, 1, categoryButton.height - 4)) {
            anchor = Anchor.MiddleRight,
            pivot = Point(1, 0.5),
            color = Color.white,
        }
        local categoryText = Text(category.name) {
            anchor = Anchor.MiddleCenter,
            pivot = Point(0.5, 0.5),
            textSize = 14,
            textAlign = TextAlign.MiddleCenter,
        }
        categoryText.SetSizeFit(true, true)

        categoryButton.onClick.Add(function()
            if oldSelectedBar then
                oldSelectedBar.color = Color.white
            end
            selectedBar.color = Color(245, 171, 12)
            oldSelectedBar = selectedBar

            ShopUI:RefreshSubCategory(category.subCategoryIds)
        end)

        categoryButton.AddChild(selectedBar)
        categoryButton.AddChild(categoryText)
        contentPanel.AddChild(categoryButton)

        if i == 1 then -- 처음 생성된 버튼 클릭 처리
            categoryButton.onClick.Call()
        end
    end
end

LClient.Events.onKeyDown:Add(function(key)
    if key == "`" then
        ShopUI:Open()
    end
end)
