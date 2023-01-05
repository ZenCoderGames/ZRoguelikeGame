extends Button

class_name SpellItemUI

var spellItem:Item
var _name:String

func init(spellItemObj):
	spellItem = spellItemObj
	self.text = spellItem.get_display_name()
	self.disabled = false
	CombatEventManager.connect("OnStartTurn", self, "_on_start_turn")
	GameGlobals.dungeon.player.equipment.connect("OnSpellActivated", self, "_on_spell_activated")

func init_as_empty(name:String):
	spellItem = null
	_name = name
	self.text = _name
	self.disabled = true

func revert_as_empty():
	GameGlobals.dungeon.player.equipment.disconnect("OnSpellActivated", self, "_on_spell_activated")
	CombatEventManager.disconnect("OnStartTurn", self, "_on_start_turn")
	spellItem = null
	self.text = _name
	self.disabled = true

func _on_mouse_entered():
	if spellItem!=null:
		CombatEventManager.on_show_info(spellItem.get_display_name(), spellItem.get_full_description())

func _on_mouse_exited():
	if spellItem!=null:
		CombatEventManager.on_hide_info()

func _on_start_turn():
	_refresh_ui()

func _refresh_ui():
	var remainingCooldown:int = spellItem.spell.get_remaining_cooldown()
	if remainingCooldown>0:
		self.text = spellItem.get_display_name() + " (" + str(remainingCooldown) + ")"
		self.disabled = true
	else:
		self.text = spellItem.get_display_name()
		self.disabled = false

func _on_spell_activated(spellItemObj):
	if spellItemObj==spellItem:
		_refresh_ui()
