-----------------------------------
-- OmegaXI Campaign zone factory
-- Shared battle lifecycle, scoring, menus, and module hooks.
-----------------------------------
require('modules/module_utils')
local campaignCore = require('modules/omega/lua/campaign/core')

local factory = {}
local unpackArgs = table.unpack or unpack

function factory.create(cfg)
    assert(cfg and cfg.moduleName and cfg.zoneId and cfg.zoneOverrideBase, 'Invalid Campaign zone configuration.')

    local m = Module:new(cfg.moduleName)
    m:setEnabled(true)

    xi.omegaCampaign = xi.omegaCampaign or {}
    xi.omegaCampaign.controllers = xi.omegaCampaign.controllers or {}
    local campaign = {}

    local ZONE_ID = cfg.zoneId
    local VAR_ACTIVE = cfg.variablePrefix .. ':Active'
    local VAR_END = cfg.variablePrefix .. ':End'
    local VAR_NEXT = cfg.variablePrefix .. ':Next'
    local VAR_ENGAGE = cfg.variablePrefix .. ':Engage'
    local VAR_WARNING_SENT = cfg.variablePrefix .. ':WarningSent'
    local VAR_ENGAGE_ANNOUNCED = cfg.variablePrefix .. ':EngageAnnounced'
    local SCORE_VAR = 'OmegaCampaignScore'
    local JOIN_VAR = 'OmegaCampaignJoinTime'
    local BATTLE_SECONDS = cfg.battleSeconds or 30 * 60
    local COOLDOWN_MIN = cfg.cooldownMin or 30 * 60
    local COOLDOWN_MAX = cfg.cooldownMax or 60 * 60
    local ALLIED_TAG_DURATION = cfg.tagDuration or 2 * 60 * 60
    local CAMPAIGN_BATTLE_ID = cfg.battleId
    local PREPARATION_SECONDS = cfg.preparationSeconds or 90
    local PREPARATION_WARNING_SECONDS = cfg.preparationWarningSeconds or 15
    local MAX_EVALUATION_SCORE = cfg.maxEvaluationScore or 2400
    local alliedSpecs = cfg.alliedSpecs
    local enemySpecs = cfg.enemySpecs

local runtime =
{
    -- Keep direct entity references. Dynamic entity IDs are released when a
    -- unit disappears, so repeatedly calling GetMobByID on old IDs floods
    -- map-server with warnings after deaths.
    allied = {},
    enemies = {},
    enemyCommander = 0,
    alliedAlive = 0,
    enemiesAlive = 0,
}

local function broadcastToZone(callback)
    local zone = GetZone(ZONE_ID)
    if not zone then
        return
    end

    for _, player in pairs(zone:getPlayers()) do
        callback(player)
    end
end

local function sendConfiguredMessage(player, message)
    if message.print then
        player:printToPlayer(message.print)
    elseif message.id then
        player:messageSpecial(message.id, unpackArgs(message.args or {}))
    end
end

local function announceApproach()
    broadcastToZone(function(player)
        sendConfiguredMessage(player, cfg.messages.approach)
    end)
end

local function announcePreparationWarning()
    broadcastToZone(function(player)
        player:printToPlayer('Enemy forces are nearly upon the stronghold! Battle will begin in 15 seconds.')
    end)
end

local function beginEngagement()
    if GetServerVariable(VAR_ENGAGE_ANNOUNCED) == 1 then
        return
    end

    SetServerVariable(VAR_ENGAGE_ANNOUNCED, 1)

    -- Campaign enemies must not proximity-aggro untagged players. Their
    -- scripted army targeting below starts combat with Allied NPCs, and they
    -- will still retaliate normally when a tagged player attacks them.
    for _, mob in ipairs(runtime.enemies) do
        if mob then
            mob:setAggressive(false)
        end
    end

    broadcastToZone(function(player)
        sendConfiguredMessage(player, cfg.messages.attack)
    end)

    printf('[OmegaCampaign] Preparation complete. Armies may now engage.')
end

local function isActive()
    return GetServerVariable(VAR_ACTIVE) == 1
end

local function resolvePlayer(entity)
    if not entity then
        return nil
    end

    if entity:isPC() then
        return entity
    end

    local master = entity:getMaster()
    if master and master:isPC() then
        return master
    end

    return nil
end

local function tagged(player)
    return player and player:hasStatusEffect(xi.effect.ALLIED_TAGS)
end

local function addScore(player, amount)
    if
        not isActive() or
        not player or
        player:getZoneID() ~= ZONE_ID or
        not tagged(player)
    then
        return
    end

    player:incrementCharVar(SCORE_VAR, math.max(0, math.floor(amount)))
end

local function levelMultiplier(level)
    if level <= 15 then
        return 0.20
    elseif level <= 30 then
        return 0.40
    elseif level <= 45 then
        return 0.60
    elseif level <= 60 then
        return 0.80
    end

    return 1.00
end

function campaign.evaluate(player, finalEvaluation)
    if not player or player:getZoneID() ~= ZONE_ID then
        return 0, 0
    end

    local rawScore = player:getCharVar(SCORE_VAR)
    -- Retail Campaign uses several action-category and duration caps. For this
    -- vertical slice, keep one clear encounter cap so meaningful participation
    -- is never reduced to almost nothing merely because the battle ended fast.
    -- A player who personally defeats the enemy army will naturally reach it.
    local cappedScore = math.min(rawScore, MAX_EVALUATION_SCORE)
    local exp = math.floor(cappedScore * levelMultiplier(player:getMainLvl()))
    local notes = math.floor(cappedScore / 2)

    if exp > 0 then
        player:addExp(exp)
    end

    if notes > 0 then
        player:addCurrency('allied_notes', notes)
    end

    player:setCharVar(SCORE_VAR, 0)

    if finalEvaluation then
        campaignCore.leaveBattle(player, CAMPAIGN_BATTLE_ID, true)
        player:setCharVar(JOIN_VAR, 0)
    else
        player:setCharVar(JOIN_VAR, GetSystemTime())
    end

    player:printToPlayer(string.format('Campaign evaluation: %d EXP and %d Allied Notes.', exp, notes))

    if finalEvaluation then
        player:printToPlayer('Your Allied Tags have been revoked.')
    end

    return exp, notes
end

local function removeRuntimeEntity(list, entity)
    -- Dynamic entities release their target ID immediately after disappearing.
    -- Remove the Lua wrapper from every live runtime list while the DEATH
    -- callback still owns a valid CMobEntity, otherwise later isSpawned() calls
    -- operate on an invalid base entity and spam map-server errors.
    for index = #list, 1, -1 do
        if list[index] == entity then
            table.remove(list, index)
        end
    end
end

local function countLivingEntities(list)
    -- Every unit removes itself from its runtime list in its DEATH listener.
    -- Avoid calling methods on released dynamic-entity wrappers here.
    return #list
end

local function getAvailableTarget(entities, startIndex)
    local count = #entities
    if count == 0 then
        return nil
    end

    -- Rotate each soldier's preferred target. Without this, every unit on a
    -- side focus-fires the first table entry and deletes armies one NPC at a
    -- time, making the battle extremely swingy.
    for offset = 0, count - 1 do
        local index = ((startIndex + offset - 1) % count) + 1
        local target = entities[index]
        if target then
            return target
        end
    end

    return nil
end

local function addArmyTargeting(mob, opposingEntities, targetIndex)
    local listenerName = 'OMEGA_CAMPAIGN_TARGET_' .. mob:getID()
    mob:removeListener(listenerName)
    mob:addListener('ROAM_TICK', listenerName, function(mobArg)
        if not isActive() then
            return
        end

        local now = GetSystemTime()
        local engageTime = GetServerVariable(VAR_ENGAGE)

        if now < engageTime then
            if
                GetServerVariable(VAR_WARNING_SENT) == 0 and
                engageTime - now <= PREPARATION_WARNING_SECONDS
            then
                SetServerVariable(VAR_WARNING_SENT, 1)
                announcePreparationWarning()
            end

            return
        end

        beginEngagement()

        if mobArg:getTarget() then
            return
        end

        local target = getAvailableTarget(opposingEntities, targetIndex)
        if target then
            -- Seed each new NPC-vs-NPC matchup with retail Provoke-equivalent
            -- enmity (1 CE / 1800 VE). This gives the armies an initial hate
            -- lead so lower-level players can participate without immediately
            -- becoming the enemy force's primary targets. A newly selected
            -- opponent receives the same opening hate when the prior target dies.
            local targetId = target:getID()
            local previousTargetId = mobArg:getLocalVar('OMEGA_CAMPAIGN_HATE_TARGET')

            if previousTargetId ~= targetId then
                mobArg:setLocalVar('OMEGA_CAMPAIGN_HATE_TARGET', targetId)
                mobArg:addEnmity(target, 1, 1800)
            else
                mobArg:addEnmity(target, 0, 1)
            end

            mobArg:updateEnmity(target)
        end
    end)
end

local function spawnDynamicUnit(zone, spec, allied)
    local mob = zone:insertDynamicEntity({
        objtype = xi.objType.MOB,
        allegiance = allied and xi.allegiance.PLAYER or xi.allegiance.MOB,
        name = spec.name,
        packetName = spec.packetName,
        x = spec.pos[1],
        y = spec.pos[2],
        z = spec.pos[3],
        rotation = spec.pos[4],
        groupId = spec.groupId,
        groupZoneId = ZONE_ID,
        minLevel = spec.level,
        maxLevel = spec.level,
        spawnType = 128,
        isAggroable = not allied,
        releaseIdOnDisappear = true,
        specialSpawnAnimation = true,
    })

    if not mob then
        printf('[OmegaCampaign] Failed to insert dynamic unit %s', spec.name)
        return nil
    end

    mob:setSpawn(spec.pos[1], spec.pos[2], spec.pos[3], spec.pos[4])
    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setMobMod(xi.mobMod.EXP_BONUS, -100)
    mob:setMobMod(xi.mobMod.GIL_BONUS, -100)
    mob:setBaseSpeed(35)
    mob:setUntargetable(false)

    local damageListener = 'OMEGA_CAMPAIGN_DAMAGE_' .. mob:getID()
    local deathListener = 'OMEGA_CAMPAIGN_DEATH_' .. mob:getID()

    mob:setRoamFlags(xi.roamFlag.SCRIPTED)
    mob:setAggressive(false)

    -- Dynamic entities finish constructing their event handler during spawn.
    -- Match Garrison's proven ordering: spawn first, then attach listeners.
    mob:spawn()

    if not allied then
        mob:addListener('TAKE_DAMAGE', damageListener, function(_, damage, attacker)
            local player = resolvePlayer(attacker)
            if player then
                addScore(player, damage * 0.10)
            end
        end)
    end

    mob:addListener('DEATH', deathListener, function(mobArg, killer)
        if allied then
            removeRuntimeEntity(runtime.allied, mobArg)
            runtime.alliedAlive = math.max(0, runtime.alliedAlive - 1)

            if isActive() and runtime.alliedAlive == 0 then
                campaign.stopBattle(false)
            end
        else
            removeRuntimeEntity(runtime.enemies, mobArg)
            runtime.enemiesAlive = math.max(0, runtime.enemiesAlive - 1)

            local player = resolvePlayer(killer)
            if player then
                addScore(player, spec.commander and 500 or 100)
            end

            -- End only when the deployed enemy force is actually defeated.
            -- This is deterministic and does not depend on dynamic Lua wrapper
            -- identity surviving releaseIdOnDisappear.
            if isActive() and runtime.enemiesAlive == 0 then
                campaign.stopBattle(true)
            end
        end
    end)

    campaignCore.configureCombatant(
        mob,
        CAMPAIGN_BATTLE_ID,
        allied and xi.allegiance.PLAYER or xi.allegiance.MOB
    )

    if spec.hpMultiplier and spec.hpMultiplier > 1 then
        local adjustedMaxHP = math.floor(mob:getMaxHP() * spec.hpMultiplier)
        mob:setMaxHP(adjustedMaxHP)
        mob:setHP(adjustedMaxHP)
    end

    -- Hostile mobs use UPDATE status for normal combat presentation. Allied
    -- mobs remain NORMAL. Their PLAYER allegiance plus matching confrontation
    -- power allows tagged players to cure and enhance them.
    mob:setStatus(allied and xi.status.NORMAL or xi.status.UPDATE)
    mob:setUntargetable(false)
    DisallowRespawn(mob:getID(), true)
    return mob
end

local function cleanup()
    campaignCore.despawnRuntimeList(runtime.allied)
    campaignCore.despawnRuntimeList(runtime.enemies)

    runtime.enemyCommander = 0
    runtime.alliedAlive = 0
    runtime.enemiesAlive = 0
    SetServerVariable(VAR_ENGAGE, 0)
    SetServerVariable(VAR_WARNING_SENT, 0)
    SetServerVariable(VAR_ENGAGE_ANNOUNCED, 0)
end

function campaign.startBattle(force)
    if isActive() then
        return false, 'A Campaign Battle is already active.'
    end

    local now = GetSystemTime()
    local nextBattle = GetServerVariable(VAR_NEXT)
    if not force and nextBattle > now then
        return false, string.format('The next battle may begin in %d minutes.', math.ceil((nextBattle - now) / 60))
    end

    local zone = GetZone(ZONE_ID)
    if not zone then
        return false, string.format('%s is not loaded.', cfg.zoneName)
    end

    cleanup()

    for _, spec in ipairs(alliedSpecs) do
        local mob = spawnDynamicUnit(zone, spec, true)
        if mob then
            table.insert(runtime.allied, mob)
        end
    end

    for _, spec in ipairs(enemySpecs) do
        local mob = spawnDynamicUnit(zone, spec, false)
        if mob then
            table.insert(runtime.enemies, mob)
            if spec.commander then
                runtime.enemyCommander = mob:getID()
            end
        end
    end

    runtime.alliedAlive = #runtime.allied
    runtime.enemiesAlive = #runtime.enemies

    if #runtime.allied == 0 or #runtime.enemies == 0 then
        printf('[OmegaCampaign] Battle start failed: allied=%u enemies=%u', #runtime.allied, #runtime.enemies)
        cleanup()
        SetServerVariable(VAR_ACTIVE, 0)
        SetServerVariable(VAR_END, 0)
        return false, 'Campaign Battle failed to deploy its armies. Check map-server logs.'
    end

    -- Attach targeting only after both runtime ID lists are complete.
    for index, mob in ipairs(runtime.allied) do
        if mob then
            addArmyTargeting(mob, runtime.enemies, index)
        end
    end

    for index, mob in ipairs(runtime.enemies) do
        if mob then
            addArmyTargeting(mob, runtime.allied, index)
        end
    end

    SetServerVariable(VAR_ACTIVE, 1)
    SetServerVariable(VAR_END, now + BATTLE_SECONDS)
    SetServerVariable(VAR_ENGAGE, now + PREPARATION_SECONDS)
    SetServerVariable(VAR_WARNING_SENT, 0)
    SetServerVariable(VAR_ENGAGE_ANNOUNCED, 0)

    announceApproach()

    printf('[OmegaCampaign] Battle deployed: allied=%u enemies=%u commander=%u',
        #runtime.allied, #runtime.enemies, runtime.enemyCommander)

    return true, string.format('Campaign Battle started in ' .. cfg.zoneName .. ' (%d allied, %d enemies).', #runtime.allied, #runtime.enemies)
end

function campaign.stopBattle(victory)
    if not isActive() then
        return false, 'No Campaign Battle is active.'
    end

    SetServerVariable(VAR_ACTIVE, 0)
    SetServerVariable(VAR_END, 0)
    SetServerVariable(VAR_NEXT, GetSystemTime() + math.randomInt(COOLDOWN_MIN, COOLDOWN_MAX))

    local zone = GetZone(ZONE_ID)
    if zone then
        for _, player in pairs(zone:getPlayers()) do
            if tagged(player) then
                campaign.evaluate(player, true)
                player:printToPlayer(victory and cfg.victoryPlayerText or 'The Campaign Battle has ended.')
            end
        end
    end

    cleanup()
    return true, victory and cfg.victoryCommandText or 'Campaign Battle stopped.'
end

function campaign.status()
    if not isActive() then
        local nextBattle = GetServerVariable(VAR_NEXT)
        if nextBattle > GetSystemTime() then
            return string.format('Campaign idle. Next automatic battle in about %d minutes.', math.ceil((nextBattle - GetSystemTime()) / 60))
        end

        return 'Campaign idle and ready to begin.'
    end

    local engageTime = GetServerVariable(VAR_ENGAGE)
    if engageTime > GetSystemTime() then
        return string.format('Campaign preparing. Combat begins in about %d seconds.', engageTime - GetSystemTime())
    end

    return string.format('Campaign active. Approximately %d minutes remain.', math.max(0, math.ceil((GetServerVariable(VAR_END) - GetSystemTime()) / 60)))
end

local onArbiterTrigger

local function attachArbiterHandler()
    local zoneTable = xi.zones and xi.zones[cfg.zoneTableKey]
    if not zoneTable then
        return false
    end

    zoneTable.npcs = zoneTable.npcs or {}
    zoneTable.npcs[cfg.arbiter.scriptName] = zoneTable.npcs[cfg.arbiter.scriptName] or {}
    zoneTable.npcs[cfg.arbiter.scriptName].onTrigger = onArbiterTrigger
    return true
end

local function normalizeCampaignPlayer(player)
    if not player then
        return
    end

    if isActive() and tagged(player) then
        campaignCore.joinBattle(player, CAMPAIGN_BATTLE_ID, ALLIED_TAG_DURATION)
    else
        campaignCore.leaveBattle(player, CAMPAIGN_BATTLE_ID, true)
    end
end

m:addOverride(cfg.zoneOverrideBase .. '.Zone.onInitialize', function(zone)
    super(zone)

    if GetServerVariable(VAR_NEXT) == 0 then
        SetServerVariable(VAR_NEXT, GetSystemTime() + 60)
    end

    -- Campaign units do not remain spawned across a map restart.
    if isActive() then
        SetServerVariable(VAR_ACTIVE, 0)
        SetServerVariable(VAR_END, 0)
        SetServerVariable(VAR_NEXT, GetSystemTime() + 60)
    end

    cleanup()
    attachArbiterHandler()
end)

m:addOverride(cfg.zoneOverrideBase .. '.Zone.onZoneIn', function(player, prevZone)
    local cs = super(player, prevZone)
    normalizeCampaignPlayer(player)
    return cs
end)

m:addOverride(cfg.zoneOverrideBase .. '.Zone.onGameHour', function(zone)
    super(zone)

    for _, player in pairs(zone:getPlayers()) do
        normalizeCampaignPlayer(player)
    end

    if isActive() and GetSystemTime() >= GetServerVariable(VAR_END) then
        campaign.stopBattle(false)
    elseif not isActive() and GetSystemTime() >= GetServerVariable(VAR_NEXT) then
        campaign.startBattle(false)
    end
end)

local function issueAlliedTags(player)
    if tagged(player) or not isActive() then
        return false
    end

    campaignCore.joinBattle(player, CAMPAIGN_BATTLE_ID, ALLIED_TAG_DURATION)
    player:setCharVar(SCORE_VAR, 0)
    player:setCharVar(JOIN_VAR, GetSystemTime())
    return true
end

local function unavailable(player)
    -- Retail Campaign Arbiter text: "I am sorry, but at this time..."
    player:messageSpecial(cfg.text.unavailable)
end

local function openCustomMenuAfterSelection(player, menu)
    -- LSB clears the current custom-menu context after the selected callback
    -- returns. Opening another menu immediately inside that callback causes the
    -- new context to be erased too, so the next selection is treated as a tell.
    player:timer(50, function(playerArg)
        playerArg:customMenu(menu)
    end)
end

local function showCampaignInfoMenu(player)
    openCustomMenuAfterSelection(player, {
        title = cfg.arbiter.displayName .. ': Information on the Allied Campaign',
        options =
        {
            {
                'About performance assessment.',
                function(playerArg)
                    playerArg:printToPlayer('Defeat enemies and support allied forces while wearing Allied Tags.')
                    playerArg:printToPlayer('Your evaluation is based on your contribution during the current battle.')
                    playerArg:printToPlayer('You may request an assessment during battle or receive one automatically when it ends.')
                end,
            },
            {
                'About Allied Tags.',
                function(playerArg)
                    playerArg:printToPlayer('Allied Tags register you as a participant in the current Campaign Battle.')
                    playerArg:printToPlayer('Tags are removed when you leave the battle area or receive an assessment.')
                end,
            },
            {
                'About temporary items.',
                function(playerArg)
                    playerArg:printToPlayer('Campaign temporary items are not available yet.')
                end,
            },
            {
                'About Unions.',
                function(playerArg)
                    playerArg:printToPlayer('Campaign Unions are not available yet.')
                end,
            },
        },
    })
end

local function assessBeforeTravel(playerArg)
    if tagged(playerArg) then
        campaign.evaluate(playerArg, true)
    end
end

local function showTeleportMenu(player)
    local options = {}
    for _, destination in ipairs(cfg.teleports or {}) do
        table.insert(options, {
            destination.label,
            function(playerArg)
                assessBeforeTravel(playerArg)
                playerArg:setPos(destination.x, destination.y, destination.z, destination.rotation, destination.zoneId)
            end,
        })
    end

    openCustomMenuAfterSelection(player, {
        title = cfg.arbiter.displayName .. ': Where would you like to go?',
        options = options,
    })
end

local function showArbiterMenu(player)
    local options = {}

    if isActive() then
        table.insert(options, {
            'Performance assessment.',
            function(playerArg)
                if tagged(playerArg) then
                    playerArg:messageSpecial(cfg.text.assessmentStart)
                    campaign.evaluate(playerArg, true)
                else
                    playerArg:messageSpecial(cfg.text.noTags)
                end
            end,
        })

        table.insert(options, {
            'New Allied Tags.',
            function(playerArg)
                if issueAlliedTags(playerArg) then
                    playerArg:messageSpecial(cfg.text.tagsIssued)
                    playerArg:messageSpecial(cfg.text.tagsEffect)
                elseif tagged(playerArg) then
                    playerArg:messageSpecial(cfg.text.alreadyTagged)
                else
                    unavailable(playerArg)
                end
            end,
        })

        table.insert(options, {
            'Temporary items.',
            function(playerArg)
                unavailable(playerArg)
            end,
        })

        table.insert(options, {
            'Union registration.',
            function(playerArg)
                unavailable(playerArg)
            end,
        })
    end

    table.insert(options, {
        'Teleportation.',
        function(playerArg)
            showTeleportMenu(playerArg)
        end,
    })

    table.insert(options, {
        'Information on the Allied Campaign.',
        function(playerArg)
            showCampaignInfoMenu(playerArg)
        end,
    })

    player:customMenu({
        title = cfg.arbiter.displayName .. ': What can I help you with?',
        options = options,
    })
end

onArbiterTrigger = function(player, npc)
    if player:getCampaignAllegiance() == 0 then
        player:startEvent(cfg.arbiter.noAllegianceEvent)
        return
    end

    -- Event 457's menu visibility is controlled by undocumented client-side
    -- parameters. Use a server-owned menu so Campaign state is authoritative,
    -- while retaining the retail Campaign dialogue strings for each action.
    showArbiterMenu(player)
end

-- Register the zone controller for the module-based GM command.
-- Each zone initializes the registry itself, so file load order is harmless.
xi.omegaCampaign.controllers[ZONE_ID] = campaign
attachArbiterHandler()
return m, campaign
end

return factory
