extends Button

class_name SpellItemUI

var spellItem:Item
var _name:String

func init(spellItemObj):
	spellItem = spellItemObj
	self.text = spellItem.get_display_name()
	self.disabled = false

func init_as_empty(name:String):
	spellItem = null
	_name = name
	self.text = _name
	self.disabled = true

func revert_as_empty():
	spellItem = null
	self.text = _name
	self.disabled = true

func _on_mouse_entered():
	if spellItem!=null:
		CombatEventManager.on_show_info(spellItem.get_display_name(), spellItem.get_full_description())

func _on_mouse_exited():
	if spellItem!=null:
		CombatEventManager.on_hide_info()
