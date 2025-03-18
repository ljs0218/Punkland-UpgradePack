local type = type
local pairs = pairs
local ipairs = ipairs
local assert = assert
local tonumber = tonumber
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

--- @param equipType number
function CustomEquip.GetSlotIds(equipType)
    local slotIds = {}

    local slots = CUSTOM_EQUIP_DATA.slots
    for slotId, _equipType in pairs(slots) do
        if _equipType == equipType then
            table.insert(slotIds, slotId)
        end
    end

    return slotIds
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

    local slotIds = CustomEquip.GetSlotIds(itemData.type)

    local function SetEquip(slotId)
        unitData[slotId] = {
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
    end

    local selectedSlotId = nil
    local isEquip = false
    for _, slotId in ipairs(slotIds) do
        -- 장착된 아이템이 존재하지 않을 경우 해당 슬롯에 장착 처리
        if not unitData[slotId] then
            SetEquip(slotId)
            selectedSlotId = slotId
            isEquip = true
            break
        end
    end
    
    if not isEquip then -- 장비 장착에 실패했을 경우
        -- 첫 번째 슬롯에 강제 장착
        local slotId = slotIds[1]
        CustomEquip.UnequipItem(unit, slotId, false)
        unitData = CustomEquip.GetUnitData(unit) -- 장착된 아이템이 제거되었으므로 다시 가져옴
        
        SetEquip(slotId)

        selectedSlotId = slotId
    end

    unit.RemoveItemByID(titem.id, 1, false)
    CustomEquip.Save(unit, unitData)

    unit.FireEvent("CustomEquip.EquipItem", tonumber(selectedSlotId), json_serialize(unitData[selectedSlotId]))

    return true
end

--- @param unit Commons.Server.Scripts.ScriptUnit
--- @param slotId number
function CustomEquip.UnequipItem(unit, slotId, isSave)
    local unitData = CustomEquip.GetUnitData(unit)
    if not unitData then
        return false
    end

    local titem = unitData[tostring(slotId)]
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

    unitData[tostring(slotId)] = nil
    if isSave then
        CustomEquip.Save(unit, unitData)
        unit.FireEvent("CustomEquip.UnequipItem", slotId)
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
    for slotId, titem in pairs(unitData) do
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

Server.GetTopic("CustomEquip.UnequipItem").Add(function(slotId)
    CustomEquip.UnequipItem(unit, slotId, true)
end)

Server.onJoinPlayer.Add(function (player)
    CustomEquip.RefreshStats(player.unit)
end)

LServer.Events.onMyPlayerUnitCreated:Add(CustomEquip.SendUpdated) -- 유닛 생성 시 장비 정보 전송

LServer.CustomEquip = CustomEquip
