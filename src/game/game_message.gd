class_name GameMessage
extends RefCounted
## backend/GameMessage.cs - one entry in the message log.

var Title: String
var Body: String
var Category: Enums.MessageCategory
## The original's finer-grained kind. Optional - None rather than guessed.
var Type: Enums.MessageType = Enums.MessageType.None
var DayReceived: int
var AssociatedLocation: Location
var AssociatedCharacter: Character
var IsRead: bool = false

## Set when the message asks a question the player can answer from the message
## itself ("Do you wish the mission to continue?", manual p110).
var PendingMission: Mission


func _init(title: String = "", body: String = "", category: int = Enums.MessageCategory.All,
		day: int = 0, planet: Location = null, character: Character = null) -> void:
	Title = title
	Body = body
	Category = category as Enums.MessageCategory
	DayReceived = day
	AssociatedLocation = planet
	AssociatedCharacter = character


func AwaitsDecision() -> bool:
	return PendingMission != null and not PendingMission.Finished


static func _enum_fields() -> Dictionary:
	return { "Category": Enums.MessageCategory, "Type": Enums.MessageType }
