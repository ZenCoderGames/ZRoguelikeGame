extends Button

class_name SpellItemUI

var spellItem:Item

func init(spellItemObj):
	spellItem = spellItemObj
	self.text = spellItem.get_display_name()

func _on_mouse_entered():
	CombatEventManager.on_show_info(spellItem.get_display_name(), spellItem.get_full_description())

func _on_mouse_exited():
	CombatEventManager.on_hide_info()
