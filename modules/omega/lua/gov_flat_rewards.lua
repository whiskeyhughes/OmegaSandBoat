-----------------------------------
-- Grounds of Valor: flat rewards + block post-WotG (2011+) high-level pages
-----------------------------------
-- This file bundles TWO changes to xi.regime.checkRegime -- both live here
-- rather than in separate files because neither calls super(), so a second
-- file overriding the same hook would silently discard this one.
--
-- CHANGE 1 -- flat rewards (matches Fields of Valor):
-- Base game behavior: completing a Grounds of Valor page does two GoV-only
-- things on top of the normal reward -- grants a random "Prowess" combat buff
-- (Casket Rate, Skill-up Rate, Crystal Yield, TH, Attack Speed, HP/MP, ACC/RACC,
-- ATT/RATT, MACC/MATK, Cure Potency, WS Damage, Killer -- stacking up to each
-- buff's own cap), and separately tracks consecutive clears via a dedicated
-- effect (xi.effect.PROWESS) that multiplies gil/tabs/EXP reward by +4% per
-- clear, capped at 2x base reward. Server preference: keep Grounds enabled for
-- its wider zone coverage, but make its reward behavior identical to Fields --
-- flat, no escalating multiplier, no Prowess buffs.
--
-- CHANGE 2 -- block post-WotG high-level pages:
-- Grounds of Valor itself launched 2011-05-10 (dev1011) -- over a year after
-- WotG ended (May 2010). Beyond that, a large fraction of GROUNDS zones have
-- extra page tiers (levels 85-105) that were added even later, in the
-- 2011-08-12 update (dev1022), which explicitly placed brand-new high-level
-- monsters into these classic dungeons for post-99-cap characters. These
-- specific tiers never existed during WotG at all -- not just unreached,
-- genuinely absent. Blocked below by regimeId (low-end level > 75 cutoff,
-- matching MAX_LEVEL). The page may still be listed as selectable in the
-- Grounds Tome menu (this doesn't touch the menu/packet code), but attempting
-- it is a permanent no-op -- kills toward it are silently ignored.
--
-- Blocked zones/regimeIds (52 total across 21 zones):
--   The Boyahda Tree: 726
--   Ranguemont Pass: 607, 608, 609
--   Bostaunieux Oubliette: 614, 615, 616, 617
--   Toraimarai Canal: 622, 623, 624, 625
--   Korroloka Tunnel: 734
--   Kuftal Tunnel: 741, 742
--   Ve'Lugannon Palace: 746, 747, 748
--   The Shrine of Ru'Avitau: 752, 753, 754
--   King Ranperre's Tomb: 636, 637, 638
--   Dangruf Wadi: 642, 643, 644, 645, 646
--   Inner Horutoto Ruins: 651, 652, 653, 654
--   Ordelles Caves: 661, 662
--   Outer Horutoto Ruins: 669, 670
--   The Eldieme Necropolis: 677, 678
--   Gusgen Mines: 685, 686
--   Crawler's Nest: 693, 694
--   Maze of Shakhrami: 701, 702
--   Garlaige Citadel: 709, 710
--   FeiYin: 717, 718
--   Gustav Tunnel: 769, 770
--   Labyrinth of Onzozo: 776
--
-- If upstream ever changes xi.regime.checkRegime for reasons unrelated to
-- either change above, this override will need to be manually re-diffed
-- against the current scripts/globals/regimes.lua to stay in sync.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local moduleName = 'gov_flat_rewards'
local m = Module:new(moduleName)

local blockedRegimeIds =
{
    [726] = true,
    [607] = true, [608] = true, [609] = true,
    [614] = true, [615] = true, [616] = true, [617] = true,
    [622] = true, [623] = true, [624] = true, [625] = true,
    [734] = true,
    [741] = true, [742] = true,
    [746] = true, [747] = true, [748] = true,
    [752] = true, [753] = true, [754] = true,
    [636] = true, [637] = true, [638] = true,
    [642] = true, [643] = true, [644] = true, [645] = true, [646] = true,
    [651] = true, [652] = true, [653] = true, [654] = true,
    [661] = true, [662] = true,
    [669] = true, [670] = true,
    [677] = true, [678] = true,
    [685] = true, [686] = true,
    [693] = true, [694] = true,
    [701] = true, [702] = true,
    [709] = true, [710] = true,
    [717] = true, [718] = true,
    [769] = true, [770] = true,
    [776] = true,
}

m:addOverride('xi.regime.checkRegime', function(player, mob, regimeId, index, regimeType)
    -- blocked post-WotG high-level page -- permanent no-op, no progress tracked
    if blockedRegimeIds[regimeId] then
        return
    end

    -- dead players, or players not on this training regime, get no credit
    -- also prevents error when this function is called onMobDeath from a mob not killed by a player
    if
        not player or
        player:getHP() == 0 or
        player:getCharVar('[regime]id') ~= regimeId
    then
        return
    end

    -- people in alliance get no fields credit unless FOV_REWARD_ALLIANCE is 1 in settings/main.lua
    if
        xi.settings.main.FOV_REWARD_ALLIANCE ~= 1 and
        regimeType == xi.regime.type.FIELDS and
        player:checkSoloPartyAlliance() == 2
    then
        return
    end

    -- people in alliance get no grounds credit unless GOV_REWARD_ALLIANCE is 1 in settings/main.lua
    if
        xi.settings.main.GOV_REWARD_ALLIANCE ~= 1 and
        regimeType == xi.regime.type.GROUNDS and
        player:checkSoloPartyAlliance() == 2
    then
        return
    end

    -- mobs that give no XP give no credit
    if not player:checkKillCredit(mob) then
        return
    end

    -- get number of this mob needed, and killed so far
    local needed = player:getCharVar('[regime]needed' .. index)
    local killed = player:getCharVar('[regime]killed' .. index)

    -- already finished with this mob
    if killed == needed then
        return
    end

    -- increment number killed
    killed = killed + 1
    player:messageBasic(xi.msg.basic.FOV_DEFEATED_TARGET, killed, needed)
    player:setCharVar('[regime]killed' .. index, killed)

    -- this mob is not yet finished
    if needed > killed then
        return
    end

    -- get page information
    local page = getPageByRegimeId(player:getCharVar('[regime]type'), player:getCharVar('[regime]zone'), player:getCharVar('[regime]id'))
    if not page then
        return
    end

    -- this page is not yet finished
    for i = 1, 4 do
        if player:getCharVar('[regime]killed' .. i) < page[i] then
            return
        end
    end

    -- get base reward
    player:messageBasic(xi.msg.basic.FOV_COMPLETED_REGIME)
    local reward = page[7]

    -- adjust reward down if regime is higher than server mob level cap
    -- example: if you have mobs capped at level 80, and the regime is level 100, you will only get 80% of the reward
    if
        xi.settings.main.NORMAL_MOB_MAX_LEVEL_RANGE_MAX > 0 and
        page[6] > xi.settings.main.NORMAL_MOB_MAX_LEVEL_RANGE_MAX
    then
        local avgCapLevel = (xi.settings.main.NORMAL_MOB_MAX_LEVEL_RANGE_MIN + xi.settings.main.NORMAL_MOB_MAX_LEVEL_RANGE_MAX) / 2
        local avgMobLevel = (page[5] + page[6]) / 2

        reward = math.floor(reward * avgCapLevel / avgMobLevel)
    end

    -- REMOVED: "prowess buffs from completing Grounds regimes" block.
    -- Grounds now falls straight through to the same flat reward path Fields uses --
    -- no Prowess combat buffs, no gil/tabs/EXP escalation.

    -- award gil and tabs once per day, or at every page completion if REGIME_WAIT is 0 in settings.lua
    local vanadielEpoch = VanadielUniqueDay()
    if
        xi.settings.main.REGIME_WAIT == 0 or
        player:getCharVar('[regime]lastReward') < vanadielEpoch
    then
        -- gil
        player:addGil(reward)
        player:messageBasic(xi.msg.basic.FOV_OBTAINS_GIL, reward)

        -- tabs
        local tabs = math.floor(reward / 10) * xi.settings.main.TABS_RATE
        tabs       = utils.clamp(tabs, 0, 50000 - player:getCurrency('valor_point')) -- Retail caps players at 50000 tabs

        player:addCurrency('valor_point', tabs)
        player:messageBasic(xi.msg.basic.FOV_OBTAINS_TABS, tabs, player:getCurrency('valor_point'))

        player:setCharVar('[regime]lastReward', vanadielEpoch)
    end

    -- Award EXP for page completion
    -- Player must be equal or greater than REGIME_REWARD_THRESHOLD levels below the minimum suggested level
    if player:getMainLvl() >= math.max(1, page[5] - xi.settings.main.REGIME_REWARD_THRESHOLD) then
        player:addExp(reward * xi.settings.main.BOOK_EXP_RATE)
    end

    -- repeating regimes
    if player:getCharVar('[regime]repeat') == 1 then
        for i = 1, 4 do
            player:setCharVar('[regime]killed' .. i, 0)
        end

        player:messageBasic(xi.msg.basic.FOV_REGIME_BEGINS_ANEW)
    else
        xi.regime.clearRegimeVars(player)
    end
end)

return m
