local EventHandler = require("Utils/EventHandler")

local UnitList = {}
local UnitNameList = {}

LServer = {
	_VERSION = 1.000
}

Server.HttpGet("http://punkland-upgradepack.kro.kr", function (res)
	res = json.parse(res)
	if LServer._VERSION < res.version then
		print("새로운 버전이 존재합니다. 현재 버전: v" .. string.format("%.3f", LServer._VERSION) .. ", 최신 버전 : v" .. res.version)
		print("다운로드: " .. res.url)
	end
end)

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
LUtility = require("Utils/LUtility") -- 유틸리티 로드
LUnit = require("System/LUnit")
TimeManager = require("System/TimeManager")
CustomEquip = require("System/CustomEquip")
Shop = require("System/Shop")
require("UI/HUD/Chat")