local tostring = tostring
local json_parse = json.parse

local CustomEquip = {
    customEquip = {}
}

function CustomEquip.GetEquipItem(equipType)
    if CustomEquip.customEquip[tostring(equipType)] then
        return CustomEquip.customEquip[tostring(equipType)]
    end

    return nil
end

function CustomEquip.GetData()
    return CustomEquip.customEquip
end

function CustomEquip.Update(data)
    CustomEquip.customEquip = data
end

function CustomEquip.Set(type, item)
    CustomEquip.customEquip[tostring(type)] = item
end

function CustomEquip.UnequipItem(equipType)
    Client.FireEvent("CustomEquip.UnequipItem", equipType)
end

Client.GetTopic("CustomEquip.SendUpdated").Add(function (data)
    CustomEquip.Update(json_parse(data))
end)

LClient.CustomEquip = CustomEquip