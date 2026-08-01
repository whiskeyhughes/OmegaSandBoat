# Omega Campaign vertical slice

This module adds a playable Campaign Battle in North Gustaberg [S].

## Included

- Any player enlisted with San d'Oria, Bastok, or Windurst can participate.
- Uriah, C.A. issues Allied Tags during an active battle.
- Talking to Uriah while tagged performs an interim assessment.
- Bastokan and Quadav forces are created as dynamic entities.
- Direct damage and kills against Campaign enemies produce contribution.
- The Quadav commander ends the battle in an Allied victory.
- Timeout ends the battle after 30 minutes.
- Rewards are EXP plus Allied Notes, with a level multiplier and an 80 points/minute cap.
- Automatic cooldown is randomized between 30 and 60 minutes.

## GM testing

```text
!campaign start
!campaign status
!campaign eval
!campaign stop
```

Enlist a test player first if necessary:

```text
!cnation PlayerName 1
!cnation PlayerName 2
!cnation PlayerName 3
```

## Current limitations

This first slice tracks damage and kills. Healing, buffs, debuffs, damage taken,
shadow prevention, medals, fortification objectives, and persistent regional
influence are intentionally reserved for the next milestone.
