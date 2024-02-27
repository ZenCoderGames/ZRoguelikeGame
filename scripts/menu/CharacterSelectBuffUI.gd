extends Node

class_name CharacterSelectBuffUI

@onready var icon:TextureRect = $"%Icon"

var _data:DungeonModifierData

signal OnInFocus(text)
signal OnOutOfFocus

func init(dungeonModifier:DungeonModifierData):
	_data = dungeonModifier
	icon.self_modulate = Color.WHITE
	icon.connect("mouse_entered",Callable(self,"_on_in_focus"))
	icon.connect("mouse_exited",Callable(self,"_on_out_of_focus"))
	
func _on_in_focus():
	emit_signal("OnInFocus", _data.description)

func _on_out_of_focus():
	emit_signal("OnOutOfFocus")
