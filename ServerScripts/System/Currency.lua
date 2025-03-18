local CURRENCY_DATA = Utility.JSONParseFromFile("Currency.json")

local tostring = tostring

local currencyVars = {}
for i, currency in ipairs(CURRENCY_DATA) do
    if currency.type == "var" then
        table.insert(currencyVars, currency.dataID)
    end
end

local Currency = {}

function Currency.Get(currencyId)
    return CURRENCY_DATA[currencyId]
end

--- @param unit Commons.Server.Scripts.ScriptUnit
--- @param currencyId number
--- @param amount number
function Currency.AddAmount(unit, currencyId, amount)
    if not unit then
        return
    end

    local currencyData = Currency.Get(currencyId)
    if currencyData.type == "gameMoney" then
        unit.AddGameMoney(amount)
    elseif currencyData.type == "item" then
        if amount < 0 then
            unit.RemoveItem(currencyData.dataID, amount, false)
        else
            unit.AddItem(currencyData.dataID, amount, false)
        end
    elseif currencyData.type == "var" then
        unit.SetVar(currencyData.dataID, unit.GetVar(currencyData.dataID) + amount)
    end

    Currency.SendUpdated(unit)
end

--- @param unit Commons.Server.Scripts.ScriptUnit
--- @param currencyId number
--- @param amount number
function Currency.GetAmount(unit, currencyId)
    if not unit then
        return 0
    end

    local currencyData = Currency.Get(currencyId)
    if currencyData.type == "gameMoney" then
        return unit.gameMoney
    elseif currencyData.type == "item" then
        return unit.CountItem(currencyData.dataID)
    elseif currencyData.type == "var" then
        return unit.GetVar(currencyData.dataID)
    end
end

--- @param unit Commons.Server.Scripts.ScriptUnit
function Currency.SendUpdated(unit)
    local varDatas = {}
    for _, varId in pairs(currencyVars) do
        varDatas[tostring(varId)] = unit.GetVar(varId)
    end
    
    unit.FireEvent("Currency.Update", json.serialize({
        gameMoney = unit.gameMoney,
        varDatas = varDatas,
    }))
end

LServer.Events.onMyPlayerUnitCreated:Add(Currency.SendUpdated)

Server.GetTopic("Currency.Get").Add(function ()
    Currency.SendUpdated(unit)
end)

return Currency