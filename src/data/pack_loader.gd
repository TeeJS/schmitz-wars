class_name PackLoader
extends RefCounted
## backend/Packs/PackLoader.cs - reads a faction pack off disk and validates it.
## Validation collects EVERY problem rather than stopping at the first, so a pack
## author sees the whole list in one pass (SCHEMA.md section 9).

const SupportedSchemaVersion := 1
const KNOWN_HQ_KINDS := ["fixed", "hidden"]
const KNOWN_OCCUPATION_POLICIES := ["garrison_bonus", "occupation_penalty"]


class LoadedPack:
	var Manifest: PackDefs.PackManifest
	var Factions: Array[PackDefs.FactionDef] = []


## Returns the pack, or null with `errors` populated. Never throws on bad pack
## content - malformed JSON is reported as an error like any other.
static func Load(pack_dir: String, errors: Array[String]) -> LoadedPack:
	var manifest_d: Variant = _read_json("%s/pack.json" % pack_dir, errors)
	var factions_d: Variant = _read_json("%s/factions.json" % pack_dir, errors)
	if manifest_d == null or factions_d == null:
		return null
	var pack := LoadedPack.new()
	pack.Manifest = PackDefs.PackManifest.from_dict(manifest_d)
	pack.Factions = PackDefs.FactionsFile.from_dict(factions_d).Factions
	_validate(pack, pack_dir, errors)
	return pack if errors.is_empty() else null


static func _read_json(path: String, errors: Array[String]) -> Variant:
	var text := JsonUtil.read_text(path)
	if text.strip_edges().is_empty():
		errors.append("%s: missing or empty." % path)
		return null
	var json := JSON.new()
	if json.parse(text) != OK:
		errors.append("%s: malformed JSON - %s" % [path, json.get_error_message()])
		return null
	return json.data


static func _validate(pack: LoadedPack, pack_dir: String, errors: Array[String]) -> void:
	var m := pack.Manifest

	# 1. Manifest identity and version.
	var folder := pack_dir.trim_suffix("/").get_file()
	if m.Id != folder:
		errors.append("pack.json: id '%s' does not match folder name '%s'." % [m.Id, folder])
	if m.SchemaVersion > SupportedSchemaVersion:
		errors.append("pack.json: schema_version %d is newer than this engine supports (%d)." % [m.SchemaVersion, SupportedSchemaVersion])

	# 2. Faction count, 2-4, and matching the declared count.
	var count := pack.Factions.size()
	if count < 2 or count > 4:
		errors.append("factions.json: %d factions declared; must be 2-4." % count)
	if m.FactionCount != count:
		errors.append("pack.json: faction_count is %d but factions.json declares %d." % [m.FactionCount, count])

	if m.Neutral == null or m.Neutral.Id.strip_edges().is_empty():
		errors.append("pack.json: 'neutral' must declare an id, display_name and color.")
	else:
		_require_color(m.Neutral.ColorHex, "pack.json: neutral.color", errors)
	_require_color(m.UnexploredColor, "pack.json: unexplored_color", errors)

	var seen := {}
	for f in pack.Factions:
		var ctx := "factions.json[%s]" % (f.Id if not f.Id.is_empty() else "?")

		if f.Id.strip_edges().is_empty():
			errors.append("%s: missing id." % ctx)
		elif seen.has(f.Id):
			errors.append("%s: duplicate id." % ctx)
		else:
			seen[f.Id] = true
		if m.Neutral != null and f.Id == m.Neutral.Id:
			errors.append("%s: id collides with the neutral id; neutral is not a playable faction." % ctx)

		if f.DisplayName.strip_edges().is_empty():
			errors.append("%s: missing display_name." % ctx)
		if f.LoyaltyLabel.strip_edges().is_empty():
			errors.append("%s: missing loyalty_label." % ctx)
		_require_color(f.ColorHex, "%s: color" % ctx, errors)

		if not f.OccupationSupportPolicy.is_empty() and not KNOWN_OCCUPATION_POLICIES.has(f.OccupationSupportPolicy):
			errors.append("%s: unknown occupation_support_policy '%s'. Known: %s." % [ctx, f.OccupationSupportPolicy, ", ".join(KNOWN_OCCUPATION_POLICIES)])

		# 6. HQ internal consistency.
		if f.Hq == null:
			errors.append("%s: missing hq." % ctx)
		elif not KNOWN_HQ_KINDS.has(f.Hq.Kind):
			errors.append("%s: unknown hq.kind '%s'. Known: %s." % [ctx, f.Hq.Kind, ", ".join(KNOWN_HQ_KINDS)])
		elif f.Hq.Kind == "fixed" and f.Hq.Planet.strip_edges().is_empty():
			errors.append("%s: hq.kind 'fixed' requires hq.planet." % ctx)
		elif f.Hq.Kind == "hidden" and f.Hq.Placement.strip_edges().is_empty():
			errors.append("%s: hq.kind 'hidden' requires hq.placement (a planet name or 'random_rim')." % ctx)

	# Cross-references into map data are checked in a later phase, once the
	# map itself is pack-loaded; today planets still come from data/.


static func _require_color(value: String, ctx: String, errors: Array[String]) -> void:
	if value.strip_edges().is_empty():
		errors.append("%s: missing." % ctx)
		return
	var ok := value.length() == 7 and value[0] == "#"
	if ok:
		for i in range(1, 7):
			if not value[i].is_valid_hex_number():
				ok = false
				break
	if not ok:
		errors.append("%s: '%s' is not a #rrggbb color." % [ctx, value])
