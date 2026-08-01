-----------------------------------
-- OmegaXI Campaign: East Ronfaure [S]
-----------------------------------
local factory = require('modules/omega/lua/campaign/zone_factory')

local config =
{
    moduleName = 'omega_campaign_east_ronfaure',
    zoneId = xi.zone.EAST_RONFAURE_S,
    zoneName = 'East Ronfaure [S]',
    zoneTableKey = 'East_Ronfaure_[S]',
    zoneOverrideBase = 'xi.zones.East_Ronfaure_[S]',
    variablePrefix = '[OmegaCampaign]ERS',
    battleId = 9002,
    arbiter = { scriptName = 'Arlayse_RK', displayName = 'Arlayse, R.K.', noAllegianceEvent = 453 },
    text = { unavailable = 7116, assessmentStart = 7117, noTags = 7118, tagsIssued = 7119, tagsEffect = 7109, alreadyTagged = 7120 },
    messages =
    {
        approach = { print = "Gnadgad's Dismemberment Brigade has begun its approach to East Ronfaure." },
        attack = { id = 7378 },
    },
    victoryPlayerText = "The Kingdom's forces are victorious!",
    victoryCommandText = "Campaign victory for San d'Oria.",
    teleports =
    {
        { label = "Return to Southern San d'Oria [S].", x = -28.082, y = 1.999, z = -29.106, rotation = 14, zoneId = 80 },
        { label = 'Travel to North Gustaberg [S].', x = -396.483, y = 40.471, z = -88.910, rotation = 193, zoneId = 88 },
    },
    alliedSpecs =
    {
        { name = 'Campaign_Cerane_I_Virgaut', packetName = 'Cerane I Virgaut', pos = { 308.0, -29.5, -112.0, 64 }, level = 70, groupId = 63, hpMultiplier = 3.00 },
        { name = 'Campaign_Aragoneu_Knight_1', packetName = 'Aragoneu Knight', pos = { 311.0, -29.5, -109.0, 64 }, level = 69, groupId = 64, hpMultiplier = 2.40 },
        { name = 'Campaign_Aragoneu_Knight_2', packetName = 'Aragoneu Knight', pos = { 311.0, -29.5, -115.0, 64 }, level = 69, groupId = 64, hpMultiplier = 2.40 },
        { name = 'Campaign_Aragoneu_Knight_3', packetName = 'Aragoneu Knight', pos = { 314.0, -29.5, -112.0, 64 }, level = 69, groupId = 64, hpMultiplier = 2.40 },
    },
    enemySpecs =
    {
        { name = 'Campaign_Poisonhand_Gnadgad', packetName = 'Poisonhand Gnadgad', pos = { 342.0, -29.5, -112.0, 192 }, level = 67, groupId = 86, commander = true, hpMultiplier = 4.50 },
        { name = 'Campaign_Dismemberment_Grappler_1', packetName = 'Dismemberment Grappler', pos = { 339.0, -29.5, -109.0, 192 }, level = 64, groupId = 87, hpMultiplier = 3.00 },
        { name = 'Campaign_Dismemberment_Grappler_2', packetName = 'Dismemberment Grappler', pos = { 339.0, -29.5, -115.0, 192 }, level = 64, groupId = 87, hpMultiplier = 3.00 },
        { name = 'Campaign_Dismemberment_Grappler_3', packetName = 'Dismemberment Grappler', pos = { 336.0, -29.5, -107.0, 192 }, level = 64, groupId = 87, hpMultiplier = 3.00 },
        { name = 'Campaign_Dismemberment_Grappler_4', packetName = 'Dismemberment Grappler', pos = { 336.0, -29.5, -117.0, 192 }, level = 64, groupId = 87, hpMultiplier = 3.00 },
    },
}

return factory.create(config)
