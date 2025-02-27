local TimeManager = {}

local serverTime = 0

function TimeManager.GetServerTime()
    return os.time() - serverTime
end

Client.GetTopic("TimeManager:ServerTime").Add(function (time)
    serverTime = time
end)

return TimeManager