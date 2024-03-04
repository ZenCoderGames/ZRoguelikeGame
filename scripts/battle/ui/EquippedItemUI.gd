extends Node

class_name EquippedItemUI

@onready var descLabel:Label = $DescLabel
@onready var bgRect:ColorRect = $Bg
@onready var button:Button = $"%Button"

var item:Item
var _name:String

func init(itemObj):
	item = itemObj
	descLabel.text = item.get_display_name()
	bgRect.visible = true
	button.connect("button_up",Callable(self,"_on_button_pressed"))

func init_as_empty(slotName):
	item = null
	_name = slotName
	descLabel.text = slotName
	bgRect.visible = false
	button.connect("button_up",Callable(self,"_on_button_pressed"))

func revert_as_empty():
	item = null
	descLabel.text = _name
	bgRect.visible = false

func _on_Items_mouse_entered():
	if item!=null:
		CombatEventManager.on_show_info(item.get_display_name(), item.get_description())
	else:
		CombatEventManager.on_show_info("Item Slot", str(_name, " can be equipped here.")) 

func _on_Items_mouse_exited():
	if item!=null:
		CombatEventManager.on_hide_info()

func _on_button_pressed():
	if item!=null:
		GameGlobals.dungeon.player.equipment.show_equip_ui_for_slot(item)
