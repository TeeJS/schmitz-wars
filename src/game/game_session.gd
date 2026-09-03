class_name GameSession
extends RefCounted
## The composition root the autoload policy calls for (HANDOFF §6): one place
## that loads the catalogs in the source's order (GameManager._Ready) and resets
## every per-game static, so a new game starts clean and a headless harness
## starts the same way the menu does.
##
## The managers stay `class_name` statics (a straight translation of the source's
## static classes); this is where their lifecycle is owned.

const DATA := "res://data"


## Everything GameManager loads before day zero, in its order.
static func load_catalogs() -> void:
	FactionRegistry.EnsureLoaded()
	RuleManager.LoadRules("%s/game_rules.json" % DATA)
	MissionTableManager.Load("%s/mission_tables.json" % DATA)
	MissionCatalog.Load("%s/missions.json" % DATA)
	UprisingTable.Load("%s/uprising_start.json" % DATA)
	# SideLotteryManager.LoadRules - day-zero generation only; ported with DayZeroGenerator (step 2).
	SeedManager.Load("%s/day_zero_logistics.json" % DATA, "%s/defensive_facilities.json" % DATA, "%s/military_units.json" % DATA)
	FacilityCatalog.Load(["%s/production_facilities.json" % DATA, "%s/defensive_facilities.json" % DATA])


## Every per-game static, cleared - the source's Reset() calls plus the ones it
## relies on a fresh process for.
static func reset_game_state() -> void:
	Economy.Reset()
	Stubs.ForceManager.Reset()
	Fleet.ResetSerials()
	Stubs.RepairManager.Reset()
	IntelManager.Reset()
	ResearchManager.Reset()
	MissionManager.Clear()
	EventBus.Reset()
	BlockadeManager.Reset()
	GameState.Reset()
	StrategicTickManager.Today = 1


## A game from a day-zero snapshot, seeded. Returns the tick manager.
static func start_from_snapshot(path: String, seed: int) -> StrategicTickManager:
	reset_game_state()
	load_catalogs()
	if not SnapshotLoader.Load(path):
		return null
	GameSettings.Seed = seed
	Prng.Session = Prng.new(seed)
	print("[Prng] seed=%d" % seed)
	return StrategicTickManager.new(GameState.ActiveGalaxy)
