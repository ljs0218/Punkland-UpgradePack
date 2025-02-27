-------------------------------------------------
-- <굿굿 게이지바> by domin2
-------------------------------------------------
-- 1= HP 강조 좌측상단
-- 2= HP 강조 중앙하단
-- 3= HP+MP 좌측상단
-- 4= HP+MP 중앙하단
local gage_type = 1
local gage_size = 240  -- 가로 사이즈만 조절 가능
local text_type = 1    -- 1= 수치, 2= 퍼센트
local txt_align = 4    -- 3= 왼쪽, 4=중앙, 5=오른쪽 (HP,MP 텍스트 위치)
-------------------------------------------------
local power_use = true -- 전투력 사용 유무, 사용을 true로 하려면, 서버스크립트 폴더에 UI_Gage_ver2_server 파일이 필요 합니다.
-------------------------------------------------

local function getPower()
    local me = Client.myPlayerUnit

    local atk = me.GetStat(Stat.ATK)
    local def = me.GetStat(Stat.DEF)
    local magicAtk = me.GetStat(Stat.MAGIC_ATK)
    local magicDef = me.GetStat(Stat.MAGIC_DEF)

    local maxHP = me.GetStat(Stat.MAX_HP)
    local maxMP = me.GetStat(Stat.MAX_MP)

    local power = atk + def + magicAtk + magicDef + (maxHP + maxMP) / 10
    return power, atk, def
end

-- 이미지 생성 함수
local function createGaugeImage(filePath, rect, isAnchorCenter)
    local image = Image(filePath, rect)
    if isAnchorCenter then
        image.anchor = 7
        image.pivotX = 0.5
    else
        image.anchor = 0
    end
    return image
end

-- 게이지 위치 및 크기 설정
local includeMP = gage_type > 2
local isCenterBottom = gage_type == 2 or gage_type == 4
local gaugeX = not isCenterBottom and 10 or 0
local gaugeHeight = includeMP and 35 or 26
local yPos = isCenterBottom and -86 or 10 - gage_type * 2
local mpGaugeHeight = includeMP and 16 or 6
local mpYPosition = 19

-- 게이지 이미지 생성
local HPbg =
    createGaugeImage(
        "Pictures/HUD/gage/HP_MP_bg.png",
        Rect(gaugeX, yPos, gage_size + 2, gaugeHeight - mpGaugeHeight - 1),
        isCenterBottom
    )
local MPbg =
    createGaugeImage(
        "Pictures/HUD/gage/HP_MP_bg.png",
        Rect(gaugeX, yPos + HPbg.height, gage_size + 2, mpGaugeHeight + 2),
        isCenterBottom
    )

local HP = createGaugeImage("Pictures/HUD/gage/HP.png", Rect(1, 1, gage_size, 17), false)
local MP = createGaugeImage("Pictures/HUD/gage/MP.png", Rect(1, 1, gage_size, mpGaugeHeight), false)

local HP2 = Panel(Rect(1, 1, HP.width, HP.height))
local MP2 = Panel(Rect(1, 1, MP.width, MP.height))
HP2.color = Color(255, 255, 255, 200)
MP2.color = Color(255, 255, 255, 200)

local HP_edge = createGaugeImage("Pictures/HUD/gage/hp_bar_edge.png", Rect(HP.width / 2, 0, HP.width / 2, HP.height), false)
local MP_edge = createGaugeImage("Pictures/HUD/gage/mp_bar_edge.png", Rect(MP.width / 2, 0, MP.width / 2, MP.height), false)

-- XP 게이지 설정
local XPbg = createGaugeImage("Pictures/HUD/gage/exp_bar_bg.png", Rect(0, -5, Client.width, 5), false)
local XP = createGaugeImage("Pictures/HUD/gage/XP.png", Rect(0, 0, Client.width, 5), false)
local XP_edge = createGaugeImage("Pictures/HUD/gage/exp_bar_edge.png", Rect(XP.width - 50, 0, 50, XP.height), false)
XPbg.anchor = 6

-- 게이지에 자식 추가
HPbg.AddChild(HP2)
MPbg.AddChild(MP2)
HPbg.AddChild(HP)
MPbg.AddChild(MP)
XPbg.AddChild(XP)

HP.AddChild(HP_edge)
MP.AddChild(MP_edge)
XP.AddChild(XP_edge)

-- 숫자 3자리마다 , 찍기
function C_commaValue(n)
    local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")

    return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end

-- 텍스트 설정 함수
local function createText(rect, anchor, textSize, textAlign)
    local text = Text("", rect)
    text.borderDistance = Point(1, 1)
    text.borderEnabled = true
    text.anchor = anchor
    text.textAlign = textAlign
    text.textSize = textSize
    text.color = Color(255, 249, 234)
    return text
end

-- 텍스트 생성
local HPtxt = createText(Rect(5, 1, HP.width - 10, HP.height), 0, 12, 4)
local MPtxt = createText(Rect(5, 1, MP.width - 10, MP.height), 0, 12, 4)

HPtxt.textAlign = txt_align
MPtxt.textAlign = txt_align

local XPtxt = createText(Rect(0, -22, 0, 15), 6, 11, 0)
local LVtxt = createText(Rect(0, -45, 60, 45), 6, 28, 4)
local LEVELtxt = createText(Rect(5, -65, 60, 35), 6, 12, 4)
LEVELtxt.text = ""
LVtxt.SetSizeFit(true, true)
XPtxt.SetSizeFit(true, false)
XPtxt.color = Color(255, 215, 142)

local cp = {}

cp.panel = HorizontalPanel(Rect(10, -40, 52, 32))
cp.panel.anchor = 6
cp.panel.spacing = 10
cp.panel.childAlign = 7
cp.panel.SetSizeFit(true, true)
cp.panel.AddChild(LVtxt)

if power_use then -- 전투력 사용시 전투력/공격력/방어력 순으로 보여줌
    cp.power_panel = HorizontalPanel(Rect(0, 0, 0, 0))
    cp.power_panel.spacing = 1
    cp.power_panel.childAlign = 4
    cp.power_panel.SetSizeFit(true, true)
    cp.power_icon = Image("Pictures/HUD/ui_icons/icon_cp.png", Rect(0, 0, 14, 14))
    cp.power_panel.AddChild(cp.power_icon)
    cp.power_text = Text("0", Rect(0, 0, 0, 0))
    cp.power_text.textSize = 11
    cp.power_text.borderDistance = Point(1, 1)
    cp.power_text.borderEnabled = true
    cp.power_text.SetSizeFit(true, true)
    cp.power_panel.AddChild(cp.power_text)
    cp.panel.AddChild(cp.power_panel)

    cp.atk_panel = HorizontalPanel(Rect(0, 0, 0, 0))
    cp.atk_panel.spacing = 1
    cp.atk_panel.childAlign = 4
    cp.atk_panel.SetSizeFit(true, true)
    cp.atk_icon = Image("Pictures/HUD/ui_icons/icon_atk.png", Rect(0, 0, 14, 14))
    cp.atk_panel.AddChild(cp.atk_icon)
    cp.atk_text = Text("0", Rect(0, 0, 0, 0))
    cp.atk_text.textSize = 11
    cp.atk_text.borderDistance = Point(1, 1)
    cp.atk_text.borderEnabled = true
    cp.atk_text.SetSizeFit(true, true)
    cp.atk_panel.AddChild(cp.atk_text)
    cp.panel.AddChild(cp.atk_panel)

    cp.atk_icon.SetOpacity(220)
    cp.atk_text.SetOpacity(220)

    cp.def_panel = HorizontalPanel(Rect(0, 0, 0, 0))
    cp.def_panel.spacing = 1
    cp.def_panel.childAlign = 4
    cp.def_panel.SetSizeFit(true, true)
    cp.def_icon = Image("Pictures/HUD/ui_icons/icon_def.png", Rect(0, 0, 14, 14))
    cp.def_panel.AddChild(cp.def_icon)
    cp.def_text = Text("0", Rect(0, 0, 0, 0))
    cp.def_text.textSize = 11
    cp.def_text.borderDistance = Point(1, 1)
    cp.def_text.borderEnabled = true
    cp.def_text.SetSizeFit(true, true)
    cp.def_panel.AddChild(cp.def_text)
    cp.panel.AddChild(cp.def_panel)

    cp.def_icon.SetOpacity(220)
    cp.def_text.SetOpacity(220)
end

HPbg.AddChild(HPtxt)
MPbg.AddChild(MPtxt)

-- 게이지바와 버프 패널이 겹치지 않도록 조정
ScreenUI.buffPanel.x = not isCenterBottom and gage_size + 80 or 40

-- 업데이트 함수
local function updateGauge()
    local me = Client.myPlayerUnit
    local hpPercent = me.hp / me.maxHP
    local mpPercent = me.mp / me.maxMP
    local xpPercent = me.exp / me.maxEXP

    HP2.DOScale(Point(hpPercent, 1), 0.7)
    MP2.DOScale(Point(mpPercent, 1), 0.7)

    HP.DOScale(Point(hpPercent, 1), 0.2)
    MP.DOScale(Point(mpPercent, 1), 0.2)

    --LVtxt.DOScale(Point(1, 1.05), 0.1)
    if power_use then
        local power, atk, def = getPower()
        cp.power_text.text = C_commaValue(math.floor(power))
        cp.atk_text.text = C_commaValue(atk)
        cp.def_text.text = C_commaValue(def)
        XPtxt.y = -37
    end

    cp.panel.ForceRebuildLayoutImmediate()
    XPtxt.x = LVtxt.width + 20

    HPtxt.text =
        text_type == 1 and string.format("%d / %d", me.hp, me.maxHP) or string.format("%.0f%%", hpPercent * 100)
    MPtxt.text =
        text_type == 1 and string.format("%d / %d", me.mp, me.maxMP) or string.format("%.0f%%", mpPercent * 100)

    -- _edge 이미지 표시 여부 업데이트
    HP_edge.visible = hpPercent < 1
    MP_edge.visible = mpPercent < 1
    XP_edge.visible = xpPercent < 1

    LVtxt.text = "Lv" .. me.level
    if me.maxEXP ~= 0 then
        -- per = string.format("%.4f", "Exp " .. me.exp / me.maxEXP * 100 .. "%")
        XPtxt.text = string.format("%.4f%%", xpPercent * 100)
        XP.DOScale(Point(me.exp / me.maxEXP, 1), 0.5)
    else
        XPtxt.text = "최대 레벨 달성"
        XP.DOScale(Point(1, 1), 0.5)
    end
end

LClient.Events.onMyPlayerUnitCreated:Add(function ()
    Client.onTick.Add(updateGauge)
end)

LClient.Events.onShowUI:Add(function ()
    HPbg.visible = true
    MPbg.visible = true
    HP.visible = true
    MP.visible = true
    cp.panel.visible = true
    XPbg.visible = true
    XPtxt.visible = true
end)

LClient.Events.onHideUI:Add(function ()
    HPbg.visible = false
    MPbg.visible = false
    HP.visible = false
    MP.visible = false
    cp.panel.visible = false
    XPbg.visible = false
    XPtxt.visible = false
end)