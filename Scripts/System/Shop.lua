local SHOP_DATA = Utility.JSONParseFromFile("Shop.json")

local Shop = {}

function Shop.GetProduct(productId)
    return SHOP_DATA.products[productId]
end

function Shop.Buy(productId, count)
    count = count or 1 -- 기본값: 1

    local product = Shop.GetProduct(productId)
    if Currency.Get(product.currencyId).type == "cube" then
        Client.UseCube(product.price * count, product.id)
        return
    end

    Client.FireEvent("Shop.Buy", productId, count)
end

function Shop.GetData()
    return SHOP_DATA
end

return Shop