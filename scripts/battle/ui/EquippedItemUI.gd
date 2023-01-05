extends Node

class_name EquippedItemUI

onready var descLabel:Label = $DescLabel
onready var bgRect:ColorRect = $Bg

var item:Item
var _name:String

func init(itemObj):
	item = itemObj
	descLabel.text = item.get_display_name()
	bgRect.visible = true

func init_as_empty(slotName):
	item = null
	_name = slotName
	descLabel.text = slotName
	bgRect.visible = false

func revert_as_empty():
	item = null
	descLabel.text = _name
	bgRect.visible = false

func _on_Items_mouse_entered():
	if item!=null:
		CombatEventManager.on_show_info(item.get_display_name(), item.get_description())

func _on_Items_mouse_exited():
	if item!=null:
		CombatEventManager.on_hide_info()
