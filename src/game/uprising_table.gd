class_name UprisingTable
extends RefCounted
## backend/UprisingTable.cs - UPRIS1TB.DAT, the shipped "uprising start" table:
## a threshold -> value step lookup fed by the 1-10 roll of entries 175/176.
## Only "0 means nothing happens" is used; what 1 and 2 mean is NOT known.

static var _start: Array = []   # [[threshold, value], ...] ascending


static func IsLoaded() -> bool:
	return _start.size() > 0


static func Load(path: String) -> void:
	_start.clear()
	if not FileAccess.file_exists(path):
		push_error("ERROR: Could not find the uprising start table at %s!" % path)
		return
	var data: Variant = JsonUtil.parse(path)
	var table := CatalogDtos.IntTable.from_dict(data) if data != null else null
	if table == null or table.Entries == null:
		return
	for e in Lq.order_by(table.Entries, func(e): return e.Threshold):
		_start.append([e.Threshold, e.Value])
	var parts := []
	for r in _start:
		parts.append("%d->%d" % [r[0], r[1]])
	print("[Rules] Uprising start table: %d rows, %s" % [_start.size(), ", ".join(parts)])


## The row with the greatest threshold at or below the roll; 0 below the lowest
## threshold and with no table at all - no uprising.
static func StartOutcome(roll: int) -> int:
	var outcome := 0
	for r in _start:
		if roll < r[0]:
			break
		outcome = r[1]
	return outcome
