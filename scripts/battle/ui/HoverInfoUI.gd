extends Node

class_name HoverInfo

@onready var area2D:Area2D = $"%HoverArea2D"
@export var title:String
@export var description:String

var _titleFar:String
var _descriptionFar:String
var _cell:DungeonCell

func _ready():
	area2D.connect("mouse_entered", Callable(self,"_on_mouse_entered"))
	area2D.connect("mouse_exited", Callable(self,"_on_mouse_exited"))

func setup_far(titleVal:String, descVal:String):
	_titleFar = titleVal
	_descriptionFar = descVal

func setup(titleVal:String, descVal:String, cellVal:DungeonCell):
	title = titleVal
	description = descVal
	_cell = cellVal

func _on_mouse_entered():
	if(_cell!=null):
		var playerCell:DungeonCell = GameGlobals.dungeon.player.cell
		if(_cell.is_rowcol_adjacent(playerCell)):
			CombatEventManager.on_show_info(_titleFar, _descriptionFar)
			return
	CombatEventManager.on_show_info(title, description)

func _on_mouse_exited():
	CombatEventManager.on_hide_info()
