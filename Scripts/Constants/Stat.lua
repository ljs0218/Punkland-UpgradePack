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

function Stat.GetName(statID)
    local statKey = statKeys[statID]
    if not statKey and statID > 100 then
        statKey = "custom" .. tostring(statID - 100)
    end
    return strings[statKey]
end
