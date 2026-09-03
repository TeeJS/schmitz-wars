class_name Enums
extends RefCounted
## The source's enums, declaration order preserved because several are ORDINAL
## (MissionType joins MISSNSD by position; MissionCatalog says so). Names match
## the C# names exactly so the canonical dump and the logs read the same.

enum UnitType { Troop, Fighter, SpecForce, CapitalShip }                 # backend/Unit.cs

enum Status { AwaitingOrders, Enroute, OnMission, Kidnapped, Dead }       # backend/Character.cs

enum Rank { None, General, Admiral, Commander, Captain }                  # backend/Character.cs

## "There are FIVE LEVELS of Force users" (manual p092); None means not a Force user.
enum ForceRanking { None, Novice, Trainee, JediStudent, JediKnight, JediMaster }

enum FacilityType {                                                       # backend/Facility.cs
	Headquarters,
	Mine,
	Refinery,
	ConstructionYard,
	Shipyard,
	TrainingFacility,
	PlanetaryShield,     # GenCore, family 36
	TurbolaserBattery,   # LNR series, family 35
	IonCannon,           # KDY v150, family 34
	DeathStarShield,     # family 37 - protects the Death Star only, no bombardment shield
}

enum Difficulty { Multiplayer, Easy, Medium, Hard }                       # backend/GameContext.cs

enum GalaxySize { Standard, Large, Huge }                                 # backend/GameContext.cs
