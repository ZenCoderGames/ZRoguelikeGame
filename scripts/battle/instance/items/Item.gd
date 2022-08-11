extends Node2D

class_name Item

var data:ItemData
var cell:DungeonCell

func init(itemData, myCell):
	data = itemData
	cell = myCell
	self.position = Vector2(cell.pos.x, cell.pos.y)

func consume(character):
	if data.is_consumable():
		for statModifier in data.statModifierDataList:
			character.modify_stat_value_from_modifier(statModifier)

func activate():
	pass

func picked():
	if cell.entityObject!=null:
		cell.entityObject.hide()
	cell.clear_entity()

func get_display_name():
	return data.displayName

func get_description():
	return data.description

func get_full_description():
	return data.fullDescription

func is_equippable():
	return data.is_equippable()

func is_consumable():
	return data.is_consumable()

func is_spell():
	return data.is_spell()

func get_slot():
	return data.slot

func get_slot_string():
	if data.slot == Constants.ITEM_EQUIP_SLOT.WEAPON:
		return "Weapon"
	elif data.slot == Constants.ITEM_EQUIP_SLOT.BODY:
		return "Body"

	return "[None]"
