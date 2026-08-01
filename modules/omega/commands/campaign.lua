-----------------------------------
-- !campaign start|stop|status
-- Operates on the Campaign controller registered for the GM's current zone.
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's',
}

local function getController(player)
    if not xi.omegaCampaign or not xi.omegaCampaign.controllers then
        return nil
    end

    return xi.omegaCampaign.controllers[player:getZoneID()]
end

commandObj.onTrigger = function(player, action)
    local controller = getController(player)
    if not controller then
        player:printToPlayer('This zone does not have an Omega Campaign controller.')
        return
    end

    action = string.lower(action or 'status')

    if action == 'start' then
        local ok, message = controller.startBattle(true)
        player:printToPlayer(message or (ok and 'Campaign started.' or 'Campaign could not start.'))
    elseif action == 'stop' then
        local ok, message = controller.stopBattle(false)
        player:printToPlayer(message or (ok and 'Campaign stopped.' or 'Campaign could not stop.'))
    elseif action == 'status' then
        player:printToPlayer(controller.status())
    else
        player:printToPlayer('Usage: !campaign start|stop|status')
    end
end

return commandObj
