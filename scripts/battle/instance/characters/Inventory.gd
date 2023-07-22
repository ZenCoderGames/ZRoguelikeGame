class_name Inventory

var items:Array = []

signal OnItemAdded(item)
signal OnConsumableItemAdded(item)
signal OnConsumableItemRemoved(item)

var character

func _init(characterRef):
	character = characterRef

func add_item(itemToAdd):
	items.append(itemToAdd)
	emit_signal("OnItemAdded", itemToAdd)
	itemToAdd.init_on_picked_up(character)
	if itemToAdd.data.is_consumable():
		emit_signal("OnConsumableItemAdded", itemToAdd)

func consume_item(item):
	item.consume(character)
	items.erase(item)
	if item.data.is_consumable():
		emit_signal("OnConsumableItemRemoved", item)

func remove_item(item):
	items.erase(item)
