class_name OrderManager
extends RefCounted
## backend/OrderManager.cs - PARTIAL (HANDOFF step 1B). Only SystemOf, which
## the backend tick path reads. Movement orders are STEP 2/3.


static func SystemOf(where: Location) -> Planet:
	if where is Planet:
		return where
	if where is Fleet:
		return (where as Fleet).Attached
	return null
