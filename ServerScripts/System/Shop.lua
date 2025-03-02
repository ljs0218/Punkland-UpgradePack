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
function Shop.GetReward(unit, productId, count)
    -- 상점 보상 지급 제작
    local product = Shop.GetProduct(productId)
    if not product then
        print("ERROR")
        return
    end

    local gameItem = Server_GetItem(product.dataID)
    local titem = Server_CreateItem(product.dataID, count)
    unit.AddItemByTItem(titem, false)
    unit.SendCenterLabel(gameItem.name .. " 아이템을 구매했습니다!")
end

Server.GetTopic("Shop.Buy").Add(function (productId, count)
    assert(type(productId) == "number")

    print("Shop.Buy", productId, count)
end)

--- @param player Commons.Server.Scripts.ScriptRoomPlayer
Server.onBuyItem.Add(function (player, productId, unknown, amount)
    productId = assert(tonumber(productId))

    local product = Shop.GetProduct(productId)
    if not product then
        print("ERROR")
        return
    end
    
    Shop.GetReward(player.unit, productId, math_floor(amount / product.price))
end)

return Shop