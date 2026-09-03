class_name MissionTableManager
extends RefCounted
## backend/MissionTableManager.cs - THE MISSION OUTCOME TABLES (data/mission_tables.json,
## from the *MSTB.DAT and friends). Each table is a STEP FUNCTION: ascending
## thresholds, each carrying the value that applies from that threshold up.

## The file names are the table identity - the same strings the original
## registers by id at REBEXE.EXE 0x58B420.
const Diplomacy         := "DIPLMSTB.DAT"   # id 20
const Rescue            := "RESCMSTB.DAT"   # id 21
const Sabotage          := "SBTGMSTB.DAT"   # id 22
const Espionage         := "ESPIMSTB.DAT"   # id 23
const Recruitment       := "RCRTMSTB.DAT"   # id 24
const Abduction         := "ABDCMSTB.DAT"   # id 25
const InciteUprising    := "INCTMSTB.DAT"   # id 26
const DeathStarSabotage := "DSSBMSTB.DAT"   # id 27
const SubdueUprising    := "SUBDMSTB.DAT"   # id 28
const Assassination     := "ASSNMSTB.DAT"   # id 29

## NOT MISSION TYPES - the contests a mission passes THROUGH.
const Foil              := "FOILTB.DAT"     # id 12
const Decoy             := "FDECOYTB.DAT"   # id 10
const TroopDecoy        := "TDECOYTB.DAT"   # id 11
const Evasion           := "RLEVADTB.DAT"   # id 13
const Escape            := "ESCAPETB.DAT"   # id 44

## Not a contest either - an EVENT CODE lookup. See InformantManager.
const Informants        := "INFORMTB.DAT"   # id 42

static var _tables: Dictionary = {}   # name -> MissionTableData


static func IsLoaded() -> bool:
	return _tables.size() > 0


static func Load(json_path: String) -> void:
	if not FileAccess.file_exists(json_path):
		push_error("ERROR: Could not find mission tables at %s!" % json_path)
		return
	_tables = Loaders.mission_tables()
	var rows := 0
	for t in _tables.values():
		rows += t.Entries.size()
	print("Successfully loaded %d mission tables (%d rows)." % [_tables.size(), rows])


## The step lookup: the value for the highest threshold the score clears; below
## the first threshold, the first entry's value stands. -1 when the table is
## missing entirely.
static func Lookup(table: Variant, score: int) -> int:
	if table == null or not _tables.has(table):
		return -1
	var t: CatalogDtos.MissionTableData = _tables[table]
	if t.Entries == null or t.Entries.is_empty():
		return -1
	var value: int = t.Entries[0].Value
	for e in t.Entries:
		if score >= e.Threshold:
			value = e.Value
	return value


static func Has(table: Variant) -> bool:
	return table != null and _tables.has(table)


## THE OTHER READER: a row looked up BY KEY against the threshold column
## (INFORMTB). -1 when the table or the row is missing.
static func Row(table: Variant, key: int) -> int:
	if table == null or not _tables.has(table):
		return -1
	var t: CatalogDtos.MissionTableData = _tables[table]
	if t.Entries == null:
		return -1
	for e in t.Entries:
		if e.Threshold == key:
			return e.Value
	return -1
