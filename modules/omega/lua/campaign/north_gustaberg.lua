-----------------------------------
-- OmegaXI Campaign: North Gustaberg [S]
-----------------------------------
local factory = require('modules/omega/lua/campaign/zone_factory')

local config =
{
    moduleName = 'omega_campaign_north_gustaberg',
    zoneId = xi.zone.NORTH_GUSTABERG_S,
    zoneName = 'North Gustaberg [S]',
    zoneTableKey = 'North_Gustaberg_[S]',
    zoneOverrideBase = 'xi.zones.North_Gustaberg_[S]',
    variablePrefix = '[OmegaCampaign]NGS',
    battleId = 9001,
    arbiter = { scriptName = 'Uriah_CA', displayName = 'Uriah, C.A.', noAllegianceEvent = 453 },
    text = { unavailable = 7515, assessmentStart = 7516, noTags = 7517, tagsIssued = 7518, tagsEffect = 7508, alreadyTagged = 7519 },
    messages =
    {
        approach = { id = 7343, args = { 49, 5 } },
        attack = { id = 7329, args = { 49, 9, 0 } },
    },
    victoryPlayerText = 'The Republican forces are victorious!',
    victoryCommandText = 'Campaign victory for Bastok.',
    teleports =
    {
        { label = 'Return to Bastok Markets [S].', x = -318.933, y = -11.999, z = -44.823, rotation = 22, zoneId = 87 },
        { label = 'Travel to East Ronfaure [S].', x = 315.451, y = -29.732, z = -114.314, rotation = 193, zoneId = 81 },
    },
    alliedSpecs =
    {
        { name = 'Campaign_Bartholomaus', packetName = 'Bartholomaus', pos = { -421.0, 40.0, -89.0, 64 }, level = 70, groupId = 62, hpMultiplier = 3.00 },
        { name = 'Campaign_Iron_Musketeer_1', packetName = '1st Iron Musketeer', pos = { -418.0, 40.0, -86.0, 64 }, level = 69, groupId = 63, hpMultiplier = 2.40 },
        { name = 'Campaign_Iron_Musketeer_2', packetName = '1st Iron Musketeer', pos = { -418.0, 40.0, -92.0, 64 }, level = 69, groupId = 63, hpMultiplier = 2.40 },
        { name = 'Campaign_Iron_Musketeer_3', packetName = '1st Iron Musketeer', pos = { -415.0, 40.0, -89.0, 64 }, level = 69, groupId = 63, hpMultiplier = 2.40 },
    },
    enemySpecs =
    {
        { name = 'Campaign_DiDha_Adamantfist', packetName = "Di'Dha Adamantfist", pos = { -451.0, 40.0, -89.0, 192 }, level = 67, groupId = 83, commander = true, hpMultiplier = 4.50 },
        { name = 'Campaign_Elite_Guard_1', packetName = "Di'Dha's Elite Guard", pos = { -448.0, 40.0, -86.0, 192 }, level = 64, groupId = 84, hpMultiplier = 3.00 },
        { name = 'Campaign_Elite_Guard_2', packetName = "Di'Dha's Elite Guard", pos = { -448.0, 40.0, -92.0, 192 }, level = 64, groupId = 84, hpMultiplier = 3.00 },
        { name = 'Campaign_Elite_Guard_3', packetName = "Di'Dha's Elite Guard", pos = { -445.0, 40.0, -84.0, 192 }, level = 64, groupId = 84, hpMultiplier = 3.00 },
        { name = 'Campaign_Elite_Guard_4', packetName = "Di'Dha's Elite Guard", pos = { -445.0, 40.0, -94.0, 192 }, level = 64, groupId = 84, hpMultiplier = 3.00 },
    },
}

return factory.create(config)
