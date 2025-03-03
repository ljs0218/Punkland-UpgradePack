local ipairs = ipairs

local traitData = Utility.JSONParseFromFile("ItemTrait.json")

--[[
    스텟 타입
    0 = + n% 증가
    1 = * n% 증가
    2 = + n 증가
    3 = * n 증가
]]

local function GetTraitData(dataID)
    return traitData[tostring(dataID)]
end

local Item = {}

--- @param dataID number
--- @param level number
--- @param type number
--- @return table
function Item.GetStats(dataID, level, type)
    local data = GetTraitData(dataID)
    if not (data and data.options) then
        return {}
    end

    local stats = {}
    for _, option in ipairs(data.options) do
        if option.level <= level and option.type == type then
            if not stats[option.statID] then
                stats[option.statID] = 0
            end

            stats[option.statID] = stats[option.statID] + option.value
        end
    end

    return stats
end

--- @param dataID number
--- @return number
function Item.GetLimitLevel(dataID)
    local data = GetTraitData(dataID)
    if not data then
        return 0
    end

    return data.limitLevel
end

--- @param dataID number
--- @return table
function Item.GetLimitJobs(dataID)
    local data = GetTraitData(dataID)
    if not data then
        return {}
    end

    return data.limitJobs
end

local LUtility = {}

function LUtility.OptionsToArray(options)
    local array = {}
    for i, option in ipairs(options) do
        array[i] = {
            type = option.type,
            statID = option.statID,
            value = option.value
        }
    end
    return array
end

function LUtility.AddOptionsFromArray(titem, options)
    for i, option in ipairs(options) do
        Utility.AddItemOption(titem, option.type, option.statID, option.value)
    end
end

LUtility.Item = Item

return LUtility