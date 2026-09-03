class_name Canonical
extends RefCounted
## The canonical form both sides of the parity test emit (HANDOFF step 1A):
##
##   object     -> { field name: value } for every script variable, sorted by name
##   enum       -> its C# name
##   Faction    -> its id
##   null       -> null (an `int?` that was absent stays distinguishable from 0)
##   Array      -> array, Dictionary -> object with sorted keys
##   Color      -> "#rrggbb" (never in a DTO today)
##
## The C# twin is backend/DtoDump.cs in the source repo. tools/dto-parity.ps1
## runs both and compares the parsed structures.

const MAX_DEPTH := 12


static func value(v: Variant, depth: int = 0) -> Variant:
	match typeof(v):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_STRING_NAME:
			return v
		TYPE_COLOR:
			return "#" + (v as Color).to_html(false)
		TYPE_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY:
			var out := []
			for x in v:
				out.append(value(x, depth + 1))
			return out
		TYPE_DICTIONARY:
			var keys := (v as Dictionary).keys()
			keys.sort()
			var out := {}
			for k in keys:
				out[str(k)] = value(v[k], depth + 1)
			return out
		TYPE_OBJECT:
			if v is Faction:
				return (v as Faction).Id
			return expand(v, depth)
		_:
			return str(v)


static func expand(o: Object, depth: int = 0) -> Variant:
	if depth > MAX_DEPTH:
		return "<depth>"
	var enum_fields: Dictionary = o._enum_fields() if o.has_method("_enum_fields") else {}
	var names: Array[String] = []
	var script: Script = o.get_script()
	while script != null:
		for p in script.get_script_property_list():
			if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and not names.has(p.name):
				names.append(p.name)
		script = script.get_base_script()
	names.sort()
	var out := {}
	for name in names:
		if name.begins_with("_"):
			continue   # private backing fields (Unit._attached) are not C# properties
		var v: Variant = o.get(name)
		if enum_fields.has(name):
			out[name] = JsonUtil.enum_name(enum_fields[name], v)
		else:
			out[name] = value(v, depth + 1)
	return out


static func to_json(v: Variant) -> String:
	return JSON.stringify(value(v), "  ", true) + "\n"
