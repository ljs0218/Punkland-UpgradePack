local CURRENCY_DATA = Utility.JSONParseFromFile("Currency.json")

local Currency = {}

function Currency.Get(currencyId)
    return CURRENCY_DATA[currencyId]
end

function Currency.GetAmount(currencyId)
    return 500000
end

return Currency