local strings = Client.GetStrings()

local statKeys = {
    [0] = "attack",
    [1] = "defense",
    [2] = "magicattack",
    [3] = "magicdefense",
    [4] = "agility",
    [5] = "lucky",
    [6] = "hp",
    [7] = "mp"
}

Stat = {
    ATK = 0,
    DEF = 1,
    MAGIC_ATK = 2,
    MAGIC_DEF = 3,
    MAX_HP = 4,
    MAX_MP = 5
}

function Stat.GetKey(statID)
    local statKey = statKeys[statID]
    if not statKey and statID > 100 then
        statKey = "custom" .. tostring(statID - 100)
    end

    return statKey
end

function Stat.GetName(statID)
    local statKey = Stat.GetKey(statID)
    return strings[statKey]
end

function Stat.GetId(name)
    for id, key in pairs(statKeys) do
        if key == name then
            return id
        end
    end
    if string.sub(name, 1, 6) == "custom" then
        local customId = tonumber(string.sub(name, 7))
        if customId then
            return customId + 100
        end
    end
    return nil
end