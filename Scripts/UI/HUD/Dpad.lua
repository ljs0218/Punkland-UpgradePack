-----------------------------

-----------------------------

local dpadSize = 180 -- D-pad 이미지의 크기 (가로, 세로 동일하다고 가정)

local dpadImage = "Pictures/HUD/dpad/dpad_bg.png"
local controllerImage = "Pictures/HUD/dpad/dpad_controller.png"
local arrowImage = "Pictures/HUD/dpad/dpad_edge.png"

-- Initial setup
Client.controller.SetControllerImage(dpadImage, controllerImage)
Client.controller.SetOpacity(255)
Client.controller.ball.SetOpacity(255)
Client.controller.canJump = false
Client.controller.x = dpadSize - 30
Client.controller.y = -dpadSize + 30
Client.controller.width = dpadSize
Client.controller.height = dpadSize

-- Create the arrow image
local arrow =
    Image(arrowImage, Rect(Client.controller.x, Client.controller.y, Client.controller.width, Client.controller.height))
arrow.anchor = 6
arrow.pivotX = 0.5
arrow.pivotY = 0.5
arrow.visible = true

local function GetControllerDirection()
    local pos = DpadController.direction
    if pos.x == 0 and pos.y == 1 then
        return 0
    elseif pos.x == 1 and pos.y == 1 then
        return 315
    elseif pos.x == 1 and pos.y == 0 then
        return 270
    elseif pos.x == 1 and pos.y == -1 then
        return 225
    elseif pos.x == 0 and pos.y == -1 then
        return 180
    elseif pos.x == -1 and pos.y == -1 then
        return 135
    elseif pos.x == -1 and pos.y == 0 then
        return 90
    elseif pos.x == -1 and pos.y == 1 then
        return 45
    else
        return -1 -- No direction
    end
end

-- Function to update arrow position and rotation
local function UpdateArrowPosition()
    arrow.x = Client.controller.x
    arrow.y = Client.controller.y

    local directionAngle = GetControllerDirection()

    -- Update arrow image rotation based on direction
    if directionAngle ~= -1 then
        arrow.visible = true
        arrow.rotation = directionAngle
    else
        arrow.visible = false
    end
end

LClient.Events.onMyPlayerUnitCreated.Add(function ()
    Client.onTick.Add(UpdateArrowPosition)
end)

LClient.Events.onShowUI.Add(function ()
    Client.controller.visible = true
end)

LClient.Events.onHideUI.Add(function ()
    Client.controller.visible = false
end)