class_name Inventory

var items:Array = []

signal OnItemAdded(item)

var character

func _init(characterRef):
	character = characterRef

func add_item(itemToAdd):
	items.append(itemToAdd)
	emit_signal("OnItemAdded", itemToAdd)
	itemToAdd.init_on_picked_up(character)

func consume_item(item):
	item.consume(character)
	items.erase(item)

func remove_item(item):
	items.erase(item)
