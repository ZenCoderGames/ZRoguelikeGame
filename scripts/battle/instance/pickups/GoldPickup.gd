extends Node2D

class_name GoldPickup

var cell:DungeonCell
@onready var hoverInfo:HoverInfo = $"%HoverInfo"

func init(myCell):
	cell = myCell
	self.position = Vector2(cell.pos.x, cell.pos.y)
	hoverInfo.setup_far("Gold", "Pick Gold Up for Meta Progression")
	hoverInfo.setup(get_display_name(), get_description(), cell)

func activate():
	CombatEventManager.on_show_info(get_display_name(), get_description())
	AudioEventManager.emit_signal("OnGenericPickup")
	GameGlobals.dungeon.dungeonProgress.gold_collected()

func get_display_name():
	return "Gold"

func get_description():
	return "Pick Gold Up for Meta Progression"