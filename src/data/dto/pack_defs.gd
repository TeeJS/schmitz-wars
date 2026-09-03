class_name PackDefs
extends RefCounted
## backend/Packs/PackLoader.cs - the plain data shapes read from a faction pack.
## The pack files are snake_case (JsonNamingPolicy.SnakeCaseLower on the C# side),
## so every hydrator here reads the snake_case key into the PascalCase field.


class HqDef:
	var Kind: String          # "fixed" | "hidden"
	var Planet: String        # fixed: the planet it sits on
	var Placement: String     # hidden: "random_rim", or a planet name
	var Movable: bool

	static func from_dict(d: Variant) -> HqDef:
		if d == null:
			return null
		var o := HqDef.new()
		o.Kind = JsonUtil.str_or(d, "kind", "")
		o.Planet = JsonUtil.str_or(d, "planet", "")
		o.Placement = JsonUtil.str_or(d, "placement", "")
		o.Movable = JsonUtil.bool_or(d, "movable")
		return o


class StartingPlanetDef:
	var Planet: String
	var Support: int          # percent loyal to THIS faction
	var Explored: bool
	var Garrison: String      # optional logistics table

	static func from_dict(d: Dictionary) -> StartingPlanetDef:
		var o := StartingPlanetDef.new()
		o.Planet = JsonUtil.str_or(d, "planet", "")
		o.Support = JsonUtil.int_or(d, "support")
		o.Explored = JsonUtil.bool_or(d, "explored")
		o.Garrison = JsonUtil.str_or(d, "garrison", "")
		return o


class FactionSeedDef:
	var HqFacilities: String
	var HqGarrison: String
	var Fleet: String
	var ProceduralFleet: String

	static func from_dict(d: Variant) -> FactionSeedDef:
		if d == null:
			return null
		var o := FactionSeedDef.new()
		o.HqFacilities = JsonUtil.str_or(d, "hq_facilities", "")
		o.HqGarrison = JsonUtil.str_or(d, "hq_garrison", "")
		o.Fleet = JsonUtil.str_or(d, "fleet", "")
		o.ProceduralFleet = JsonUtil.str_or(d, "procedural_fleet", "")
		return o


## WHAT THIS SIDE MUST ACHIEVE TO WIN - manual p011 and p162. Only the character
## list lives here; the headquarters half is derived from the opponent's HqDef.
class VictoryDef:
	var CaptureCharacters: Array[String] = []

	static func from_dict(d: Variant) -> VictoryDef:
		if d == null:
			return null
		var o := VictoryDef.new()
		o.CaptureCharacters = JsonUtil.str_list(d, "capture_characters", [])
		return o


class FactionDef:
	var Id: String
	var DisplayName: String
	var ColorHex: String        # C# ColorHex, JSON "color" - Color is a builtin type name
	var LoyaltyLabel: String
	var Hq: HqDef
	var OccupationSupportPolicy: String
	var StartingPlanets: Array[StartingPlanetDef] = []
	var Seed: FactionSeedDef
	var Victory: VictoryDef

	static func from_dict(d: Dictionary) -> FactionDef:
		var o := FactionDef.new()
		o.Id = JsonUtil.str_or(d, "id", "")
		o.DisplayName = JsonUtil.str_or(d, "display_name", "")
		o.ColorHex = JsonUtil.str_or(d, "color", "")
		o.LoyaltyLabel = JsonUtil.str_or(d, "loyalty_label", "")
		o.Hq = HqDef.from_dict(JsonUtil.get_ci(d, "hq"))
		o.OccupationSupportPolicy = JsonUtil.str_or(d, "occupation_support_policy", "")
		var sp: Variant = JsonUtil.get_ci(d, "starting_planets")
		if sp != null:
			for e in sp:
				o.StartingPlanets.append(StartingPlanetDef.from_dict(e))
		o.Seed = FactionSeedDef.from_dict(JsonUtil.get_ci(d, "seed"))
		o.Victory = VictoryDef.from_dict(JsonUtil.get_ci(d, "victory"))
		return o


class NeutralDef:
	var Id: String
	var DisplayName: String
	var ColorHex: String

	static func from_dict(d: Variant) -> NeutralDef:
		if d == null:
			return null
		var o := NeutralDef.new()
		o.Id = JsonUtil.str_or(d, "id", "")
		o.DisplayName = JsonUtil.str_or(d, "display_name", "")
		o.ColorHex = JsonUtil.str_or(d, "color", "")
		return o


class PackSetupDef:
	var DifficultyDefault: String
	var GalaxySizes: Array[String] = []

	static func from_dict(d: Variant) -> PackSetupDef:
		if d == null:
			return null
		var o := PackSetupDef.new()
		o.DifficultyDefault = JsonUtil.str_or(d, "difficulty_default", "")
		o.GalaxySizes = JsonUtil.str_list(d, "galaxy_sizes", [])
		return o


class PackManifest:
	var Id: String
	var DisplayName: String
	var SchemaVersion: int
	var FactionCount: int
	var Neutral: NeutralDef
	var UnexploredColor: String
	var Setup: PackSetupDef

	static func from_dict(d: Dictionary) -> PackManifest:
		var o := PackManifest.new()
		o.Id = JsonUtil.str_or(d, "id", "")
		o.DisplayName = JsonUtil.str_or(d, "display_name", "")
		o.SchemaVersion = JsonUtil.int_or(d, "schema_version")
		o.FactionCount = JsonUtil.int_or(d, "faction_count")
		o.Neutral = NeutralDef.from_dict(JsonUtil.get_ci(d, "neutral"))
		o.UnexploredColor = JsonUtil.str_or(d, "unexplored_color", "")
		o.Setup = PackSetupDef.from_dict(JsonUtil.get_ci(d, "setup"))
		return o


class FactionsFile:
	var Factions: Array[FactionDef] = []

	static func from_dict(d: Dictionary) -> FactionsFile:
		var o := FactionsFile.new()
		var list: Variant = JsonUtil.get_ci(d, "factions")
		if list != null:
			for e in list:
				o.Factions.append(FactionDef.from_dict(e))
		return o
