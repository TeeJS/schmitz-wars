class_name Facility
extends RefCounted
## backend/Facility.cs - a facility standing on a world.

var Attached: Planet

var Type: Enums.FacilityType = Enums.FacilityType.Headquarters
var Tier: int = 1
var IsDamaged: bool = false
var IsSelected: bool = false

# --- COMBAT STATS ---
var ConstructionCost: int
var MaintenanceCost: int
var WeaponRating: int
var ShieldStrength: int

## "BOMBARDMENT VALUE" - what a bombarding fleet must spend to destroy this
## (manual p085 fig 3.28, p122).
var BombardmentDefense: int


func Name() -> String:
	return NameOf(Type)


## Static so code holding only a TYPE names it the same way a live facility does.
static func NameOf(type: int) -> String:
	return JsonUtil.enum_name(Enums.FacilityType, type) \
		.replace("ConstructionYard", "Construction Yard") \
		.replace("TrainingFacility", "Training Facility") \
		.replace("PlanetaryShield", "Planetary Shield") \
		.replace("TurbolaserBattery", "Turbolaser Battery") \
		.replace("DeathStarShield", "Death Star Shield") \
		.replace("IonCannon", "Ion Cannon")


static func _enum_fields() -> Dictionary:
	return { "Type": Enums.FacilityType }
