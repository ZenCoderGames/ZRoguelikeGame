extends Node

class_name EquippedItemUI

onready var descLabel:Label = get_node("DescLabel")

var item:Item

func init(itemObj):
	item = itemObj
	descLabel.text = item.get_display_name()
