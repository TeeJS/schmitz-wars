class_name FacilityCatalog
extends RefCounted
## backend/FacilityCatalog.cs - what a facility costs and how it behaves, from
## the original's tables via data/parse_facilities.py and parse_defenses.py.
## The one place the engine asks "what does this cost, how fast is it".

## (FacilityType, Tier) -> FacilityStatRule. Vector2i is a value-typed pair key.
static var _by_type: Dictionary = {}

## Facility family ids as the original binary numbers them.
const Families := {
	32: Enums.FacilityType.Headquarters,
	34: Enums.FacilityType.IonCannon,
	35: Enums.FacilityType.TurbolaserBattery,
	36: Enums.FacilityType.PlanetaryShield,
	37: Enums.FacilityType.DeathStarShield,
	40: Enums.FacilityType.Shipyard,
	41: Enums.FacilityType.TrainingFacility,
	42: Enums.FacilityType.ConstructionYard,
	44: Enums.FacilityType.Mine,
	45: Enums.FacilityType.Refinery,
}


static func Load(paths: Array) -> void:
	_by_type.clear()
	for path in paths:
		var text := JsonUtil.read_text(path)
		if text.strip_edges().is_empty():
			continue
		for rule in Loaders._list(path, CatalogDtos.FacilityStatRule.from_dict):
			if not Families.has(rule.FamilyId):
				continue
			_by_type[Vector2i(Families[rule.FamilyId], rule.Tier)] = rule
	print("[FacilityCatalog] Loaded %d facility profiles." % _by_type.size())


static func Get(type: int, tier: int = 1) -> CatalogDtos.FacilityStatRule:
	return _by_type.get(Vector2i(type, tier))


static func ConstructionCost(type: int, tier: int = 1) -> int:
	var r := Get(type, tier)
	return r.ConstructionCost if r != null else 0


static func MaintenanceCost(type: int, tier: int = 1) -> int:
	var r := Get(type, tier)
	return r.MaintenanceCost if r != null else 0


## Days of work per unit of cost. Base facilities are 4, the R&D-gated Advanced
## variants 2 (manual p104).
static func ProcessingRate(type: int, tier: int = 1) -> int:
	var r := Get(type, tier)
	return max(1, r.ProcessingRate if r != null else 4)


## Every profile, for the research tree to walk.
static func All() -> Array:
	return _by_type.values()


## What a given faction may place on a world it controls. Excludes the
## headquarters; Advanced variants are R&D-gated (manual p104).
static func BuildableBy(faction: Faction) -> Array:
	var out := []
	for r in _by_type.values():
		if not ResearchManager.IsUnlockedFacility(faction, r):
			continue
		if r.Tier != 1:
			continue
		if Families.get(r.FamilyId, Enums.FacilityType.Mine) == Enums.FacilityType.Headquarters:
			continue
		if not r.CanBeBuiltBy(faction):
			continue
		out.append(r)
	return Lq.order_by(out, func(r): return r.ConstructionCost)


static func TypeOf(rule: CatalogDtos.FacilityStatRule) -> int:
	return Families.get(rule.FamilyId, Enums.FacilityType.Mine)
