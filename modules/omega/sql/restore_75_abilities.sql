-- Retag sub-75 SOA/ROV/ABYSSEA job abilities to WOTG
-- for a 75-cap / pre-Seekers of Adoulin classic server.
-- Generated from LandSandBoat sql/abilities.sql — matches abilityId + job + level + old content_tag
-- so only the exact identified rows are touched.


-- PLD
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 394 AND `job` = 7 AND `level` = 70 AND `content_tag` = 'ROV'; -- majesty

-- DRK
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 389 AND `job` = 8 AND `level` = 55 AND `content_tag` = 'ROV'; -- consume_mana

-- BST
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 387 AND `job` = 9 AND `level` = 23 AND `content_tag` = 'SOA'; -- bestial_loyalty

-- SAM
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 320 AND `job` = 12 AND `level` = 65 AND `content_tag` = 'ABYSSEA'; -- konzen-ittai

-- DRG
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 393 AND `job` = 14 AND `level` = 65 AND `content_tag` = 'ROV'; -- spirit_bond

-- SMN
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 521 AND `job` = 15 AND `level` = 1 AND `content_tag` = 'SOA'; -- regal_scratch
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 527 AND `job` = 15 AND `level` = 1 AND `content_tag` = 'SOA'; -- altana_s_favor
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 960 AND `job` = 15 AND `level` = 1 AND `content_tag` = 'ROV'; -- clarsach_call
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 961 AND `job` = 15 AND `level` = 1 AND `content_tag` = 'ROV'; -- welt
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 962 AND `job` = 15 AND `level` = 1 AND `content_tag` = 'ROV'; -- katabatic_blades
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 963 AND `job` = 15 AND `level` = 1 AND `content_tag` = 'ROV'; -- lunatic_voice
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 965 AND `job` = 15 AND `level` = 1 AND `content_tag` = 'ROV'; -- chinook
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 966 AND `job` = 15 AND `level` = 1 AND `content_tag` = 'ROV'; -- bitter_elegy
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 525 AND `job` = 15 AND `level` = 15 AND `content_tag` = 'SOA'; -- raise_ii
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 522 AND `job` = 15 AND `level` = 25 AND `content_tag` = 'SOA'; -- mewing_lullaby
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 964 AND `job` = 15 AND `level` = 25 AND `content_tag` = 'ROV'; -- roundhouse
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 526 AND `job` = 15 AND `level` = 30 AND `content_tag` = 'SOA'; -- reraise_ii
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 523 AND `job` = 15 AND `level` = 55 AND `content_tag` = 'SOA'; -- eerie_eye
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 967 AND `job` = 15 AND `level` = 65 AND `content_tag` = 'ROV'; -- sonic_buffet
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 385 AND `job` = 15 AND `level` = 70 AND `content_tag` = 'SOA'; -- apogee
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 524 AND `job` = 15 AND `level` = 75 AND `content_tag` = 'SOA'; -- level_X_holy
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 968 AND `job` = 15 AND `level` = 75 AND `content_tag` = 'ROV'; -- tornado_ii

-- COR
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 390 AND `job` = 17 AND `level` = 67 AND `content_tag` = 'ROV'; -- naturalists_roll
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 391 AND `job` = 17 AND `level` = 70 AND `content_tag` = 'ROV'; -- runeists_roll

-- PUP
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 310 AND `job` = 18 AND `level` = 5 AND `content_tag` = 'ABYSSEA'; -- deus_ex_automata
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 322 AND `job` = 18 AND `level` = 30 AND `content_tag` = 'ABYSSEA'; -- maintenance

-- DNC
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 384 AND `job` = 19 AND `level` = 50 AND `content_tag` = 'SOA'; -- contradance
UPDATE `abilities` SET `content_tag` = 'WOTG' WHERE `abilityId` = 381 AND `job` = 19 AND `level` = 70 AND `content_tag` = 'SOA'; -- chocobo_jig_ii