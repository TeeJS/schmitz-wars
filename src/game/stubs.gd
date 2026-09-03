class_name Stubs
extends RefCounted
## HANDOFF step 1B: the thirteen daily subsystems that are NOT in the vertical
## slice, stubbed to no-ops so StrategicTickManager.AdvanceDay runs the real
## Planet and Mission ticks over the real day-zero state. Each is a STEP 2 port.
## Kept in one file so the list of what is missing is one grep away.
##
## Not stubs (ported for 1B): Planet, Economy, MissionManager, ResearchManager;
## and the predicates other code reads: BlockadeManager.IsBlockaded,
## LoyaltyManager.FerretOutTraitors, OrderManager.SystemOf.

class ForceManager:
	static func Reset() -> void: pass
	static func ProcessDay(_day: int) -> void: pass


class StoryManager:
	static func ProcessDay(_day: int, _rng: Prng) -> void: pass


class CaptivityManager:
	static func ProcessDay(_galaxy: Array, _day: int, _rng: Prng) -> void: pass


class InformantManager:
	static func ProcessDay(_galaxy: Array, _day: int, _rng: Prng) -> void: pass


class AgentDroid:
	static func ProcessDay(_galaxy: Array, _day: int) -> void: pass


class AiManager:
	static var DriveAllFactions: bool = false
	static func ProcessDay(_galaxy: Array, _day: int, _rng: Prng) -> void: pass


class FleetBattleManager:
	static func ProcessDay(_galaxy: Array, _day: int, _rng: Prng) -> void: pass
	static func HasPendingBattle() -> bool: return false


class SmugglingManager:
	static func ProcessDay(_galaxy: Array, _day: int, _rng: Prng) -> void: pass


class RepairManager:
	static func Reset() -> void: pass
	static func ProcessDay(_galaxy: Array, _day: int) -> void: pass


class VictoryManager:
	static var Winner: Faction = null
	static func IsOver() -> bool: return Winner != null
	static func ProcessDay(_galaxy: Array, _day: int) -> void: pass
