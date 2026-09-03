class_name Loaders
extends RefCounted
## Every data file the source reads, hydrated exactly as its C# loader does -
## the same path, the same DTO, the same post-processing that touches the DTO
## itself (LogisticsFile.Name is stamped from the dictionary key). The catalogs
## that INDEX these (RuleManager, MissionCatalog, ...) are ported with the
## subsystems that use them; this file is the contract with data/*.json.

const RULES              := "res://data/game_rules.json"
const MISSION_TABLES     := "res://data/mission_tables.json"
const MISSIONS           := "res://data/missions.json"
const UPRISING_START     := "res://data/uprising_start.json"
const UPRISING_END       := "res://data/uprising_end.json"
const SIDE_LOTTERY       := "res://data/side_lottery.json"
const LOGISTICS          := "res://data/day_zero_logistics.json"
const DEFENSES           := "res://data/defensive_facilities.json"
const MILITARY           := "res://data/military_units.json"
const PRODUCTION         := "res://data/production_facilities.json"
const SECTORS            := "res://data/sectors_data.json"
const PLANETS            := "res://data/planets_data.json"
const MAJOR_CHARACTERS   := "res://data/major_characters.json"
const MINOR_CHARACTERS   := "res://data/minor_characters.json"


static func _list(path: String, from_dict: Callable) -> Array:
	var data: Variant = JsonUtil.parse(path)
	var out: Array = []
	if data == null:
		return out
	for e in data:
		out.append(from_dict.call(e))
	return out


static func sectors() -> Array:            return _list(SECTORS, CatalogDtos.SectorJsonData.from_dict)
static func planets() -> Array:            return _list(PLANETS, CatalogDtos.PlanetJsonData.from_dict)
static func missions() -> Array:           return _list(MISSIONS, CatalogDtos.MissionDef.from_dict)
static func rules() -> Array:              return _list(RULES, CatalogDtos.GameRuleData.from_dict)
static func side_lottery() -> Array:       return _list(SIDE_LOTTERY, CatalogDtos.SideRuleData.from_dict)
static func production_facilities() -> Array: return _list(PRODUCTION, CatalogDtos.FacilityStatRule.from_dict)
static func defensive_facilities() -> Array:  return _list(DEFENSES, CatalogDtos.FacilityStatRule.from_dict)
static func defense_stats() -> Array:      return _list(DEFENSES, CatalogDtos.DefenseStatRule.from_dict)
static func military_units() -> Array:     return _list(MILITARY, CatalogDtos.UnitStatRule.from_dict)
static func military_units_editor() -> Array: return _list(MILITARY, CatalogDtos.MilitaryUnit.from_dict)
static func major_characters() -> Array:   return _list(MAJOR_CHARACTERS, Character.from_dict)
static func minor_characters() -> Array:   return _list(MINOR_CHARACTERS, Character.from_dict)


## Dictionary<string, LogisticsFile>, the file name stamped onto each entry.
static func logistics() -> Dictionary:
	var data: Variant = JsonUtil.parse(LOGISTICS)
	var out := {}
	if data == null:
		return out
	for key in data.keys():
		var f := CatalogDtos.LogisticsFile.from_dict(data[key])
		f.Name = str(key)
		out[str(key)] = f
	return out


## Dictionary<string, MissionTableData>
static func mission_tables() -> Dictionary:
	var data: Variant = JsonUtil.parse(MISSION_TABLES)
	var out := {}
	if data == null:
		return out
	for key in data.keys():
		out[str(key)] = CatalogDtos.MissionTableData.from_dict(data[key])
	return out


static func uprising_start() -> CatalogDtos.IntTable:
	var data: Variant = JsonUtil.parse(UPRISING_START)
	return CatalogDtos.IntTable.from_dict(data) if data != null else null


static func uprising_end() -> CatalogDtos.IntTable:
	var data: Variant = JsonUtil.parse(UPRISING_END)
	return CatalogDtos.IntTable.from_dict(data) if data != null else null
