class_name Lq
extends RefCounted
## The handful of LINQ shapes the source leans on that GDScript lacks, done the
## way C# does them. STABLE sorting matters: C# OrderBy is stable and several
## rules tie-break by insertion order; Array.sort_custom is not guaranteed stable.


## OrderBy(key) - stable. `key` returns a comparable Variant; return an Array
## for OrderBy(...).ThenBy(...).
static func order_by(items: Array, key: Callable, descending: bool = false) -> Array:
	var decorated := []
	for i in items.size():
		decorated.append([key.call(items[i]), i, items[i]])
	decorated.sort_custom(func(a, b):
		if a[0] == b[0]:
			return a[1] < b[1]
		return a[0] > b[0] if descending else a[0] < b[0])
	var out := []
	for d in decorated:
		out.append(d[2])
	return out


static func first_or_null(items: Array, pred: Callable = Callable()) -> Variant:
	for x in items:
		if not pred.is_valid() or pred.call(x):
			return x
	return null


static func any(items: Array, pred: Callable) -> bool:
	for x in items:
		if pred.call(x):
			return true
	return false


static func all(items: Array, pred: Callable) -> bool:
	for x in items:
		if not pred.call(x):
			return false
	return true


static func where(items: Array, pred: Callable) -> Array:
	var out := []
	for x in items:
		if pred.call(x):
			out.append(x)
	return out


static func count(items: Array, pred: Callable) -> int:
	var n := 0
	for x in items:
		if pred.call(x):
			n += 1
	return n


static func sum(items: Array, sel: Callable) -> int:
	var n := 0
	for x in items:
		n += sel.call(x)
	return n


static func max_of(items: Array, sel: Callable, default: int = 0) -> int:
	if items.is_empty():
		return default
	var best: int = sel.call(items[0])
	for i in range(1, items.size()):
		best = max(best, sel.call(items[i]))
	return best


static func select(items: Array, sel: Callable) -> Array:
	var out := []
	for x in items:
		out.append(sel.call(x))
	return out


static func of_type_character(items: Array) -> Array:
	var out := []
	for x in items:
		if x is Character:
			out.append(x)
	return out


## string.Join(", ", names)
static func join(items: Array, sep: String = ", ") -> String:
	var parts := PackedStringArray()
	for x in items:
		parts.append(str(x))
	return sep.join(parts)
