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

function Item.ParseDesc(titem, desc)
    local statPlus = Item.GetStats(titem.dataID, titem.level, 2)
    local statPercent = Item.GetStats(titem.dataID, titem.level, 0)

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
    
    local statPlusOption = {}
    local statPlusTotal = {}
    for statID, option in pairs(optionStats) do
        --[[
            1: 직업 스탯 (+) ADD_STAT
            2: 직업 스탯 (%) ADD_PERCENT_STAT
            3: 아이템 스탯 (+) ADD_ITEM_PLUS_STAT
            4: 아이템 스탯 (%) ADD_ITEM_PERCENT_STAT
        ]]
        local addStat = option[1] or 0
        local addPercentStat = option[2] or 0
        local addItemPlusStat = option[3] or 0
        local addItemPercentStat = option[4] or 0

        statPlusOption[statID] = (addStat + addItemPlusStat) + (statPlus[statID] * (addItemPercentStat / 100))
        statPlusTotal[statID] = statPlusOption[statID] + statPlus[statID]

        desc = string.gsub(desc, "{{" .. Stat.GetKey(statID) .. "PlusOption}}", statPlusOption[statID])
        desc = string.gsub(desc, "{{" .. Stat.GetKey(statID) .. "PlusTotal}}", statPlusTotal[statID])
    end
    
    for statID, value in pairs(statPlus) do
        desc = string.gsub(desc, "{{" .. Stat.GetKey(statID) .. "Plus}}", value)
    end
    
    for statID, value in pairs(statPercent) do
        desc = string.gsub(desc, "{{" .. Stat.GetKey(statID) .. "Percent}}", value)
    end


    return desc
end

local LUtility = {}

function LUtility.OptionsToText(options)
    if not options then
        return ""
    end

    if #options == 0 then
        return ""
    end

    local text = "<color=#F002F0>옵션</color>"

    for i, option in ipairs(options) do
        local prefix = "\n<color=#00FCFC>"
        if option.type == 4 then
            prefix = prefix .. "아이템 "
        end

        local suffix = ""
        if option.type == 2 or option.type == 4 then
            suffix = "%"
        end

        text = text .. string.format("%s%s +%d%s</color>", prefix, Stat.GetName(option.statID), option.value, suffix)
    end
    return text
end

function LUtility.FormatNumber(n)
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

LUtility.Item = Item

return LUtility
