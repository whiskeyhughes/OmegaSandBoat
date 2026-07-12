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
-- ARCHITECTURE NOTE (why this file is ~900 lines):
-- xi.regime.checkRegime (the function we're overriding) depends on two things
-- private to scripts/globals/regimes.lua: a local table `regimeInfo` (every
-- Fields/Grounds zone's page data -- kill counts, level range, reward, regimeId)
-- and a local helper `getPageByRegimeId` that looks a page up out of it. Both
-- are declared `local`, meaning they are NOT reachable from any other file --
-- there is no addOverride path that can reach into another file's local scope.
-- The only way to keep this override fully self-contained (no edits to any
-- original/upstream file) is to duplicate both directly below.
--
-- TRADEOFF: if upstream LandSandBoat ever changes regimeInfo (new pages,
-- adjusted rewards/level-ranges, additional zones), this copy will NOT pick
-- those changes up automatically -- it needs to be manually re-synced against
-- the current scripts/globals/regimes.lua. Re-diff both the data table below
-- and the "checkRegime" logic itself if upstream ever touches this system.
--
-- BUG THIS FILE FIXES (found the hard way): an earlier version of this
-- override called the *original* file's local getPageByRegimeId directly,
-- which is undefined outside regimes.lua and threw
-- "attempt to call global 'getPageByRegimeId' (a nil value)" on every single
-- completion attempt -- silently, with no crash, no in-game message. Counter
-- increments (which happen before that line) always worked fine, which is why
-- it looked like pages were "stuck at fully-satisfied counts" rather than an
-- obvious hard error. Confirmed via the actual map-server console log.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local moduleName = 'gov_flat_rewards'
local m = Module:new(moduleName)

-- ===================================================================
-- Duplicated from scripts/globals/regimes.lua (see architecture note above)
-- ===================================================================

local regimeInfo =
{

    -----------------------------------
    -- Fields of Valor information
    -----------------------------------

    [xi.regime.type.FIELDS] =
    {
        sharedOptions =
        {
            [18] = { page = 1 },
            [34] = { page = 2 },
            [50] = { page = 3 },
            [66] = { page = 4 },
            [82] = { page = 5 },
        },
        updateOptions =
        {
            [ 1] = { review = true },
            [ 6] = { details = true },
        },
        finishOptions =
        {
            [  3] = { act = 'CANCEL_REGIME',   cost =  0, discounted =  0 },
            [ 21] = { act = 'REPATRIATION',    cost = 50, discounted = 10 },
            [ 37] = { act = 'RERAISE',         cost = 10, discounted =  5 },
            [ 53] = { act = 'REGEN',           cost = 20, discounted = 10 },
            [ 69] = { act = 'REFRESH',         cost = 20, discounted = 10 },
            [ 85] = { act = 'PROTECT',         cost = 15, discounted =  5 },
            [101] = { act = 'SHELL',           cost = 15, discounted =  5 },
            [117] = { act = 'DRIED_MEAT',      cost = 50, discounted = 25, food = true },
            [133] = { act = 'SALTED_FISH',     cost = 50, discounted = 25, food = true },
            [149] = { act = 'HARD_COOKIE',     cost = 50, discounted = 25, food = true },
            [165] = { act = 'INSTANT_NOODLES', cost = 50, discounted = 25, food = true },
            [181] = { act = 'CIPHER_KORU',     cost = 300, discounted = 300 },
            [197] = { act = 'CIPHER_SAKURA',   cost = 300, discounted = 300 },

            -- TODO: implement elite training
            -- ELITE_INTRO     =  36,
            -- ELITE_CHAP1     =  52,
            -- ELITE_CHAP2     =  68,
            -- ELITE_CHAP3     =  84,
            -- ELITE_CHAP4     = 100,
            -- ELITE_CHAP5     = 116,
            -- ELITE_CHAP6     = 132,
            -- ELITE_CHAP7     = 148,
        },
        zone =
        {
            [xi.zone.WEST_RONFAURE] =
            {
                event = 61,
                page =
                {
                    { 6, 0, 0, 0, 1, 6, 270,  1 },
                    { 6, 0, 0, 0, 2, 6, 285,  2 },
                    { 5, 1, 0, 0, 4, 7, 300,  3 },
                    { 4, 2, 0, 0, 4, 8, 315,  4 },
                    { 6, 1, 0, 0, 4, 8, 330, 56 },
                },
            },
            [xi.zone.EAST_RONFAURE] =
            {
                event = 61,
                page =
                {
                    { 6, 0, 0, 0, 1, 5, 270, 64 },
                    { 6, 0, 0, 0, 2, 5, 285, 65 },
                    { 7, 0, 0, 0, 2, 6, 300, 66 },
                    { 4, 2, 0, 0, 3, 6, 315, 67 },
                    { 4, 2, 0, 0, 4, 8, 330, 68 },
                },
            },
            [xi.zone.LA_THEINE_PLATEAU] =
            {
                event = 61,
                page =
                {
                    { 3, 3, 0, 0, 8, 12, 330,   5 },
                    { 3, 5, 0, 0, 11, 13, 360, 69 },
                    { 8, 0, 0, 0, 12, 13, 390,  6 },
                    { 5, 3, 0, 0, 11, 14, 420, 70 },
                    { 5, 3, 0, 0, 10, 15, 450, 71 },
                },
            },
            [xi.zone.VALKURM_DUNES] =
            {
                event = 47,
                page =
                {
                    { 7, 1, 0, 0, 15, 19, 475,  7 },
                    { 6, 2, 0, 0, 15, 22, 500,  8 },
                    { 5, 3, 0, 0, 18, 23, 525,  9 },
                    { 4, 4, 0, 0, 20, 23, 550, 10 },
                    { 4, 2, 0, 0, 22, 25, 575, 57 },
                },
            },
            [xi.zone.JUGNER_FOREST] =
            {
                event = 32,
                page =
                {
                    { 8, 2, 0, 0, 15, 18, 480, 58 },
                    { 9, 0, 0, 0, 21, 22, 540, 11 },
                    { 8, 1, 0, 0, 21, 23, 570, 12 },
                    { 7, 2, 0, 0, 22, 25, 600, 13 },
                    { 6, 3, 0, 0, 24, 25, 630, 14 },
                },
            },
            [xi.zone.BATALLIA_DOWNS] =
            {
                event = 61,
                page =
                {
                    { 5, 2, 0, 0, 23, 26, 630, 72 },
                    { 5, 2, 0, 0, 23, 28, 650, 73 },
                    { 4, 3, 0, 0, 25, 28, 670, 15 },
                    { 5, 2, 2, 0, 26, 32, 700, 74 },
                    { 9, 0, 0, 0, 31, 32, 730, 75 },
                },
            },
            [xi.zone.NORTH_GUSTABERG] =
            {
                event = 266,
                page =
                {
                    { 6, 0, 0, 0, 1, 6, 270, 16 },
                    { 6, 0, 0, 0, 3, 6, 285, 17 },
                    { 5, 1, 0, 0, 3, 7, 300, 18 },
                    { 4, 2, 0, 0, 3, 8, 315, 19 },
                    { 3, 4, 0, 0, 3, 8, 330, 59 },
                },
            },
            [xi.zone.SOUTH_GUSTABERG] =
            {
                event = 61,
                page =
                {
                    { 6, 0, 0, 0, 1, 6, 270, 76 },
                    { 7, 0, 0, 0, 2, 5, 285, 77 },
                    { 3, 3, 0, 0, 3, 6, 300, 78 },
                    { 7, 0, 0, 0, 3, 6, 315, 79 },
                    { 5, 2, 0, 0, 4, 8, 330, 80 },
                },
            },
            [xi.zone.KONSCHTAT_HIGHLANDS] =
            {
                event = 61,
                page =
                {
                    { 4, 2, 0, 0, 8, 11, 340, 81 },
                    { 4, 2, 0, 0, 9, 12, 360, 82 },
                    { 3, 3, 0, 0, 10, 12, 330, 20 },
                    { 6, 0, 0, 0, 9, 15, 380, 83 },
                    { 2, 2, 2, 0, 12, 14, 400, 84 },
                },
            },
            [xi.zone.PASHHOW_MARSHLANDS] =
            {
                event = 28,
                page =
                {
                    { 9, 0, 0, 0, 20, 21, 540, 21 },
                    { 8, 1, 0, 0, 20, 22, 570, 22 },
                    { 7, 2, 0, 0, 21, 23, 600, 23 },
                    { 6, 3, 0, 0, 22, 25, 630, 24 },
                    { 5, 4, 1, 0, 22, 25, 660, 60 },
                },
            },
            [xi.zone.ROLANBERRY_FIELDS] =
            {
                event = 61,
                page =
                {
                    { 5, 2, 0, 0, 25, 26, 670, 85 },
                    { 4, 3, 0, 0, 25, 28, 690, 25 },
                    { 6, 2, 0, 0, 26, 32, 710, 86 },
                    { 6, 2, 0, 0, 27, 33, 740, 87 },
                    { 5, 0, 0, 0, 36, 37, 800, 88 },
                },
            },
            [xi.zone.BEAUCEDINE_GLACIER] =
            {
                event = 218,
                page =
                {
                    { 9, 2, 0, 0, 34, 38, 810, 46 },
                    { 8, 3, 0, 0, 34, 39, 855, 47 },
                    { 7, 4, 0, 0, 37, 42, 900, 48 },
                    { 6, 4, 1, 0, 37, 43, 945, 49 },
                    { 5, 4, 2, 0, 40, 43, 990, 50 },
                },
            },
            [xi.zone.XARCABARD] =
            {
                event = 48,
                page =
                {
                    { 9, 3, 0, 0, 42, 46, 900, 51 },
                    { 8, 4, 0, 0, 42, 45, 950, 52 },
                    { 7, 4, 1, 0, 42, 48, 1000, 53 },
                    { 6, 4, 2, 0, 42, 48, 1050, 54 },
                    { 5, 4, 3, 0, 45, 52, 1100, 55 },
                },
            },
            [xi.zone.CAPE_TERIGGAN] =
            {
                event = 61,
                page =
                {
                    { 4, 4, 0, 0, 62, 66, 1300, 104 },
                    { 4, 5, 0, 0, 64, 68, 1320, 105 },
                    { 4, 5, 0, 0, 64, 69, 1340, 106 },
                    { 7, 3, 0, 0, 66, 74, 1390, 107 },
                    { 4, 5, 0, 0, 71, 79, 1450, 108 },
                },
            },
            [xi.zone.EASTERN_ALTEPA_DESERT] =
            {
                event = 61,
                page =
                {
                    { 10, 0, 0, 0, 30, 34, 810, 109 },
                    {  3, 1, 7, 0, 35, 40, 830, 110 },
                    {  3, 1, 7, 0, 35, 44, 870, 111 },
                    {  5, 2, 2, 1, 44, 49, 950, 112 },
                    {  3, 3, 2, 1, 45, 49, 970, 113 },
                },
            },
            [xi.zone.WEST_SARUTABARUTA] =
            {
                event = 52,
                page =
                {
                    { 6, 0, 0, 0, 1, 5, 270, 26 },
                    { 6, 0, 0, 0, 2, 5, 285, 27 },
                    { 5, 1, 0, 0, 3, 8, 300, 28 },
                    { 4, 2, 0, 0, 4, 8, 315, 29 },
                    { 4, 2, 0, 0, 4, 8, 330, 61 },
                },
            },
            [xi.zone.EAST_SARUTABARUTA] =
            {
                event = 61,
                page =
                {
                    { 6, 0, 0, 0, 1, 6, 270, 89 },
                    { 6, 0, 0, 0, 1, 8, 285, 90 },
                    { 6, 0, 0, 0, 2, 6, 300, 91 },
                    { 4, 2, 0, 0, 3, 6, 315, 92 },
                    { 4, 3, 0, 0, 3, 6, 330, 93 },
                },
            },
            [xi.zone.TAHRONGI_CANYON] =
            {
                event = 61,
                page =
                {
                    { 3, 3, 0, 0, 7, 12, 330, 30 },
                    { 8, 0, 0, 0, 11, 13, 450, 31 },
                    { 4, 2, 0, 0, 7, 11, 315, 94 },
                    { 3, 3, 0, 0, 8, 12, 370, 95 },
                    { 3, 4, 0, 0, 12, 16, 475, 96 },
                },
            },
            [xi.zone.BUBURIMU_PENINSULA] =
            {
                event = 51,
                page =
                {
                    { 7, 1, 0, 0, 15, 19, 475, 32 },
                    { 6, 2, 0, 0, 15, 23, 500, 33 },
                    { 5, 3, 0, 0, 20, 24, 525, 34 },
                    { 4, 4, 0, 0, 21, 24, 550, 35 },
                    { 4, 3, 0, 0, 22, 27, 575, 62 },
                },
            },
            [xi.zone.MERIPHATAUD_MOUNTAINS] =
            {
                event = 46,
                page =
                {
                    { 9, 0, 0, 0, 20, 21, 540, 36 },
                    { 8, 1, 0, 0, 20, 22, 570, 37 },
                    { 7, 2, 0, 0, 21, 23, 600, 38 },
                    { 6, 3, 0, 0, 22, 25, 630, 39 },
                    { 3, 5, 0, 0, 25, 27, 660, 63 },
                },
            },
            [xi.zone.SAUROMUGUE_CHAMPAIGN] =
            {
                event = 61,
                page =
                {
                    { 4, 3, 0, 0, 25, 28, 690, 40 },
                    { 4, 4, 0, 0, 26, 32, 710, 97 },
                    { 2, 5, 0, 0, 26, 34, 710, 98 },
                    { 3, 5, 0, 0, 27, 33, 730, 99 },
                    { 5, 3, 0, 0, 36, 38, 770, 100 },
                },
            },
            [xi.zone.THE_SANCTUARY_OF_ZITAH] =
            {
                event = 61,
                page =
                {
                    { 7, 2, 0, 0, 40, 44, 900, 114 },
                    { 7, 3, 0, 0, 41, 46, 940, 115 },
                    { 7, 3, 0, 0, 41, 46, 980, 116 },
                    { 7, 3, 0, 0, 42, 47, 1020, 117 },
                    { 3, 5, 0, 0, 44, 50, 1100, 118 },
                },
            },
            [xi.zone.ROMAEVE] =
            {
                event = 61,
                page =
                {
                    { 3, 3, 0, 0, 60, 65, 1300, 119 },
                    { 7, 0, 0, 0, 64, 69, 1330, 120 },
                    { 7, 0, 0, 0, 65, 69, 1360, 121 },
                    { 6, 1, 0, 0, 78, 82, 1540, 122 },
                    { 6, 1, 0, 0, 79, 82, 1570, 123 },
                },
            },
            [xi.zone.YUHTUNGA_JUNGLE] =
            {
                event = 61,
                page =
                {
                    {  4, 5, 0, 0, 30, 35, 820, 124 },
                    {  7, 4, 0, 0, 32, 37, 840, 125 },
                    { 10, 0, 0, 0, 34, 36, 860, 126 },
                    {  4, 6, 0, 0, 34, 38, 880, 127 },
                    {  4, 6, 0, 0, 34, 41, 920, 128 },
                },
            },
            [xi.zone.YHOATOR_JUNGLE] =
            {
                event = 61,
                page =
                {
                    {  3, 6, 0, 0, 35, 39, 840, 129 },
                    {  3, 6, 0, 0, 35, 40, 880, 130 },
                    { 10, 0, 0, 0, 40, 44, 920, 131 },
                    {  7, 3, 0, 0, 40, 46, 940, 132 },
                    { 10, 0, 0, 0, 45, 49, 1000, 133 },
                },
            },
            [xi.zone.WESTERN_ALTEPA_DESERT] =
            {
                event = 61,
                page =
                {
                    {  7, 3, 0, 0, 40, 45, 920, 134 },
                    {  5, 1, 4, 0, 44, 49, 980, 135 },
                    { 10, 1, 0, 0, 47, 53, 1020, 136 },
                    {  2, 8, 0, 0, 51, 56, 1080, 137 },
                    {  4, 6, 0, 0, 54, 58, 1140, 138 },
                },
            },
            [xi.zone.QUFIM_ISLAND] =
            {
                event = 33,
                page =
                {
                    { 9, 1, 0, 0, 26, 29, 630, 41 },
                    { 8, 2, 0, 0, 26, 29, 665, 42 },
                    { 7, 3, 0, 0, 28, 29, 700, 43 },
                    { 6, 4, 0, 0, 28, 30, 735, 44 },
                    { 5, 4, 1, 0, 28, 34, 770, 45 },
                },
            },
            [xi.zone.BEHEMOTHS_DOMINION] =
            {
                event = 61,
                page =
                {
                    { 3, 2, 0, 0, 41, 44, 350, 101 },
                    { 3, 2, 0, 0, 41, 46, 400, 102 },
                    { 3, 2, 0, 0, 43, 47, 450, 103 },
                },
            },
            [xi.zone.VALLEY_OF_SORROWS] =
            {
                event = 61,
                page =
                {
                    { 5, 2, 0, 0, 66, 72, 1220, 139 },
                    { 5, 1, 0, 0, 66, 74, 1260, 140 },
                    { 4, 1, 0, 0, 69, 74, 1300, 141 },
                },
            },
            [xi.zone.RUAUN_GARDENS] =
            {
                event = 73,
                page =
                {
                    {  8, 3, 0, 0, 72, 76, 1450, 142 },
                    {  8, 3, 0, 0, 73, 78, 1500, 143 },
                    { 11, 0, 0, 0, 75, 78, 1550, 144 },
                    {  2, 2, 2, 0, 78, 79, 1600, 145 },
                    {  2, 2, 2, 0, 78, 79, 1600, 146 },
                },
            },
        },
    },

    -----------------------------------
    -- Grounds of Valor information
    -----------------------------------

    [xi.regime.type.GROUNDS] =
    {
        sharedOptions =
        {
            [ 18] = { page = 1 },
            [ 34] = { page = 2 },
            [ 50] = { page = 3 },
            [ 66] = { page = 4 },
            [ 82] = { page = 5 },
            [ 98] = { page = 6 },
            [114] = { page = 7 },
            [130] = { page = 8 },
            [146] = { page = 9 },
            [162] = { page = 10 },
        },
        updateOptions =
        {
            [  1] = { review = true },
            [  5] = { details = true },
            [  7] = { prowess = true },
        },
        finishOptions =
        {
            [  3] = { act = 'CANCEL_REGIME',   cost =   0, discounted =   0 },
            [ 20] = { act = 'REPATRIATION',    cost =  50, discounted =  10 },
            [ 36] = { act = 'CIRCUMSPECTION',  cost =   5, discounted =   5 },
            [ 52] = { act = 'HOMING_INSTINCT', cost =  50, discounted =  25 },
            [ 68] = { act = 'RERAISE',         cost =  10, discounted =   5 },
            [ 84] = { act = 'RERAISE_II',      cost =  20, discounted =  10 },
            [100] = { act = 'RERAISE_III',     cost =  30, discounted =  15 },
            [116] = { act = 'REGEN',           cost =  20, discounted =  10 },
            [132] = { act = 'REFRESH',         cost =  20, discounted =  10 },
            [148] = { act = 'PROTECT',         cost =  15, discounted =   5 },
            [164] = { act = 'SHELL',           cost =  15, discounted =   5 },
            [180] = { act = 'HASTE',           cost =  20, discounted =  10 },
            [196] = { act = 'DRIED_MEAT',      cost =  50, discounted =  25, food = true },
            [212] = { act = 'SALTED_FISH',     cost =  50, discounted =  25, food = true },
            [228] = { act = 'HARD_COOKIE',     cost =  50, discounted =  25, food = true },
            [244] = { act = 'INSTANT_NOODLES', cost =  50, discounted =  25, food = true },
            [260] = { act = 'DRIED_AGARICUS',  cost =  50, discounted =  25, food = true },
            [276] = { act = 'INSTANT_RICE',    cost =  50, discounted =  25, food = true },
            [292] = { act = 'CIPHER_SAKURA',   cost = 300, discounted = 300 },
            [308] = { act = 'CIPHER_KORU',     cost = 300, discounted = 300 },
        },
        zone =
        {
            [xi.zone.THE_BOYAHDA_TREE] =
            {
                event = 17,
                page =
                {
                    { 3, 3, 0, 0, 60, 63, 1470, 719 },
                    { 4, 3, 0, 0, 62, 66, 1720, 720 },
                    { 4, 3, 0, 0, 62, 67, 1760, 721 },
                    { 4, 2, 0, 0, 72, 75, 1770, 722 },
                    { 3, 4, 0, 0, 72, 76, 1830, 723 },
                    { 4, 3, 0, 0, 72, 78, 1900, 724 },
                    { 3, 3, 0, 0, 74, 78, 1640, 725 },
                    { 2, 2, 2, 0, 102, 105, 2040, 726 },
                },
            },
            [xi.zone.MIDDLE_DELKFUTTS_TOWER] =
            {
                event = 18,
                page =
                {
                    { 4, 3, 0, 0, 25, 34, 1090, 782 },
                    { 4, 3, 0, 0, 25, 34, 1090, 783 },
                    { 4, 4, 0, 0, 30, 34, 1290, 784 },
                },
            },
            [xi.zone.UPPER_DELKFUTTS_TOWER] =
            {
                event = 20,
                page =
                {
                    { 6, 0, 0, 0, 34, 35, 1010, 785 },
                    { 2, 2, 2, 0, 62, 69, 1520, 786 },
                    { 2, 2, 2, 0, 62, 69, 1520, 787 },
                    { 2, 2, 2, 0, 65, 69, 1540, 788 },
                    { 2, 2, 2, 0, 65, 69, 1540, 789 },
                },
            },
            [xi.zone.TEMPLE_OF_UGGALEPIH] =
            {
                event = 83,
                page =
                {
                    { 3, 3, 0, 0, 51, 57, 1450, 790 },
                    { 4, 2, 0, 0, 51, 57, 1450, 791 },
                    { 4, 2, 0, 0, 51, 57, 1450, 792 },
                    { 3, 3, 0, 0, 61, 63, 1630, 793 },
                    { 3, 3, 0, 0, 61, 67, 1650, 794 },
                    { 3, 3, 0, 0, 61, 68, 1660, 795 },
                },
            },
            [xi.zone.DEN_OF_RANCOR] =
            {
                event = 13,
                page =
                {
                    { 3, 3, 0, 0, 60, 64, 1370, 796 },
                    { 4, 2, 0, 0, 60, 67, 1500, 797 },
                    { 6, 0, 0, 0, 62, 69, 1820, 798 },
                    { 4, 2, 0, 0, 62, 69, 1640, 799 },
                    { 4, 2, 0, 0, 62, 76, 1650, 800 },
                    { 5, 1, 0, 0, 73, 81, 1690, 801 },
                    { 3, 3, 0, 0, 74, 79, 1640, 802 },
                    { 4, 2, 0, 0, 75, 80, 1790, 803 },
                },
            },
            [xi.zone.RANGUEMONT_PASS] =
            {
                event = 24,
                page =
                {
                    { 4, 1, 0, 0,  3,  5, 270, 602 },
                    { 5, 1, 0, 0, 25, 30, 930, 603 },
                    { 4, 2, 0, 0, 26, 30, 860, 604 },
                    { 4, 2, 0, 0, 26, 30, 860, 605 },
                    { 4, 2, 0, 0, 30, 34, 970, 606 },
                    { 5, 2, 0, 0, 87, 92, 2260, 607 },
                    { 3, 3, 0, 0, 88, 90, 2260, 608 },
                    { 3, 3, 0, 0, 88, 90, 1850, 609 },
                },
            },
            [xi.zone.BOSTAUNIEUX_OUBLIETTE] =
            {
                event = 114,
                page =
                {
                    { 5, 0, 0, 0, 52, 54, 1110, 610 },
                    { 4, 2, 0, 0, 52, 59, 1320, 611 },
                    { 5, 1, 0, 0, 56, 63, 1430, 612 },
                    { 9, 0, 0, 0, 65, 68, 2050, 613 },
                    { 6, 1, 0, 0, 94, 97, 2300, 614 },
                    { 6, 1, 0, 0, 95, 97, 2300, 615 },
                    { 6, 0, 0, 0, 96, 97, 1960, 616 },
                    { 2, 5, 0, 0, 95, 99, 2480, 617 },
                },
            },
            [xi.zone.TORAIMARAI_CANAL] =
            {
                event = 100,
                page =
                {
                    { 3, 3, 0, 0, 47, 52, 1260, 618 },
                    { 2, 2, 2, 0, 52, 57, 1410, 619 },
                    { 3, 3, 0, 0, 53, 57, 1500, 620 },
                    { 3, 4, 0, 0, 60, 65, 1690, 621 },
                    { 4, 3, 0, 0, 95, 97, 2240, 622 },
                    { 5, 2, 0, 0, 95, 98, 2170, 623 },
                    { 5, 2, 0, 0, 96, 98, 2250, 624 },
                    { 8, 2, 0, 0, 94, 99, 2050, 625 },
                },
            },
            [xi.zone.ZERUHN_MINES] =
            {
                event = 210,
                page =
                {
                    { 3, 0, 0, 0,  1,  3,  90, 626 },
                    { 3, 0, 0, 0,  2,  4, 110, 627 },
                    { 5, 2, 0, 0, 75, 78, 1640, 628 },
                    { 5, 2, 0, 0, 75, 79, 1600, 629 },
                    { 5, 2, 0, 0, 75, 80, 1700, 630 },
                },
            },
            [xi.zone.KORROLOKA_TUNNEL] =
            {
                event = 4,
                page =
                {
                    { 2, 4, 0, 0, 20, 26, 780, 727 },
                    { 3, 3, 0, 0, 22, 30, 870, 728 },
                    { 4, 2, 0, 0, 23, 31, 950, 729 },
                    { 6, 0, 0, 0, 28, 31, 980, 730 },
                    { 3, 3, 0, 0, 29, 33, 930, 731 },
                    { 4, 0, 0, 0, 30, 33, 770, 732 },
                    { 6, 0, 0, 0, 35, 37, 1030, 733 },
                    { 4, 3, 0, 0, 87, 91, 2140, 734 },
                },
            },
            [xi.zone.KUFTAL_TUNNEL] =
            {
                event = 29,
                page =
                {
                    { 3, 3, 0, 0, 60, 64, 1440, 735 },
                    { 5, 1, 0, 0, 60, 66, 1480, 736 },
                    { 3, 3, 0, 0, 60, 66, 1380, 737 },
                    { 4, 2, 0, 0, 60, 67, 1550, 738 },
                    { 3, 3, 0, 0, 63, 69, 1410, 739 },
                    { 3, 3, 0, 0, 65, 69, 1540, 740 },
                    { 3, 3, 0, 0, 77, 80, 1660, 741 },
                    { 3, 3, 0, 0, 99, 103, 1900, 742 },
                },
            },
            [xi.zone.SEA_SERPENT_GROTTO] =
            {
                event = 24,
                page =
                {
                    { 3, 3, 0, 0, 35, 39, 1040, 804 },
                    { 2, 4, 0, 0, 37, 41, 1050, 805 },
                    { 5, 1, 0, 0, 41, 45, 1180, 806 },
                    { 4, 2, 0, 0, 43, 48, 1190, 807 },
                    { 4, 2, 0, 0, 44, 48, 1220, 808 },
                    { 3, 3, 0, 0, 62, 67, 1470, 809 },
                    { 3, 3, 0, 0, 62, 69, 1480, 810 },
                    { 3, 3, 0, 0, 66, 69, 1500, 811 },
                },
            },
            [xi.zone.VELUGANNON_PALACE] =
            {
                event = 4,
                page =
                {
                    { 10, 0, 0, 0, 72, 72, 2390, 743 },
                    {  7, 0, 0, 0, 74, 77, 1900, 744 },
                    {  7, 0, 0, 0, 75, 78, 1920, 745 },
                    {  7, 0, 0, 0, 76, 79, 2120, 746 },
                    {  7, 0, 0, 0, 77, 80, 2230, 747 },
                    {  6, 0, 0, 0, 79, 80, 2180, 748 },
                },
            },
            [xi.zone.THE_SHRINE_OF_RUAVITAU] =
            {
                event = 61,
                page =
                {
                    { 10, 0, 0, 0, 71, 71, 2370, 749 },
                    {  6, 0, 0, 0, 71, 74, 2080, 750 },
                    {  7, 0, 0, 0, 75, 80, 1930, 751 },
                    {  7, 0, 0, 0, 77, 82, 2150, 752 },
                    {  7, 0, 0, 0, 79, 82, 2050, 753 },
                    {  7, 0, 0, 0, 81, 84, 2390, 754 },
                },
            },
            [xi.zone.LOWER_DELKFUTTS_TOWER] =
            {
                event = 40,
                page =
                {
                    { 3, 3, 0, 0, 25, 30, 900, 777 },
                    { 3, 3, 0, 0, 25, 30, 900, 778 },
                    { 3, 3, 0, 0, 25, 30, 930, 779 },
                    { 4, 2, 0, 0, 25, 32, 980, 780 },
                    { 4, 2, 0, 0, 25, 35, 940, 781 },
                },
            },
            [xi.zone.KING_RANPERRES_TOMB] =
            {
                event = 100,
                page =
                {
                    { 3, 3, 0, 0,  3,  8, 380, 631 },
                    { 4, 2, 0, 0,  5, 11, 420, 632 },
                    { 2, 2, 2, 0, 12, 16, 610, 633 },
                    { 3, 3, 0, 0, 14, 17, 590, 634 },
                    { 2, 2, 2, 0, 21, 23, 864, 635 },
                    { 6, 1, 0, 0, 78, 80, 1520, 636 },
                    { 5, 2, 0, 0, 77, 80, 1690, 637 },
                    { 5, 2, 0, 0, 80, 83, 1720, 638 },
                },
            },
            [xi.zone.DANGRUF_WADI] =
            {
                event = 160,
                page =
                {
                    { 4, 1, 0, 0,  3,  8, 280, 639 },
                    { 3, 2, 0, 0,  5,  9, 350, 640 },
                    { 3, 2, 0, 0, 11, 14, 490, 641 },
                    { 4, 2, 0, 0, 86, 89, 1830, 642 },
                    { 5, 2, 0, 0, 86, 90, 1650, 643 },
                    { 5, 2, 0, 0, 86, 90, 1840, 644 },
                    { 2, 2, 2, 0, 90, 91, 1860, 645 },
                    { 5, 2, 0, 0, 90, 93, 2260, 646 },
                },
            },
            [xi.zone.INNER_HORUTOTO_RUINS] =
            {
                event = 100,
                page =
                {
                    { 2, 3, 0, 0,  1,  6, 250, 647 },
                    { 2, 3, 0, 0,  1,  7, 270, 648 },
                    { 3, 2, 0, 0, 15, 20, 610, 649 },
                    { 4, 2, 0, 0, 22, 26, 840, 650 },
                    { 3, 3, 0, 0, 78, 82, 1750, 651 },
                    { 3, 3, 0, 0, 79, 82, 1760, 652 },
                    { 2, 4, 0, 0, 81, 83, 1770, 653 },
                    { 2, 4, 0, 0, 81, 84, 1780, 654 },
                },
            },
            [xi.zone.ORDELLES_CAVES] =
            {
                event = 100,
                page =
                {
                    { 3, 3, 0, 0, 18, 21, 730, 655 },
                    { 4, 2, 0, 0, 21, 27, 840, 656 },
                    { 5, 1, 0, 0, 17, 26, 800, 657 },
                    { 3, 3, 0, 0, 23, 26, 850, 658 },
                    { 4, 2, 0, 0, 26, 28, 950, 659 },
                    { 4, 1, 0, 0, 29, 34, 830, 660 },
                    { 3, 3, 0, 0, 84, 86, 1810, 661 },
                    { 3, 3, 0, 0, 86, 88, 1890, 662 },
                },
            },
            [xi.zone.OUTER_HORUTOTO_RUINS] =
            {
                event = 110,
                page =
                {
                    { 1, 1, 1, 1, 10, 14, 340, 663 },
                    { 1, 1, 1, 1, 15, 19, 450, 664 },
                    { 1, 1, 1, 1, 20, 24, 540, 665 },
                    { 1, 1, 1, 1, 25, 29, 590, 666 },
                    { 1, 1, 1, 1, 30, 34, 650, 667 },
                    { 1, 1, 1, 1, 35, 39, 700, 668 },
                    { 5, 1, 0, 0, 81, 85, 1840, 669 },
                    { 5, 1, 0, 0, 82, 85, 1850, 670 },
                },
            },
            [xi.zone.THE_ELDIEME_NECROPOLIS] =
            {
                event = 100,
                page =
                {
                    { 6, 0, 0, 0, 42, 46, 950, 671 },
                    { 6, 0, 0, 0, 46, 49, 1030, 672 },
                    { 4, 2, 0, 0, 51, 54, 1300, 673 },
                    { 5, 1, 0, 0, 50, 55, 1340, 674 },
                    { 3, 3, 0, 0, 53, 56, 1330, 675 },
                    { 3, 3, 0, 0, 60, 63, 1470, 676 },
                    { 3, 3, 0, 0, 91, 95, 1890, 677 },
                    { 3, 3, 0, 0, 91, 95, 1890, 678 },
                },
            },
            [xi.zone.GUSGEN_MINES] =
            {
                event = 100,
                page =
                {
                    { 6, 0, 0, 0, 20, 27, 660, 679 },
                    { 2, 4, 0, 0, 20, 24, 800, 680 },
                    { 2, 4, 0, 0, 21, 26, 790, 681 },
                    { 2, 2, 2, 0, 28, 31, 1050, 682 },
                    { 3, 3, 0, 0, 30, 34, 970, 683 },
                    { 3, 3, 0, 0, 32, 36, 1000, 684 },
                    { 2, 5, 0, 0, 85, 87, 1890, 685 },
                    { 2, 5, 0, 0, 85, 89, 2180, 686 },
                },
            },
            [xi.zone.CRAWLERS_NEST] =
            {
                event = 100,
                page =
                {
                    { 3, 3, 0, 0, 40, 44, 1160, 687 },
                    { 3, 3, 0, 0, 45, 49, 1230, 688 },
                    { 3, 3, 0, 0, 49, 52, 1280, 689 },
                    { 4, 2, 0, 0, 50, 54, 1300, 690 },
                    { 2, 2, 2, 0, 53, 58, 1340, 691 },
                    { 3, 3, 0, 0, 59, 63, 1470, 692 },
                    { 4, 3, 0, 0, 91, 93, 2190, 693 },
                    { 4, 3, 0, 0, 92, 96, 2220, 694 },
                },
            },
            [xi.zone.MAZE_OF_SHAKHRAMI] =
            {
                event = 100,
                page =
                {
                    { 3, 2, 0, 0, 15, 18, 550, 695 },
                    { 4, 2, 0, 0, 18, 23, 700, 696 },
                    { 2, 4, 0, 0, 22, 26, 840, 697 },
                    { 2, 4, 0, 0, 26, 31, 920, 698 },
                    { 4, 2, 0, 0, 26, 31, 820, 699 },
                    { 5, 1, 0, 0, 27, 33, 840, 700 },
                    { 3, 3, 0, 0, 83, 85, 1840, 701 },
                    { 3, 3, 0, 0, 86, 88, 1830, 702 },
                },
            },
            [xi.zone.GARLAIGE_CITADEL] =
            {
                event = 110,
                page =
                {
                    { 4, 2, 0, 0, 40, 43, 1160, 703 },
                    { 4, 2, 0, 0, 40, 44, 1160, 704 },
                    { 2, 4, 0, 0, 46, 49, 1240, 705 },
                    { 4, 2, 0, 0, 51, 55, 1310, 706 },
                    { 3, 3, 0, 0, 52, 58, 1330, 707 },
                    { 2, 2, 1, 0, 59, 62, 1270, 708 },
                    { 5, 2, 0, 0, 91, 96, 1840, 709 },
                    { 4, 3, 0, 0, 92, 96, 2220, 710 },
                },
            },
            [xi.zone.FEIYIN] =
            {
                event = 100,
                page =
                {
                    { 4, 2, 0, 0, 40, 43, 1180, 711 },
                    { 4, 2, 0, 0, 43, 46, 1240, 712 },
                    { 5, 1, 0, 0, 50, 55, 1310, 713 },
                    { 4, 2, 0, 0, 50, 56, 1310, 714 },
                    { 5, 1, 0, 0, 50, 58, 1340, 715 },
                    { 3, 3, 0, 0, 59, 63, 1470, 716 },
                    { 4, 2, 0, 0, 95, 99, 2060, 717 },
                    { 4, 3, 0, 0, 95, 99, 2250, 718 },
                },
            },
            [xi.zone.IFRITS_CAULDRON] =
            {
                event = 51,
                page =
                {
                    { 4, 1, 0, 0, 61, 68, 1270, 755 },
                    { 4, 1, 0, 0, 61, 68, 1570, 756 },
                    { 4, 1, 0, 0, 62, 69, 1280, 757 },
                    { 3, 2, 0, 0, 62, 73, 1310, 758 },
                    { 3, 2, 0, 0, 62, 73, 1380, 759 },
                    { 4, 2, 0, 0, 69, 74, 1610, 760 },
                    { 4, 2, 0, 0, 71, 78, 1650, 761 },
                    { 4, 2, 0, 0, 71, 78, 1760, 762 },
                },
            },
            [xi.zone.QUICKSAND_CAVES] =
            {
                event = 15,
                page =
                {
                    { 3, 3, 0, 0, 51, 55, 1310, 812 },
                    { 3, 3, 0, 0, 51, 58, 1360, 813 },
                    { 3, 3, 0, 0, 51, 59, 1230, 814 },
                    { 7, 0, 0, 0, 52, 59, 1480, 815 },
                    { 3, 3, 0, 0, 52, 59, 1470, 816 },
                    { 3, 3, 0, 0, 56, 59, 1360, 817 },
                    { 3, 3, 0, 0, 62, 65, 1570, 818 },
                    { 3, 3, 0, 0, 65, 69, 1540, 819 },
                },
            },
            [xi.zone.GUSTAV_TUNNEL] =
            {
                event = 17,
                page =
                {
                    { 2, 2, 1, 0, 44, 49, 1040, 763 },
                    { 2, 2, 2, 0, 45, 49, 1230, 764 },
                    { 3, 2, 1, 0, 65, 68, 1490, 765 },
                    { 3, 3, 0, 0, 73, 76, 1620, 766 },
                    { 5, 1, 0, 0, 75, 78, 1700, 767 },
                    { 5, 1, 0, 0, 75, 79, 1680, 768 },
                    { 4, 2, 0, 0, 76, 80, 1710, 769 },
                    { 5, 2, 0, 0, 100, 103, 2310, 770 },
                },
            },
            [xi.zone.LABYRINTH_OF_ONZOZO] =
            {
                event = 3,
                page =
                {
                    { 2, 3, 0, 0, 45, 49, 1050, 771 },
                    { 3, 2, 0, 0, 50, 53, 1070, 772 },
                    { 3, 2, 0, 0, 50, 54, 1140, 773 },
                    { 3, 2, 0, 0, 55, 59, 1130, 774 },
                    { 4, 1, 0, 0, 70, 74, 1350, 775 },
                    { 4, 2, 0, 0, 95, 98, 1920, 776 },
                },
            },
        },
    },
}

local function getPageByRegimeId(regimeType, zoneId, regimeId)
    local info = regimeInfo[regimeType]
    if not info then
        return nil
    end

    info = info.zone[zoneId]
    if not info then
        return nil
    end

    info = info.page
    if not info then
        return nil
    end

    for _, v in pairs(info) do
        if v[8] == regimeId then
            return v
        end
    end

    return nil
end

-- ===================================================================
-- End of duplicated data/helper. Everything below is our own logic.
-- ===================================================================

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