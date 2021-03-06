extends Node2D

class_name Item

var data:ItemData
var cell:DungeonCell

func init(itemData, myCell):
	data = itemData
	cell = myCell
	self.position = Vector2(cell.pos.x, cell.pos.y)

func activate(character):
	if data.is_consumable():
		for statModifier in data.statModifierDataList:
			character.modify_stat_value_from_modifier(statModifier)

func deactivate(character):
	pass

func picked():
	if cell.entityObject!=null:
		cell.entityObject.hide()
	cell.clear_entity()
