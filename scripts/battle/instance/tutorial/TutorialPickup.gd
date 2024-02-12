extends Node2D

class_name TutorialPickup

var data:TutorialPickupData
var cell:DungeonCell
@onready var hoverInfo:HoverInfo = $"%HoverInfo"

func init(tutorialPickupData, myCell):
	data = tutorialPickupData
	cell = myCell
	self.position = Vector2(cell.pos.x, cell.pos.y)
	hoverInfo.title = get_display_name()
	hoverInfo.description = get_description()

func activate():
	CombatEventManager.on_show_info(get_display_name(), get_description())
	AudioEventManager.emit_signal("OnGenericPickup")

func get_display_name():
	return data.name

func get_description():
	return data.description
