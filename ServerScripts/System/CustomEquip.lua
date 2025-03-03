local type = type
local pairs = pairs
local ipairs = ipairs
local assert = assert
local tostring = tostring
local json_parse = json.parse
local json_serialize = json.serialize
local Server_GetItem = Server.GetItem
local Server_CreateItem = Server.CreateItem

local CUSTOM_EQUIP_VAR = LServer.VAR.STRING.CUSTOM_EQUIP
local CUSTOM_EQUIP_DATA = Utility.JSONParseFromFile("CustomEquip.json")

--- 커스텀 장비 관련 함수를 모아둔 클래스입니다.
local CustomEquip = {}

--- @param dataID number
function CustomEquip.GetItemData(dataID)
    assert(type(dataID) == "number")

    return CUSTOM_EQUIP_DATA.items[tostring(dataID)]
end

--- @param unit Commons.Server.Scripts.ScriptUnit
function CustomEquip.GetUnitData(unit)
    if not unit then
        return nil
    end

    if unit.customData.customEquip then
        return unit.customData.customEquip
    end

    local success, data = pcall(json_parse, unit.GetStringVar(CUSTOM_EQUIP_VAR))
    if success then
        unit.customData.customEquip = data
        return data
    end

    unit.customData.customEquip = {}
    return unit.customData.customEquip
end

--- @param unit Commons.Server.Scripts.ScriptUnit
--- @param titem network.TItem
function CustomEquip.EquipItem(unit, titem)
    local unitData = CustomEquip.GetUnitData(unit)
    if not unitData then
        return false
    end

    local itemData = CustomEquip.GetItemData(titem.dataID)
    if not itemData then
        return false
    end

    local typeStr = tostring(itemData.type)

    -- 이미 장착된 아이템이 있을 경우
    if unitData[typeStr] then
        CustomEquip.UnequipItem(unit, itemData.type, false)
        unitData = CustomEquip.GetUnitData(unit) -- 장착된 아이템이 제거되었으므로 다시 가져옴
    end

    unitData[typeStr] = {
        dataID = titem.dataID,
        count = titem.count,
        level = titem.level,
        exp = titem.exp,
        index = titem.index,
        inTrade = titem.inTrade,
        locked = titem.locked,
        tag = titem.tag,
        options = LUtility.OptionsToArray(titem.options),
    }

    unit.RemoveItemByID(titem.id, 1, false)
    CustomEquip.Save(unit, unitData)

    unit.FireEvent("CustomEquip.EquipItem", itemData.type, json_serialize(unitData[typeStr]))

    return true
end

--- @param unit Commons.Server.Scripts.ScriptUnit
--- @param equipType number
function CustomEquip.UnequipItem(unit, equipType, isSave)
    local unitData = CustomEquip.GetUnitData(unit)
    if not unitData then
        return false
    end

    local titem = unitData[tostring(equipType)]
    if not titem then -- 장착된 아이템이 없을 경우
        return false
    end

    local _titem = Server_CreateItem(titem.dataID, titem.count)
    _titem.level = titem.level
    _titem.exp = titem.exp
    _titem.index = titem.index
    _titem.inTrade = titem.inTrade
    _titem.locked = titem.locked
    _titem.tag = titem.tag
    LUtility.AddOptionsFromArray(_titem, titem.options)

    unit.AddItemByTItem(_titem, false)

    unitData[tostring(equipType)] = nil
    if isSave then
        CustomEquip.Save(unit, unitData)
        unit.FireEvent("CustomEquip.UnequipItem", equipType)
        return true
    end

    return true
end

function CustomEquip.Save(unit, unitData)
    unitData = unitData or CustomEquip.GetUnitData(unit)
    unit.SetStringVar(CUSTOM_EQUIP_VAR, json_serialize(unitData))

    CustomEquip.RefreshStats(unit)
    unit.RefreshStats()
end

function CustomEquip.RefreshStats(unit)
    local unitData = CustomEquip.GetUnitData(unit)
    if not unitData then
        return
    end

    local stats = {}
    for equipType, titem in pairs(unitData) do
        local statPlus = LUtility.Item.GetStats(titem.dataID, titem.level, 2)
    
        local optionStats = {}
        if #titem.options > 0 then
            for _, option in ipairs(titem.options) do
                if not optionStats[option.statID] then
                    optionStats[option.statID] = {}
                end
                
                if not optionStats[option.statID][option.type] then
                    optionStats[option.statID][option.type] = 0
                end
                
                optionStats[option.statID][option.type] = optionStats[option.statID][option.type] + option.value
            end
        end
        
        for statID, option in pairs(optionStats) do
            local addStat = option[1] or 0
            local addItemPlusStat = option[3] or 0
            local addItemPercentStat = option[4] or 0
    
            local statPlusOption = (addStat + addItemPlusStat) + (statPlus[statID] * (addItemPercentStat * 0.01))
            stats[tostring(statID)] = statPlusOption + statPlus[statID]
        end
    end

    unit.customData.stats.customEquip = stats
end

function CustomEquip.SendUpdated(unit)
    unit.FireEvent(
        "CustomEquip.SendUpdated",
        json_serialize(CustomEquip.GetUnitData(unit))
    )
end

--- @param unit Commons.Server.Scripts.ScriptUnit
--- @param titem network.TItem
Server.onEquipItem.Add(function(unit, titem)
    local gameItem = Server_GetItem(titem.dataID)
    if gameItem.type ~= 7 then
        return
    end

    local data = CustomEquip.GetItemData(titem.dataID)
    if data then -- 커스텀 장비 데이터가 존재 할 경우
        if CustomEquip.EquipItem(unit, titem) then
            return
        end
    end

    unit.SendCenterLabel("이 아이템은 장착할 수 없습니다.")
    unit.UnequipItem(titem.id)
end)

Server.GetTopic("CustomEquip.UnequipItem").Add(function(equipType)
    CustomEquip.UnequipItem(unit, equipType, true)
end)

Server.onJoinPlayer.Add(function (player)
    CustomEquip.RefreshStats(player.unit)
end)

-- TODO: CustomEquip 스텟 계산 추가

LServer.Events.onMyPlayerUnitCreated:Add(CustomEquip.SendUpdated) -- 유닛 생성 시 장비 정보 전송

LServer.CustomEquip = CustomEquip
