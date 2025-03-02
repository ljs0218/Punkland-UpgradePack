local CURRENCY_DATA = Utility.JSONParseFromFile("Currency.json")

local tostring = tostring
local json_parse = json.parse

local Currency = {}

function Currency.Get(currencyId)
    return CURRENCY_DATA[currencyId]
end

function Currency.GetPath(currencyId)
    return "Pictures/Currency/" .. currencyId .. ".png"
end

function Currency.GetAmount(currencyId)
    local currency = Currency.Get(currencyId)
    if not currency then
        return
    end

    if currency.type == "cube" then
        return Client.myPlayerUnit.cashMoney
    elseif currency.type == "gameMoney" then
        return Currency.data.gameMoney
    elseif currency.type == "item" then
        return Client.myPlayerUnit.GetItemCount(currency.dataID)
    elseif currency.type == "var" then
        if not Currency.data.varDatas[tostring(currency.dataID)] then
            return 0
        end

        return Currency.data.varDatas[tostring(currency.dataID)]
    end

    return 500000
end

Client.GetTopic("Currency.Update").Add(function (data)
    local success, data = pcall(json_parse, data)
    if not success then
        return
    end

    Currency.data = data
end)

LClient.Events.onEverySecond:Add(function ()
    Client.FireEvent("Currency.Get")
end)

return Currency