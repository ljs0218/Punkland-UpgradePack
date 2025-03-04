local LServer_GetUnitId = LServer.GetUnitId
local json_serialize = json.serialize

-- 유틸리티 함수를 정의합니다.
local function fireChatEvent(unit, name, text, type, serialize)
    unit.FireEvent("AddChat", json_serialize({name = name, text = text, type = type}), serialize)
end

local function sendErrorMessage(unit, message)
    fireChatEvent(unit, "", message, nil, true)
    unit.SendCenterLabel(message)
end

-- SayCallback 채팅시 발생하는 콜백 이벤트입니다.
Server.sayCallback = function(player, text, sayType, targetPlayerID)
    local unit = player.unit
    local targetUnit = (sayType == 2 or sayType == 3) and LServer.GetUnitId(targetPlayerID) or nil

    local textLen = string.len(text) -- 이모티콘
    local isEmote = (textLen <= 3 and string.sub(text, 1, 1) == "!") and true or false
    if isEmote then
        return true
    end

    if sayType == 0 then -- 근처
        for _, pu in pairs(unit.field.playerUnits) do
            fireChatEvent(pu, player.name, text, sayType, true)
        end
        return true
    elseif sayType == 1 then -- 전체
        Server.FireEvent("AddChat", json_serialize({name = player.name, text = text, type = sayType}), true)
        return true
    elseif sayType == 2 or sayType == 3 then -- 귓속말
        if not targetUnit then
            sendErrorMessage(unit, "접속중이지 않은 플레이어입니다.")
        else
            fireChatEvent(unit, player.name .. ">" .. targetUnit.player.name, text, sayType, true)
            fireChatEvent(targetUnit, player.name .. ">" .. targetUnit.player.name, text, sayType, true)
        end
    elseif sayType == 4 or sayType == 5 then -- 클랜
        if not player.clan then
            sendErrorMessage(unit, "소속된 클랜이 없습니다.")
        else
            for _, p in pairs(Server.players) do
                if p.clan and p.clan.id == player.clan.id then
                    fireChatEvent(p.unit, player.name, text, sayType, true)
                end
            end
        end
    elseif sayType == 6 then -- 파티
        if not unit.party then
            sendErrorMessage(unit, "소속된 파티가 없습니다.")
        else
            for _, p in pairs(unit.party.players) do
                fireChatEvent(p.unit, player.name, text, sayType, true)
            end
        end
    end
    return false
end
