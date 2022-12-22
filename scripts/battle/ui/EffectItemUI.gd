extends PanelContainer

class_name EffectItemUI

onready var descLabel:Label = $NameLabel

var item

func init(itemObj):
	item = itemObj
	descLabel.text = item.get_display_name()

func _on_mouse_entered():
	CombatEventManager.on_show_info(item.get_display_name(), item.get_description())

func _on_mouse_exited():
	CombatEventManager.on_hide_info()
