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
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

return LUtility