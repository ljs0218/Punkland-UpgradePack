local TimeManager = {}

local serverTime = 0

function TimeManager.GetServerTime()
    return os.time() - serverTime
end

Client.GetTopic("TimeManager:ServerTime").Add(function (time)
    serverTime = time
end)

local function onEverySecond()
    LClient.Events.onEverySecond:Fire()
    Client.RunLater(onEverySecond, 1)
end
onEverySecond()

return TimeManager