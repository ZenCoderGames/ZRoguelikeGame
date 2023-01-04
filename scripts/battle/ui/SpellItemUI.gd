extends Button

class_name SpellItemUI

var spellItem:Item

func init(spellItemObj):
	spellItem = spellItemObj
	self.text = spellItem.get_display_name()
	self.disabled = false

func init_as_empty(idx:int):
	spellItem = null
	self.text = str("Spell Slot")
	self.disabled = true

func _on_mouse_entered():
	if spellItem!=null:
		CombatEventManager.on_show_info(spellItem.get_display_name(), spellItem.get_full_description())

func _on_mouse_exited():
	if spellItem!=null:
		CombatEventManager.on_hide_info()
