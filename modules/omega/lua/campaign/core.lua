-----------------------------------
-- OmegaXI Campaign shared helpers
-----------------------------------

xi.omegaCampaign = xi.omegaCampaign or {}
xi.omegaCampaign.zones = xi.omegaCampaign.zones or {}

local core = xi.omegaCampaign.core or {}
xi.omegaCampaign.core = core

local DEFAULT_TAG_DURATION = 2 * 60 * 60

local function addConfrontationEffect(entity, effectId, battleId, duration)
    if not entity then
        return false
    end

    entity:delStatusEffect(effectId)

    local effectParams =
    {
        power  = battleId,
        origin = entity,
        flag   = xi.effectFlag.ON_ZONE + xi.effectFlag.CONFRONTATION,
    }

    if duration and duration > 0 then
        effectParams.duration = duration
    end

    return entity:addStatusEffect(effectId, effectParams)
end

function core.configureCombatant(entity, battleId, allegiance)
    if not entity then
        return false
    end

    entity:setAllegiance(allegiance)
    entity:setBattleID(battleId)
    entity:setUntargetable(false)

    -- Garrison and Expeditionary Force use LEVEL_RESTRICTION as a harmless
    -- carrier for the CONFRONTATION flag on mobs. Level restriction does not
    -- apply to mobs, while the shared power hooks into normal target checks.
    return addConfrontationEffect(entity, xi.effect.LEVEL_RESTRICTION, battleId)
end

function core.joinBattle(player, battleId, duration)
    if not player then
        return false
    end

    local confrontationId = player:getConfrontationEffect()
    if
        not player:hasStatusEffect(xi.effect.ALLIED_TAGS) or
        confrontationId ~= battleId
    then
        addConfrontationEffect(
            player,
            xi.effect.ALLIED_TAGS,
            battleId,
            duration or DEFAULT_TAG_DURATION
        )
    end

    player:setBattleID(battleId)
    return true
end

function core.leaveBattle(player, battleId, removeTags)
    if not player then
        return false
    end

    if removeTags then
        player:delStatusEffect(xi.effect.ALLIED_TAGS)
    end

    if not battleId or player:getBattleID() == battleId then
        player:setBattleID(0)
    end

    return true
end

function core.syncPlayer(player, battleId, shouldParticipate, duration)
    if not player then
        return
    end

    if shouldParticipate then
        core.joinBattle(player, battleId, duration)
    else
        core.leaveBattle(player, battleId, true)
    end
end

function core.despawnRuntimeList(runtimeList)
    -- Dynamic entity wrappers can become invalid immediately after an entity
    -- disappears. Capture IDs while wrappers are valid, clear references, and
    -- then use the supported global despawn function.
    local entityIds = {}

    for index = #runtimeList, 1, -1 do
        local entity = runtimeList[index]

        if entity then
            local ok, entityId = pcall(function()
                return entity:getID()
            end)

            if ok and entityId and entityId > 0 then
                entityIds[#entityIds + 1] = entityId
            end
        end

        table.remove(runtimeList, index)
    end

    for _, entityId in ipairs(entityIds) do
        DespawnMob(entityId)
    end
end

return core
