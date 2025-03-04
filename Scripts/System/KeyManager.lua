local Input = Input
local onKeyDown = LClient.Events.onKeyDown

local string_len = string.len
local string_sub = string.sub
local string_lower = string.lower

local function fireEvent(key)
    -- 소문자로 변환하여 이벤트 발생
    onKeyDown:Fire(string_lower(key))
end

Client.onTick.Add(function()
    if Input.anyKeyDown then -- 아무 키나 눌렀을 때
        local inputString = Input.inputString
        if inputString == "" then
            if Input.GetKeyDown(Input.KeyCode.Escape) then
                fireEvent("esc")
            end

            return
        end

        local len = string_len(inputString)

        if len > 1 then
            for i = 1, len do
                fireEvent(string_sub(inputString, i, i))
            end
        else
            fireEvent(inputString)
        end
    end
end)
