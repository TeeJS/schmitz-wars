class_name GameState
extends RefCounted
## The two statics the source keeps on its GameManager node - the roster and the
## galaxy - and nothing else. Backend code reads `GameManager.ActiveRoster` in
## C#; here it is `GameState.ActiveRoster`, because the port's GameManager is a
## scene node (step 3) and the backend must not depend on a node.

static var ActiveRoster: Array[Character] = []
static var ActiveGalaxy: Array[Sector] = []


static func AllPlanets() -> Array[Planet]:
	var out: Array[Planet] = []
	for s in ActiveGalaxy:
		for p in s.Planets:
			out.append(p)
	return out


static func Reset() -> void:
	ActiveRoster = []
	ActiveGalaxy = []
