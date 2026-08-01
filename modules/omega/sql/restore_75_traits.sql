-- Retag sub-75 SOA/ROV/ABYSSEA trait ranks to WOTG
-- for a 75-cap / pre-Seekers of Adoulin classic server.
-- Generated from LandSandBoat sql/traits.sql — matches job + name + level + old content_tag
-- so only the exact identified rows are touched.


-- WAR
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'max hp boost' AND `level` = 30 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'smite' AND `level` = 35 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'damage limit+' AND `level` = 40 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'defense bonus' AND `level` = 45 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'fencer' AND `level` = 45 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'max hp boost' AND `level` = 50 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'double attack' AND `level` = 50 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'fencer' AND `level` = 58 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'attack bonus' AND `level` = 65 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'smite' AND `level` = 65 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'max hp boost' AND `level` = 70 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'fencer' AND `level` = 71 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 1 AND `name` = 'double attack' AND `level` = 75 AND `content_tag` = 'ABYSSEA';

-- MNK
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 2 AND `name` = 'damage limit+' AND `level` = 30 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 2 AND `name` = 'smite' AND `level` = 40 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 2 AND `name` = 'max hp boost' AND `level` = 55 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 2 AND `name` = 'damage limit+' AND `level` = 60 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 2 AND `name` = 'max hp boost' AND `level` = 65 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 2 AND `name` = 'max hp boost II' AND `level` = 75 AND `content_tag` = 'ROV';

-- WHM
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 3 AND `name` = 'tranquil heart' AND `level` = 21 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 3 AND `name` = 'divine benison' AND `level` = 50 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 3 AND `name` = 'divine benison' AND `level` = 60 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 3 AND `name` = 'divine benison' AND `level` = 70 AND `content_tag` = 'ABYSSEA';

-- BLM
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 4 AND `name` = 'mag. burst bonus' AND `level` = 45 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 4 AND `name` = 'elemental celerity' AND `level` = 50 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 4 AND `name` = 'mag. burst bonus' AND `level` = 58 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 4 AND `name` = 'elemental celerity' AND `level` = 60 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 4 AND `name` = 'elemental celerity' AND `level` = 70 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 4 AND `name` = 'mag. burst bonus' AND `level` = 71 AND `content_tag` = 'ABYSSEA';

-- RDM
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 5 AND `name` = 'tranquil heart' AND `level` = 26 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 5 AND `name` = 'damage limit+' AND `level` = 60 AND `content_tag` = 'ROV';

-- THF
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 6 AND `name` = 'damage limit+' AND `level` = 50 AND `content_tag` = 'ROV';

-- PLD
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 7 AND `name` = 'max hp boost' AND `level` = 45 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 7 AND `name` = 'shield barrier' AND `level` = 70 AND `content_tag` = 'ROV';

-- DRK
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'smite' AND `level` = 15 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'damage limit+' AND `level` = 20 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'desperate blows' AND `level` = 30 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'smite' AND `level` = 35 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'damage limit+' AND `level` = 40 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'desperate blows' AND `level` = 45 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'occult acumen' AND `level` = 45 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'stalwart soul' AND `level` = 45 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'smite' AND `level` = 55 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'damage limit+' AND `level` = 55 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'occult acumen' AND `level` = 58 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'stalwart soul' AND `level` = 60 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'damage limit+' AND `level` = 70 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'occult acumen' AND `level` = 71 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'stalwart soul' AND `level` = 75 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 8 AND `name` = 'smite' AND `level` = 75 AND `content_tag` = 'SOA';

-- BST
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'resist amnesia' AND `level` = 15 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'tandem strike' AND `level` = 30 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'resist amnesia' AND `level` = 35 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'tandem blow' AND `level` = 40 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'damage limit+' AND `level` = 45 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'tandem strike' AND `level` = 45 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'resist amnesia' AND `level` = 55 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'tandem strike' AND `level` = 60 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'tandem blow' AND `level` = 60 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'resist amnesia' AND `level` = 75 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 9 AND `name` = 'tandem strike' AND `level` = 75 AND `content_tag` = 'ROV';

-- RNG
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 11 AND `name` = 'recycle' AND `level` = 20 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 11 AND `name` = 'damage limit+' AND `level` = 30 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 11 AND `name` = 'recycle' AND `level` = 35 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 11 AND `name` = 'recycle' AND `level` = 50 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 11 AND `name` = 'dead aim' AND `level` = 50 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 11 AND `name` = 'dead aim' AND `level` = 60 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 11 AND `name` = 'damage limit+' AND `level` = 60 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 11 AND `name` = 'dead aim' AND `level` = 70 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 11 AND `name` = 'rapid shot' AND `level` = 71 AND `content_tag` = 'SOA';

-- SAM
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 12 AND `name` = 'damage limit+' AND `level` = 40 AND `content_tag` = 'ROV';

-- NIN
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 13 AND `name` = 'max hp boost' AND `level` = 20 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 13 AND `name` = 'daken' AND `level` = 25 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 13 AND `name` = 'max hp boost' AND `level` = 40 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 13 AND `name` = 'daken' AND `level` = 40 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 13 AND `name` = 'damage limit+' AND `level` = 50 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 13 AND `name` = 'daken' AND `level` = 55 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 13 AND `name` = 'max hp boost' AND `level` = 60 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 13 AND `name` = 'daken' AND `level` = 70 AND `content_tag` = 'SOA';

-- DRG
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'damage limit+' AND `level` = 30 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'strafe' AND `level` = 40 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'smite' AND `level` = 40 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'conserve tp' AND `level` = 45 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'ws damage boost' AND `level` = 45 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'ws damage boost' AND `level` = 55 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'conserve tp' AND `level` = 58 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'strafe' AND `level` = 60 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'damage limit+' AND `level` = 60 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'ws damage boost' AND `level` = 65 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'conserve tp' AND `level` = 71 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 14 AND `name` = 'ws damage boost' AND `level` = 75 AND `content_tag` = 'ROV';

-- SMN
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 15 AND `name` = 'blood boon' AND `level` = 60 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 15 AND `name` = 'blood boon' AND `level` = 70 AND `content_tag` = 'ABYSSEA';

-- COR
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 17 AND `name` = 'resist amnesia' AND `level` = 30 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 17 AND `name` = 'recycle' AND `level` = 35 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 17 AND `name` = 'resist amnesia' AND `level` = 50 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 17 AND `name` = 'recycle' AND `level` = 65 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 17 AND `name` = 'resist amnesia' AND `level` = 70 AND `content_tag` = 'ABYSSEA';

-- PUP
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 18 AND `name` = 'resist amnesia' AND `level` = 15 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 18 AND `name` = 'resist amnesia' AND `level` = 35 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 18 AND `name` = 'damage limit+' AND `level` = 45 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 18 AND `name` = 'resist amnesia' AND `level` = 55 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 18 AND `name` = 'smite' AND `level` = 60 AND `content_tag` = 'SOA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 18 AND `name` = 'resist amnesia' AND `level` = 75 AND `content_tag` = 'ABYSSEA';

-- DNC
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 19 AND `name` = 'dual wield' AND `level` = 20 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 19 AND `name` = 'dual wield' AND `level` = 40 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 19 AND `name` = 'skillchain bonus' AND `level` = 45 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 19 AND `name` = 'damage limit+' AND `level` = 45 AND `content_tag` = 'ROV';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 19 AND `name` = 'skillchain bonus' AND `level` = 58 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 19 AND `name` = 'dual wield' AND `level` = 60 AND `content_tag` = 'ABYSSEA';
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 19 AND `name` = 'skillchain bonus' AND `level` = 71 AND `content_tag` = 'ABYSSEA';

-- SCH
UPDATE `traits` SET `content_tag` = 'WOTG' WHERE `job` = 20 AND `name` = 'tranquil heart' AND `level` = 30 AND `content_tag` = 'ABYSSEA';