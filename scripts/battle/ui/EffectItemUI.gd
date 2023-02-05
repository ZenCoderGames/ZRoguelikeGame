extends PanelContainer

class_name EffectItemUI

onready var descLabel:Label = $NameLabel

var item

func init(itemObj):
	item = itemObj
	descLabel.text = item.data.get_display_name()
	#if item is Passive:
	#	if item.has_counter():
	#		CombatEventManager.connect("OnStartTurn", self, "_update_for_passive")

func _on_mouse_entered():
	CombatEventManager.on_show_info(item.data.get_display_name(), item.data.get_description())

func _on_mouse_exited():
	CombatEventManager.on_hide_info()

func _update_for_passive():
	descLabel.text = str(item.data.get_display_name(), "(", item.get_remaining_to_trigger(), ")")
