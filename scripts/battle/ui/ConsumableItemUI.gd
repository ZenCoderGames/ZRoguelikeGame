extends Button

class_name ConsumableItemUI

var consumableItem:Item

func init(consumableItemObj):
	consumableItem = consumableItemObj
	#self.text = consumableItem.get_display_name()
	self.disabled = false
	GameGlobals.dungeon.player.equipment.connect("OnSpellActivated",Callable(self,"_on_spell_activated"))
	self.connect("pressed",Callable(self,"_on_consumable_activated"))
	self.self_modulate = consumableItem.data.tintColor

func _on_mouse_entered():
	if consumableItem!=null:
		CombatEventManager.on_show_info(consumableItem.get_display_name(), consumableItem.get_full_description())

func _on_mouse_exited():
	if consumableItem!=null:
		CombatEventManager.on_hide_info()

func _on_consumable_activated():
	GameGlobals.dungeon.player.inventory.consume_item(consumableItem)
	CombatEventManager.on_hide_info()
