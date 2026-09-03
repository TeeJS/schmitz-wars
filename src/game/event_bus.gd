class_name EventBus
extends RefCounted
## backend/EventBus.cs. C# static events became lists of Callables, so nothing
## needs a Node to listen: the UI (step 3) connects with `EventBus.OnStateChanged.append(callable)`.
## The message log lives here exactly as in the source.

static var OnGameNotification: Array[Callable] = []   # Action<string>
static var OnDayAdvanced: Array[Callable] = []        # Action<int>
static var OnStateChanged: Array[Callable] = []       # Action
static var OnMessageReceived: Array[Callable] = []    # Action<GameMessage>

static var MessageLog: Array[GameMessage] = []

## ⚠ RE-ENTRANT BROADCASTS ARE SWALLOWED, AND THAT IS DELIBERATE (see the source:
## a redraw that touches state broadcasts again, which redraws again, which froze
## the game).
static var _broadcasting: bool = false


static func Broadcast(message: String) -> void:
	for cb in OnGameNotification:
		cb.call(message)


static func BroadcastStateUpdated() -> void:
	Broadcast("The day has advanced. Strategic state updated.")


static func BroadcastDayAdvanced(day: int) -> void:
	for cb in OnDayAdvanced:
		cb.call(day)


static func BroadcastChanged() -> void:
	if _broadcasting:
		return
	_broadcasting = true
	for cb in OnStateChanged:
		cb.call()
	_broadcasting = false


static func BroadcastMessage(message: GameMessage) -> void:
	MessageLog.append(message)
	print("[COMMS - Day %d] (%s) %s: %s" % [message.DayReceived, JsonUtil.enum_name(Enums.MessageCategory, message.Category), message.Title, message.Body])
	for cb in OnMessageReceived:
		cb.call(message)


## "Messages are eventually deleted whether or not you read them, except for
## agent advice messages" (manual p079). Automatic expiry is not modelled; this
## is the player clearing one by hand.
static func DeleteMessage(message: GameMessage) -> void:
	if message == null:
		return
	MessageLog.erase(message)
	BroadcastChanged()   # a deletion is a state change, not an arrival


## Unread messages waiting, per category (manual p068).
static func UnreadCount(category: int) -> int:
	var n := 0
	for m in MessageLog:
		if not m.IsRead and (category == Enums.MessageCategory.All or m.Category == category):
			n += 1
	return n


static func UnreadTotal() -> int:
	var n := 0
	for m in MessageLog:
		if not m.IsRead:
			n += 1
	return n


static func Reset() -> void:
	MessageLog.clear()
	_broadcasting = false
