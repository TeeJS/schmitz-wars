class_name GameSettings
extends RefCounted
## backend/GameSettings.cs - the choices made on the menu, plus the session seed.

static var SelectedDifficulty: Enums.Difficulty = Enums.Difficulty.Medium
## No default: the pack decides which factions exist, so this is only valid once
## the menu has chosen one from FactionRegistry.Playable.
static var PlayerFaction: Faction = null
static var SelectedSize: Enums.GalaxySize = Enums.GalaxySize.Large
static var HQOnlyVictory: bool = false

## The session's PRNG seed - see Prng. Printed at start; --seed=N replays.
static var Seed: int = 0
