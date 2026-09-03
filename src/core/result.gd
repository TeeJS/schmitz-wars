class_name Result
extends RefCounted
## The C# `bool Try(..., out string error)` shape. `ok` is the return value and
## `error` the out parameter; `value` carries an int result where C# returned one.

var ok: bool
var error: String = ""
var value: Variant = null


static func success(value: Variant = null) -> Result:
	var r := Result.new()
	r.ok = true
	r.value = value
	return r


static func fail(error: String, value: Variant = null) -> Result:
	var r := Result.new()
	r.ok = false
	r.error = error
	r.value = value
	return r
