local SHOP_DATA = Utility.JSONParseFromFile("Shop.json")

local type = type
local assert = assert
local math_floor = math.floor

local Server_CreateItem = Server.CreateItem
local Server_GetItem = Server.GetItem

local Shop = {}

function Shop.GetProduct(productId)
    return SHOP_DATA.products[productId]
end

--- @param unit Commons.Server.Scripts.ScriptUnit
--- @param productId number
--- @param count number
function Shop.GiveReward(unit, productId, count)
    if not unit then return end
    
    -- 상품이 존재하지 않을 경우 리턴
    local product = Shop.GetProduct(productId)
    if not product then
        return
    end

    local gameItem = Server_GetItem(product.dataID)
    unit.AddItem(product.dataID, count, false)
    unit.SendCenterLabel(gameItem.name .. " 아이템을 구매했습니다!")
end

--- @param unit Commons.Server.Scripts.ScriptUnit
--- @param productId number
--- @param count number
function Shop.Buy(unit, productId, count)
    if not unit then return end

    assert(type(productId) == "number")
    assert(type(count) == "number")
    
    -- 1개 미만으로 구매할 경우 리턴
    if count < 1 then
        return
    end
    
    -- 상품이 존재하지 않을 경우 리턴
    local product = Shop.GetProduct(productId)
    if not product then
        return
    end

    local totalPrice = product.price * count

    -- 소지금이 부족할 경우
    if totalPrice > LUnit.Currency.GetAmount(unit, product.currencyId) then
        unit.SendCenterLabel("<color=#FF0000>소지금이 부족합니다.</color>")
        return
    end

    LUnit.Currency.AddAmount(unit, product.currencyId, -totalPrice)
    Shop.GiveReward(unit, productId, count)
end

Server.GetTopic("Shop.Buy").Add(function(productId, count)
    Shop.Buy(unit, productId, count)
end)

--- @param player Commons.Server.Scripts.ScriptRoomPlayer
Server.onBuyItem.Add(function(player, productId, unknown, amount)
    productId = assert(tonumber(productId))

    -- 상품이 존재하지 않을 경우 리턴
    local product = Shop.GetProduct(productId)
    if not product then
        return
    end

    Shop.GiveReward(player.unit, productId, math_floor(amount / product.price))
end)

return Shop
