class_name LoyaltyManager
extends RefCounted
## backend/LoyaltyManager.cs - PARTIAL (HANDOFF step 1B). What Mission and
## Character need is here: the traitor threshold and the Force ferret. The daily
## loyalty drift (ProcessDay) is a STEP 2 port and is a no-op until then.

## ⚠ fitted, no entry exists (see the source's calibration note).
const TraitorThreshold := 15


## "CHARACTERS STRONG IN THE FORCE CAN ALSO FERRET OUT TRAITORS IN A PARTY" (p094).
static func FerretOutTraitors(team: Array) -> Array:
	var found: Array = []
	if team == null:
		return found
	var people := Lq.of_type_character(team)
	var strong := Lq.any(people, func(c): return c.ForceRank() == Enums.ForceRanking.JediKnight or c.ForceRank() == Enums.ForceRanking.JediMaster)
	if not strong:
		return found
	for c in people:
		if not c.IsTraitorous() or c.TraitorRevealed:
			continue
		c.TraitorRevealed = true
		found.append(c)
	return found


## STUB - step 2. The source drifts every character's loyalty toward galaxy-wide
## support and applies the manual's shocks. Not ported yet; deliberately no-op.
static func ProcessDay(_galaxy: Array) -> void:
	pass
