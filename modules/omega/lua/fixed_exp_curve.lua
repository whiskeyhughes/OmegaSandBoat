-----------------------------------
-- Original EXP curve for the base game (CORRECTED GATE)
-- Date : 2011-02-14
-- https://www.bg-wiki.com/ffxi/Version_Update_(02/14/2011)
-- Use in tandem with modules/wotg/sql/2007_exp_tables.sql
-----------------------------------
-- This is a fixed copy of era/lua/globals/exp_curve.lua.
-- The original file gates off at 'WOTG', but the patch it reverts
-- (02/14/2011) falls in the ABYSSEA era window per the module
-- README (ABYSSEA: June 2010 - February 2013). That means the
-- original file disables itself as soon as WOTG content is enabled,
-- roughly 3.5 years before the patch it's supposed to be reverting.
--
-- This copy gates off at 'ABYSSEA' instead, so it stays active
-- through the full WotG era, matching wotg/sql/2007_exp_tables.sql
-- (which has no gating and always applies). Without this fix, mobs
-- would /check with difficulty ratings that don't match the actual
-- (reverted) EXP values in the DB.
--
-- NOTE: Do NOT also load era/lua/globals/exp_curve.lua alongside
-- this file -- pick one or the other, since both register the same
-- override (xi.expDifficultyCurve.loadExpDifficultyCurve).
-----------------------------------
require('modules/module_utils')
-----------------------------------

local moduleName = 'original_exp_curve_fixed'

if xi.module.isContentEnabled('ABYSSEA') then
    return { name = moduleName }
end

local m = Module:new(moduleName)

m:addOverride('xi.expDifficultyCurve.loadExpDifficultyCurve', function()
    local incrediblyEasyPreyLevel  = 255
    local incrediblyEasyPreyMinExp = 65535

    -- exp value >= returns X difficulty
    -- [exp] = xi.mobDifficulty
    local expToDifficultyTable =
    {
        [400] = xi.mobDifficulty.INCREDIBLY_TOUGH,
        [200] = xi.mobDifficulty.VERY_TOUGH,
        [120] = xi.mobDifficulty.TOUGH,
        [100] = xi.mobDifficulty.EVEN_MATCH,
        [50]  = xi.mobDifficulty.DECENT_CHALLENGE,
        [15]  = xi.mobDifficulty.EASY_PREY,
        -- Nothing below 15 so that is too weak
    }

    -- Load into C++
    LoadExpDifficultyCurves(expToDifficultyTable, incrediblyEasyPreyLevel, incrediblyEasyPreyMinExp)
end)

return m