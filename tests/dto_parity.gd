extends SceneTree
## HANDOFF step 1A, GDScript half: hydrate every data file the source reads and
## write the canonical dump. Run headless:
##
##   Godot_console.exe --headless --path . -s tests/dto_parity.gd -- --out=C:\path\gd-dto.json
##
## The C# half is `--dto-dump=path` on the source's Main.tscn. tools/dto-parity.ps1
## runs both and diffs them field by field.


func _init() -> void:
	var out_path := _arg("--out=")
	if out_path.is_empty():
		push_error("usage: -s tests/dto_parity.gd -- --out=<file>")
		quit(2)
		return

	FactionRegistry.EnsureLoaded()

	var pack_id: String = str(JsonUtil.get_ci(JsonUtil.parse("res://packs/active.json"), "pack"))
	var errors: Array[String] = []
	var pack := PackLoader.Load("res://packs/%s" % pack_id, errors)

	var dump := {
		"pack_manifest":          pack.Manifest if pack != null else null,
		"factions_file":          pack.Factions if pack != null else null,
		"sectors":                Loaders.sectors(),
		"planets":                Loaders.planets(),
		"missions":               Loaders.missions(),
		"rules":                  Loaders.rules(),
		"side_lottery":           Loaders.side_lottery(),
		"production_facilities":  Loaders.production_facilities(),
		"defensive_facilities":   Loaders.defensive_facilities(),
		"defense_stats":          Loaders.defense_stats(),
		"military_units":         Loaders.military_units(),
		"military_units_editor":  Loaders.military_units_editor(),
		"logistics":              Loaders.logistics(),
		"mission_tables":         Loaders.mission_tables(),
		"uprising_start":         Loaders.uprising_start(),
		"uprising_end":           Loaders.uprising_end(),
		"major_characters":       Loaders.major_characters(),
		"minor_characters":       Loaders.minor_characters(),
	}

	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f == null:
		push_error("cannot write %s" % out_path)
		quit(1)
		return
	f.store_string(Canonical.to_json(dump))
	f.close()

	var counts := []
	for k in dump.keys():
		var v = dump[k]
		counts.append("%s=%d" % [k, v.size() if (v is Array or v is Dictionary) else 1])
	print("[dto_parity] wrote %s: %s" % [out_path, ", ".join(counts)])
	quit(0)


func _arg(prefix: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(prefix):
			return a.substr(prefix.length())
	for a in OS.get_cmdline_args():
		if a.begins_with(prefix):
			return a.substr(prefix.length())
	return ""
