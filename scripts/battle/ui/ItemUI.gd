extends Node

class_name ItemUI

@onready var nameBg:ColorRect = $"%NameBg"
@onready var nameLabel:Label = $"%NameLabel"
@onready var descLabel:Label = $"%DescLabel"

var item

func init(itemInstance):
	item = itemInstance
	nameLabel.text = item.get_display_name()
	descLabel.text = item.get_description()
	if itemInstance is Item:
		if itemInstance.data.is_gear():
			nameBg.color = GameGlobals.battleInstance.view.itemGearColor
		elif itemInstance.data.is_consumable():
			nameBg.color = GameGlobals.battleInstance.view.itemConsumableColor
		elif itemInstance.data.is_spell():
				nameBg.color = GameGlobals.battleInstance.view.itemSpellColor

func has_entity(entity):
	return item == entity
