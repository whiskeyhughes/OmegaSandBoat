-----------------------------------
-- func: campaign <start|stop|status|eval>
-- desc: Omega Campaign Battle controls
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's'
}

commandObj.onTrigger = function(player, action)
    if not xi.omegaCampaign then
        player:printToPlayer('Omega Campaign module is not loaded.')
        return
    end

    action = string.lower(action or 'status')

    if action == 'start' then
        local _, message = xi.omegaCampaign.startBattle(true)
        player:printToPlayer(message)
    elseif action == 'stop' then
        local _, message = xi.omegaCampaign.stopBattle(false)
        player:printToPlayer(message)
    elseif action == 'eval' then
        xi.omegaCampaign.evaluate(player, true)
    elseif action == 'status' then
        player:printToPlayer(xi.omegaCampaign.status())
    else
        player:printToPlayer('Usage: !campaign <start|stop|status|eval>')
    end
end

return commandObj
