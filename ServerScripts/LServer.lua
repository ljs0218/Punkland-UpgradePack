local EventHandler = require("Utils/EventHandler")

local UnitList = {}
local UnitNameList = {}

LServer = {}

LServer.Events = {
    onMyPlayerUnitCreated = EventHandler:new(),
}

--- @param id number
--- 유닛 ID로 유닛을 가져옵니다.
LServer.GetUnitId = function(id)
	return UnitList[id]
end

--- @param name string
-- 유닛 이름으로 유닛을 가져옵니다.
LServer.GetUnitFromName = function(name)
	return UnitNameList[name]
end

--- @param player Commons.Server.Scripts.ScriptRoomPlayer
Server.onJoinPlayer.Add(function(player)
	local u = player.unit
	UnitList[player.id] = u
	UnitNameList[player.name] = u
end)

--- @param player Commons.Server.Scripts.ScriptRoomPlayer
Server.onLeavePlayer.Add(function(player)
	UnitList[player.id] = nil
	UnitNameList[player.name] = nil
end)

Server.GetTopic("LClient.onMyPlayerUnitCreated").Add(function()
	LServer.Events.onMyPlayerUnitCreated:Fire(unit)
end)

-- Constants(상수) 로드
LServer.VAR = require("Constants/Var") -- UI 상수 로드

-- 스크립트 로드
TimeManager = require("System/TimeManager")
CustomEquip = require("System/CustomEquip")
require("UI/HUD/Chat")
LUtility = require("Utils/LUtility") -- 유틸리티 로드