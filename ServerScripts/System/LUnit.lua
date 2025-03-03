local LUnit = {}

local tonumber = tonumber

LUnit.Currency = require("System/Currency")

Server.onJoinPlayer.Add(function (player)
    player.unit.customData.stats = {}
end)

Server.onRefreshStats.Add(function (unit)
    for key, stats in pairs(unit.customData.stats) do
        for statId, value in pairs(stats) do
            local statId = tonumber(statId)
            unit.SetStat(statId, unit.GetStat(statId) + value)
        end
    end
end)

return LUnit