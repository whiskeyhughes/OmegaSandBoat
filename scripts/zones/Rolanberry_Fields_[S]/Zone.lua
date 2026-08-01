-----------------------------------
-- Zone: Rolanberry_Fields_[S] (91)
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    xi.voidwalker.zoneOnInit(zone)
    xi.darkixion.zoneOnInit(zone)
end

zoneObject.onGameHour = function(zone)
    xi.darkixion.zoneOnGameHour(zone)
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(-376.179, -30.387, -776.159, 220)
    end

    return cs
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
    if csid == 700 then
        -- TEMPORARY TEST-ONLY: real captured values from Tairneanach's session,
        -- Rolanberry Fields [S]. Confirms/denies the missing onEventUpdate
        -- theory for WOTG mission 2 (Back to the Beginning)'s crash-land scene.
        -- Remove once confirmed and properly wired into the mission file itself.
        player:updateEvent(1, 23, 1749, 0, 0, 5439508, 0, 0)
    end
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

return zoneObject