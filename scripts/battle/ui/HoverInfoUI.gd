extends Node

class_name HoverInfo

@onready var area2D:Area2D = $"%HoverArea2D"
@export var title:String
@export var description:String

func _ready():
	area2D.connect("mouse_entered", Callable(self,"_on_mouse_entered"))
	area2D.connect("mouse_exited", Callable(self,"_on_mouse_exited"))

func _on_mouse_entered():
	CombatEventManager.on_show_info(title, description)

func _on_mouse_exited():
	CombatEventManager.on_hide_info()
