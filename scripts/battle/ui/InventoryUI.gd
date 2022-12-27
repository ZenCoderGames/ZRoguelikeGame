extends Node

class_name InventoryUI

onready var itemList:VBoxContainer = get_node("Content/HSplitContainer/ItemPanel/Bg/MarginContainer/ItemList/VBoxContainer")
const InventoryItem := preload("res://ui/battle/InventoryItem.tscn")

onready var noContent:Node = get_node("NoContent")

onready var nameLabel:Label = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/NameContainer/NameLabel")
onready var typeLabel:Label = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/TypeContainer/TypeLabel")
onready var descLabel:Label = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/DescContainer/DescLabel")
onready var equipButton:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/EquipButton")
onready var unequipButton:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/UnequipButton")
onready var consumeButton:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/ConsumeButton")
onready var equippedUI:ColorRect = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/EquippedUI")

var playerChar:Character
var itemButtons:Array
var itemDict:Dictionary = {}
var selectedIdx:int

func _ready():
	hide()
	equipButton.connect("pressed", self, "_on_equip_selected_item")
	unequipButton.connect("pressed", self, "_on_unequip_selected_item")
	consumeButton.connect("pressed", self, "_on_consume_selected_item")
	
func init(character):
	playerChar = character
	playerChar.inventory.connect("OnItemAdded", self, "_on_item_added_to_inventory")
	playerChar.equipment.connect("OnSpellActivated", self, "_on_spell_activated")
	
func show():
	selectedIdx = 0
	_refresh_ui()
	self.visible = true
	
func hide():
	self.visible = false
	noContent.visible = false
	
func _on_item_added_to_inventory(_itemPicked):
	selectedIdx = 0
	_refresh_ui()

func _on_spell_activated(_spellItem):
	selectedIdx = 0
	_refresh_ui()
	
func _refresh_ui():
	clear_items()

	var idx:int = 0
	for item in playerChar.inventory.items:
		var itemButton:Button = InventoryItem.instance()
		itemList.add_child(itemButton)
		itemButton.text = item.get_display_name()
		itemButton.clip_text = true
		itemButton.connect("pressed", self, "_on_item_selected", [idx])
		itemButtons.append(itemButton)
		itemDict[itemButton] = item
		idx = idx + 1

	if playerChar.inventory.items.size()>0:
		_show_selected()
	else:
		noContent.visible = true

func _show_selected():
	var selectedItemButton:Button = itemButtons[selectedIdx]
	var selectedItem:Item = playerChar.inventory.items[selectedIdx]
	selectedItemButton.self_modulate = Color.orange
	nameLabel.text = selectedItem.get_display_name() 
	descLabel.text = selectedItem.get_full_description()
	consumeButton.visible = false
	if selectedItem.is_spell():
		equipButton.visible = !playerChar.equipment.equippedSpells.has(selectedItem)
		unequipButton.visible = playerChar.equipment.equippedSpells.has(selectedItem)
	elif selectedItem.is_consumable():
		equipButton.visible = false
		unequipButton.visible = false
		consumeButton.visible = true
	else:
		equipButton.visible = !playerChar.equipment.equippedItems.has(selectedItem)
		unequipButton.visible = playerChar.equipment.equippedItems.has(selectedItem)
	equippedUI.visible = (playerChar.equipment.equippedItems.has(selectedItem) or playerChar.equipment.equippedSpells.has(selectedItem)) and !selectedItem.is_consumable()
	if selectedItem.is_consumable():
		typeLabel.text = "Consumable"
	elif selectedItem.is_spell():
		typeLabel.text = "Spell"
	else:
		typeLabel.text = selectedItem.get_slot_string()

func _on_equip_selected_item():
	var selectedItem:Item = playerChar.inventory.items[selectedIdx]
	playerChar.equipment.equip_item(selectedItem)
	_refresh_ui()

func _on_unequip_selected_item():
	var selectedItem:Item = playerChar.inventory.items[selectedIdx]
	playerChar.equipment.unequip_item(selectedItem)
	_refresh_ui()

func _on_consume_selected_item():
	var selectedItem:Item = playerChar.inventory.items[selectedIdx]
	playerChar.inventory.consume_item(selectedItem)
	selectedIdx = 0
	_refresh_ui()

func _on_item_selected(idx):
	selectedIdx = idx
	_refresh_ui()

func clear_items():
	for itemButton in itemButtons:
		if !weakref(itemButton).get_ref():
			continue

		itemButton.queue_free()
	itemButtons.clear()
	itemDict.clear()
	
	nameLabel.text = ""
	descLabel.text = ""
	typeLabel.text = ""
	equipButton.visible = false
	consumeButton.visible = false
	equippedUI.visible = false
	noContent.visible = false

func clean_up():
	clear_items()
	selectedIdx = -1
	hide()
