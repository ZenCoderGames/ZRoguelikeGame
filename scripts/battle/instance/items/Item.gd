extends Node2D

class_name Item

var data:ItemData
var cell:DungeonCell
var spell:Spell
var passive:Passive
@onready var hoverInfo:HoverInfo = $"%HoverInfo"

func init(itemData, myCell):
	data = itemData
	cell = myCell
	self.position = Vector2(cell.pos.x, cell.pos.y)
	hoverInfo.setup_far("Item", "This is an Item. Get Close to Identify.")
	hoverInfo.setup(get_display_name(), get_description(), cell)

func init_on_picked_up(character):
	if data.spellId != "":
		spell = Spell.new(GameGlobals.dataManager.get_spell_data(data.spellId), character)

func consume(character):
	if data.is_consumable():
		for statModifier in data.statModifierDataList:
			character.modify_stat_value_from_modifier(statModifier)
		if !data.statusEffectId.is_empty():
			var statusEffectData:StatusEffectData = GameGlobals.dataManager.get_status_effect_data(data.statusEffectId)
			character.add_status_effect(character, statusEffectData)
		CombatEventManager.emit_signal("OnConsumeItem", data)

func can_activate()->bool:
	if spell!=null:
		return spell.can_activate()

	return true

func activate():
	if spell!=null:
		spell.activate()

func picked():
	if cell.entityObject!=null:
		cell.entityObject.hide()
	cell.clear_entity()

func on_equipped(character):
	if !data.passiveId.is_empty():
		passive = character.add_passive(GameGlobals.dataManager.get_passive_data(data.passiveId))
	
func on_unequipped(character):
	if !data.passiveId.is_empty():
		passive.clear_events()
		character.remove_passive(passive)
		passive = null

func get_display_name():
	return data.name

func get_description():
	return data.description

func get_full_description():
	return data.fullDescription
