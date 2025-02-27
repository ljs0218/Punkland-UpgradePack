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

return LUtility