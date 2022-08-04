extends Node

onready var nameLabel:Label = get_node("VBoxContainer/PanelContainer/NameLabel")
onready var descLabel:Label = get_node("VBoxContainer/PanelContainer3/DescLabel")

var item:Item

func init(entityObj):
	item = entityObj as Item
	nameLabel.text = item.get_display_name()
	descLabel.text = item.get_description()

func has_entity(entity):
	return item == entity
