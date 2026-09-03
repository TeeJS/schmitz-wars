class_name Character
extends Unit
## backend/Character.cs - the data half. Behaviour (command relief, injury,
## captivity, the Force) is ported with the subsystems that drive it (step 2);
## the command-relief hook on Attached is here because it is a property setter.

## Major or minor - set from which file the character was loaded out of, not JSON.
var IsMajor: bool

var Rank: Enums.Rank = Enums.Rank.None
var Commanding: Location   # a planet or a fleet

## CAPTURED: who is holding them. Null means free.
var CapturedBy: Faction
var AtDagobah: bool
var AtJabbasPalace: bool
var KnowsHeritage: bool
var CanEscape: bool = true
var BountyAttack: bool
var CapturedByBountyHunters: bool
var FinalBattleReady: bool
var NextEscapeAttemptOn: int

## Days spent convalescing somewhere friendly.
var DaysResting: int
## INJURY IS A MAGNITUDE, NOT A FLAG (rules table entries 22-37).
var Injury: int

# The JSON stat block: each rating is base + rand(0..var), rolled at day zero.
var DiplomacyBase: int
var DiplomacyVar: int
var EspionageBase: int
var EspionageVar: int
var CombatBase: int
var CombatVar: int
var LeadershipBase: int
var LeadershipVar: int
var LoyaltyBase: int
var LoyaltyVar: int
var JediLevelBase: int
var JediLevelVar: int
var ShipResearchBase: int
var ShipResearchVar: int
var TroopResearchBase: int
var TroopResearchVar: int
var FacilityResearchBase: int
var FacilityResearchVar: int

var CanBeAdmiral: bool
var CanBeCommander: bool
var CanBeGeneral: bool

var JediProbability: int
var JediLevel: int
var IsKnownJedi: bool
var CanTrainJedi: bool

var Loyalty: int
var TraitorRevealed: bool
var WontBetray: bool

var ShipDesign: int
var TroopTraining: int
var FacilityDesign: int


func IsInjured() -> bool:
	return Injury > 0


## ★ LEAVING THE THING YOU COMMAND RELIEVES YOU OF THE COMMAND (measured in the
## original). One choke point instead of thirty departure paths. The player-side
## message is raised by the EventBus port in step 2; the relief itself is here.
func set_Attached(value: Location) -> void:
	_attached = value
	if Rank == Enums.Rank.None or Commanding == null:
		return
	if Commanding == value:
		return
	var relieved := Rank
	var post := Commanding
	Rank = Enums.Rank.None
	Commanding = null
	print("[Command] %s is no longer %s of %s - left the post." % [Name, JsonUtil.enum_name(Enums.Rank, relieved), post.Name])


static func _enum_fields() -> Dictionary:
	return { "Type": Enums.UnitType, "Status": Enums.Status, "Rank": Enums.Rank }


## The C# deserialisation: case-insensitive keys, JsonStringEnumConverter for
## enums, FactionConverter for Faction (a faction id resolved through the registry).
static func from_dict(d: Dictionary) -> Character:
	var c := Character.new()
	JsonUtil.hydrate(c, d, _enum_fields(), {
		"Faction": func(id: String) -> Faction: return FactionRegistry.ById(id),
		"CapturedBy": func(id: String) -> Faction: return FactionRegistry.ById(id),
	})
	return c
