LClient = {}

-- 클라이언트의 이벤트들이 저장되는 테이블
LClient.Events = {
    -- myPlayerUnit 객체가 생성되었을 때 발생하는 이벤트
    onMyPlayerUnitCreated = EventPublisher(),
    -- UI가 화면에 표시될 때 발생하는 이벤트
    onShowUI = EventPublisher(),
    -- UI가 화면에서 사라질 때 발생하는 이벤트
    onHideUI = EventPublisher(),
    onKeyDown = EventPublisher(),
    onEverySecond = EventPublisher(),
}

local function checkCreateUnit() -- myPlayerUnit 객체가 생성되었는지 확인하는 함수
    if Client.myPlayerUnit then
        LClient.Events.onMyPlayerUnitCreated.Call() -- myPlayerUnit 객체가 생성되면 이벤트 발생
        Client.onTick.Remove(checkCreateUnit)
    end
end
Client.onTick.Add(checkCreateUnit)

LClient.Events.onMyPlayerUnitCreated.Add(function () -- myPlayerUnit 객체가 생성되면 서버에 이벤트 발생
    Client.FireEvent("LClient.onMyPlayerUnitCreated")
end)

-- Client Config 로드
local ClientConfig = require("Config/Client") -- Config 로드
LClient.Config = ClientConfig -- UI 설정 로드

-- Constants(상수) 로드
require("Constants/UI") -- UI 상수 로드
require("Constants/Stat") -- Stat 상수 로드

-- 스크립트 로드
CustomEquip = require("System/CustomEquip")
KeyManager = require("System/KeyManager")
TimeManager = require("System/TimeManager")
require("System/DamageCallback")
Currency = require("System/Currency")
Shop = require("System/Shop")

UIManager = require("UI/UIManager") -- UI 매니저 로드

LUtility = require("Utils/LUtility") -- 유틸리티 로드

Client.resolution = ClientConfig.Client.resolution
Camera.orthographicSize = ClientConfig.Client.orthographicSize

Client.controller.canJump = ClientConfig.Player.canJump
Camera.offsetY = ClientConfig.Player.offsetY
Camera.movementType = ClientConfig.Player.movementType

ScreenUI.menuButtonVisible = false
ScreenUI.noticeButtonVisible = false
ScreenUI.cubeShopButtonVisible = false
ScreenUI.menuVisible = false
ScreenUI.bagVisible = false
ScreenUI.myProfileButtonVisible = false
ScreenUI.popupGameSettingsEnable = false
ScreenUI.hpBarVisible = false
ScreenUI.mpBarVisible = false
ScreenUI.expBarVisible = false
ScreenUI.levelVisible = false
ScreenUI.gameMoneyVisible = false