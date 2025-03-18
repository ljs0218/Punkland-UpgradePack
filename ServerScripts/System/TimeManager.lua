local EventHandler = require("Utils/EventHandler")

local DAILY_CHECK = LServer.VAR.INTEGER.DAILY_CHECK
local WEEKLY_CHECK = LServer.VAR.INTEGER.WEEKLY_CHECK
local MONTHLY_CHECK = LServer.VAR.INTEGER.MONTHLY_CHECK
local YEARLY_CHECK = LServer.VAR.INTEGER.YEARLY_CHECK

LServer.Events.onDailyCheck = EventHandler:new()
LServer.Events.onWeeklyCheck = EventHandler:new()
LServer.Events.onMonthlyCheck = EventHandler:new()
LServer.Events.onEverySecond = EventHandler:new()
LServer.Events.onEvery10Seconds = EventHandler:new()

local TimeManager = {}

function TimeManager.GetNowTime()
    return os.time() + 32400
end

function TimeManager.GetDailyDate(unit)
    return unit.GetVar(DAILY_CHECK)
end

function TimeManager.GetWeeklyDate(unit)
    return unit.GetVar(WEEKLY_CHECK)
end

function TimeManager.GetMonthlyDate(unit)
    return unit.GetVar(MONTHLY_CHECK)
end

function TimeManager.GetYearlyDate(unit)
    return unit.GetVar(YEARLY_CHECK)
end

-- 주차 계산 함수
local function getWeekNumber(now)
    local firstDayOfYear = os.time { year = now.year, month = 1, day = 1 }
    local firstDayOfWeek = os.date("*t", firstDayOfYear).wday
    local yday = now.yday

    -- 월요일을 기준으로 주차 계산 (일요일이 첫날이면 한 주 뒤로 조정)
    local offset = (firstDayOfWeek == 1) and 1 or 2
    return math.ceil((yday + firstDayOfWeek - offset) / 7)
end


-- 출석체크
function TimeManager.CheckIn(unit)
    -- 한국 시간
    local now = os.date("*t", TimeManager.GetNowTime())
    local daily = TimeManager.GetDailyDate(unit)
    local weekly = TimeManager.GetWeeklyDate(unit)
    local monthly = TimeManager.GetMonthlyDate(unit)
    local yearly = TimeManager.GetYearlyDate(unit)

    if daily ~= now.yday or yearly ~= now.year then
        unit.SetVar(DAILY_CHECK, now.yday)
        unit.SetVar(YEARLY_CHECK, now.year)
        LServer.Events.onDailyCheck:Fire(unit)
    end

    local currentWeek = getWeekNumber(now)
    if weekly ~= currentWeek or yearly ~= now.year then
        unit.SetVar(WEEKLY_CHECK, currentWeek)
        unit.SetVar(YEARLY_CHECK, now.year)
        LServer.Events.onWeeklyCheck:Fire(unit)
    end

    if monthly ~= now.month or yearly ~= now.year then
        unit.SetVar(MONTHLY_CHECK, now.month)
        unit.SetVar(YEARLY_CHECK, now.year)
        LServer.Events.onMonthlyCheck:Fire(unit)
    end
end

Server.onJoinPlayer.Add(function(player)
    TimeManager.CheckIn(player.unit)
end)

local t1 = 0
local t2 = 0
Server.onTick.Add(function (delta)
    t1 = t1 + delta
    t2 = t2 + delta
    if t1 >= 10 then
        t1 = 0
        LServer.Events.onEvery10Seconds:Fire()
    end

    if t2 >= 1 then
        t2 = 0
        LServer.Events.onEverySecond:Fire()
    end
end)

LServer.Events.onEverySecond:Add(function()
    for _, player in pairs(Server.players) do
        player.unit.FireEvent("TimeManager:ServerTime", os.time())
    end
end)

LServer.Events.onEvery10Seconds:Add(function()
    for _, player in pairs(Server.players) do
        TimeManager.CheckIn(player.unit)
    end
end)

return TimeManager