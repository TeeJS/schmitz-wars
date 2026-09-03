class_name BlockadeManager
extends RefCounted
## backend/BlockadeManager.cs - PARTIAL (HANDOFF step 1B). The predicate the
## Planet tick reads is ported; the daily drift, the withdrawal percentage and
## the blockade-running roll are STEP 2 and no-ops until then.

static var _next_drift: Dictionary = {}


static func Reset() -> void:
	_next_drift.clear()


## Which side, if any, is blockading this world right now. Derived every time it
## is asked, never latched. "Any time a fleet is in orbit above an ENEMY OR
## NEUTRAL system" - an unpopulated neutral world has nothing to blockade; if
## both sides are present this is a battle, not a blockade.
static func BlockaderOf(p: Planet) -> Faction:
	if p == null or p.ControllingFaction == null:
		return null
	var neutral := p.ControllingFaction == FactionRegistry.Neutral
	if neutral and not p.IsInhabited:
		return null

	var in_orbit := p.FleetsInOrbit()
	var present := func(f: Faction) -> bool:
		return Lq.any(in_orbit, func(x): return x.Faction == f and not x.IsEmpty()) \
			or Lq.any(p.FighterSquadrons, func(u): return u.Faction == f)

	var sides := 0
	for f in FactionRegistry.Playable:
		if present.call(f):
			sides += 1
	if sides > 1:
		return null

	for x in in_orbit:
		if not x.IsEmpty() and x.Faction != null and x.Faction != p.ControllingFaction:
			return x.Faction
	return null


static func IsBlockaded(p: Planet) -> bool:
	return BlockaderOf(p) != null


## STUB - step 2.
static func ProcessDay(_galaxy: Array, _day: int, _rng: Prng) -> void:
	pass
