-----------------------------------
-- Zone: Sauromugue_Champaign_[S] (98)
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    xi.voidwalker.zoneOnInit(zone)
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(-104, -25.36, -410, 195)
    end

    return cs
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
    if csid == 700 then
        -- TEMPORARY TEST-ONLY: real captured values from Tairneanach's session,
        -- Sauromugue Champaign [S]. Confirms/denies the missing onEventUpdate
        -- theory for WOTG mission 2 (Back to the Beginning)'s crash-land scene.
        -- Remove once confirmed and properly wired into the mission file itself.
        player:updateEvent(2, 23, 1747, 0, 298038, 16795784, 0, 0)
    end
end

zoneObject.onEventFinish = function(player, csid, option)
end

return zoneObject