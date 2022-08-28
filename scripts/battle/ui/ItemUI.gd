extends Node

class_name ItemUI

onready var nameBg:ColorRect = $"%NameBg"
onready var nameLabel:Label = $"%NameLabel"
onready var descLabel:Label = $"%DescLabel"

var item:Item

func init(itemInstance:Item):
	item = itemInstance
	nameLabel.text = item.get_display_name()
	descLabel.text = item.get_description()
	if itemInstance.is_gear():
		nameBg.color = Dungeon.battleInstance.view.itemGearColor
	elif itemInstance.is_consumable():
		nameBg.color = Dungeon.battleInstance.view.itemConsumableColor
	elif itemInstance.is_spell():
			nameBg.color = Dungeon.battleInstance.view.itemSpellColor

func has_entity(entity):
	return item == entity
