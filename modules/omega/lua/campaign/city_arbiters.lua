-----------------------------------
-- Omega Campaign city arbiters
-----------------------------------
require('modules/module_utils')
require('scripts/enum/zone')

local m = Module:new('omega_campaign_city_arbiters')

xi.omegaCampaign = xi.omegaCampaign or {}
xi.omegaCampaign.controllers = xi.omegaCampaign.controllers or {}

local destinations =
{
    {
        label = 'North Gustaberg [S]',
        zone = xi.zone.NORTH_GUSTABERG_S,
        x = -396.483,
        y = 40.471,
        z = -88.910,
        rot = 193,
    },
    {
        label = 'East Ronfaure [S]',
        zone = xi.zone.EAST_RONFAURE_S,
        x = 315.451,
        y = -29.732,
        z = -114.314,
        rot = 193,
    },
}

local function destinationLabel(destination)
    local controller = xi.omegaCampaign.controllers[destination.zone]
    if not controller or not controller.status then
        return destination.label
    end

    local status = controller.status()
    if status:find('active') then
        return destination.label .. ' - Battle in progress'
    elseif status:find('preparing') then
        return destination.label .. ' - Preparing'
    end

    return destination.label
end

local function showCityWarpMenu(player, npcName)
    local options = {}

    for _, destination in ipairs(destinations) do
        local target = destination
        table.insert(options,
        {
            destinationLabel(target),
            function(playerArg)
                playerArg:setPos(target.x, target.y, target.z, target.rot, target.zone)
            end,
        })
    end

    player:customMenu(
    {
        title = npcName .. ': Select a Campaign destination.',
        options = options,
    })
end

local handlers =
{
    {
        zoneId = xi.zone.BASTOK_MARKETS_S,
        zoneTable = 'Bastok_Markets_[S]',
        npcTable = 'Narkissa_CA',
        displayName = 'Narkissa, C.A.',
    },
    {
        zoneId = xi.zone.SOUTHERN_SAN_DORIA_S,
        zoneTable = 'Southern_San_dOria_[S]',
        npcTable = 'Scarlette_CA',
        displayName = 'Scarlette, C.A.',
    },
    {
        zoneId = xi.zone.WINDURST_WATERS_S,
        zoneTable = 'Windurst_Waters_[S]',
        npcTable = 'Wenonah_CA',
        displayName = 'Wenonah, C.A.',
    },
}

-- Remove the exact DefaultActions trigger for a city arbiter.  These entries
-- are loaded after modules are registered, so the removal must happen after
-- InteractionGlobal finishes loading the zone's default actions.
local function removeDefaultTrigger(handler)
    if not InteractionGlobal or not InteractionGlobal.lookup then
        return
    end

    local zoneData = InteractionGlobal.lookup.data and InteractionGlobal.lookup.data[handler.zoneId]
    local npcData = zoneData and zoneData[handler.npcTable]
    if npcData then
        npcData.onTrigger = nil
    end
end

local handlerByZone = {}
for _, handler in ipairs(handlers) do
    handlerByZone[handler.zoneId] = handler
end

-- DefaultActions are loaded after module registration.  Hook that loader so
-- Scarlette/Wenonah/Narkissa never retain their retail event alongside the
-- Omega menu, including after !reloadglobal-style interaction reloads.
m:addOverride('InteractionGlobal.loadDefaultActionsForZone', function(zoneId, shouldReloadRequires)
    super(zoneId, shouldReloadRequires)

    local handler = handlerByZone[zoneId]
    if handler then
        removeDefaultTrigger(handler)
    end
end)

local function attachHandler(handler)
    local zoneTable = xi.zones and xi.zones[handler.zoneTable]
    if not zoneTable then
        return false
    end

    zoneTable.npcs = zoneTable.npcs or {}
    zoneTable.npcs[handler.npcTable] = zoneTable.npcs[handler.npcTable] or {}
    zoneTable.npcs[handler.npcTable].onTrigger = function(player, npc)
        showCityWarpMenu(player, handler.displayName)
        return -1
    end

    -- Also remove it here for module reloads after InteractionGlobal has
    -- already been initialized.
    removeDefaultTrigger(handler)
    return true
end

for _, handler in ipairs(handlers) do
    local currentHandler = handler
    m:addOverride(string.format('xi.zones.%s.Zone.onInitialize', currentHandler.zoneTable), function(zone)
        super(zone)
        attachHandler(currentHandler)
    end)
end

-- Supports module reloads after the zone Lua tables and interaction lookup
-- have already been initialized.
for _, handler in ipairs(handlers) do
    attachHandler(handler)
end

return m
