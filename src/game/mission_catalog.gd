class_name MissionCatalog
extends RefCounted
## backend/MissionCatalog.cs - MISSNSD.DAT as data (data/missions.json).

static var _by_id: Dictionary = {}   # shipped mission id -> MissionDef

## The ids this codebase needs by name.
const Dagobah := 0x43
const Palace := 0x44

## MissionType is ordinal; this is the join with MISSNSD's own ids.
const _ids := {
	Enums.MissionType.Diplomacy:              0x10,
	Enums.MissionType.Rescue:                 0x11,
	Enums.MissionType.Sabotage:               0x12,
	Enums.MissionType.Espionage:              0x13,
	Enums.MissionType.Reconnaissance:         0x15,
	Enums.MissionType.Recruitment:            0x16,
	Enums.MissionType.Abduction:              0x17,
	Enums.MissionType.ShipDesignResearch:     0x20,
	Enums.MissionType.FacilityDesignResearch: 0x21,
	Enums.MissionType.TroopTrainingResearch:  0x22,
	Enums.MissionType.InciteUprising:         0x40,
	Enums.MissionType.DeathStarSabotage:      0x41,
	Enums.MissionType.JediTraining:           0x42,
	Enums.MissionType.SubdueUprising:         0x80,
	Enums.MissionType.Assassination:          0x81,
}


static func IdFor(type: int) -> int:
	return _ids.get(type, -1)


static func RollLength(type: int, rng: Prng, fallback: int) -> int:
	return RollLengthById(IdFor(type), rng, fallback)


## "Do you wish the mission to continue?" - col 12. Null when the pack ships no
## MISSNSD, so the caller can fall back rather than read a missing table as
## "nothing is persistent".
static func CanContinue(type: int) -> Variant:
	var d := Get(IdFor(type))
	return null if d == null else d.CanContinue != 0


static func Load(path: String) -> void:
	_by_id.clear()
	if not FileAccess.file_exists(path):
		push_error("ERROR: Could not find mission definitions at %s!" % path)
		return
	for d in Loaders._list(path, CatalogDtos.MissionDef.from_dict):
		_by_id[d.MissionId] = d
	print("Successfully loaded %d mission definitions." % _by_id.size())


static func Get(mission_id: int) -> CatalogDtos.MissionDef:
	return _by_id.get(mission_id)


## base + rand(0..spread), inclusive at both ends, matching RuleManager.Roll.
## Falls back to the supplied default when a pack ships no MISSNSD.
static func RollLengthById(mission_id: int, rng: Prng, fallback: int) -> int:
	var d := Get(mission_id)
	if d == null or d.LengthBase <= 0:
		return fallback
	var extra := 0
	if d.LengthSpread > 0:
		assert(rng != null, "MissionCatalog.RollLength: null rng")   # fails loudly on purpose
		extra = rng.NextRange(0, d.LengthSpread + 1)
	return d.LengthBase + extra
