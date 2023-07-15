extends TextureRect

class_name EffectItemUI

@onready var counterLabel:Label = $NameLabel

var item

func init(itemObj, color:Color):
	item = itemObj
	#descLabel.text = item.data.get_display_name()
	if item is Passive:
		var passiveItem:Passive = item as Passive
		if passiveItem.has_counter():
			CombatEventManager.connect("OnStartTurn",Callable(self,"_update_for_passive"))
			counterLabel.visible = true
			_update_for_passive()
	self.self_modulate = color

func _on_mouse_entered():
	CombatEventManager.on_show_info(item.data.get_display_name(), item.data.get_description())

func _on_mouse_exited():
	CombatEventManager.on_hide_info()

func _update_for_passive():
	var passiveItem:Passive = item as Passive
	counterLabel.text = str(passiveItem.get_remaining_to_trigger())
