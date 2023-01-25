extends Node

class_name InventoryUI

onready var itemList:VBoxContainer = get_node("Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/MarginContainer/ItemList/VBoxContainer")
const InventoryItem := preload("res://ui/battle/InventoryItem.tscn")

onready var noContent:Node = get_node("NoContent")

onready var nameLabel:Label = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/NameContainer/NameLabel")
onready var typeLabel:Label = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/TypeContainer/TypeLabel")
onready var descLabel:Label = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/DescContainer/DescLabel")
onready var equipButton:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/EquipButton")
onready var equipButtonRune1:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/EquipButton_Rune1")
onready var equipButtonRune2:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/EquipButton_Rune2")
onready var equipButtonSpell1:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/EquipButton_Spell1")
onready var equipButtonSpell2:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/EquipButton_Spell2")
onready var equipButtonSpell3:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/EquipButton_Spell3")
onready var equipButtonSpell4:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/EquipButton_Spell4")

onready var unequipButton:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/UnequipButton")
onready var consumeButton:Button = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/ConsumeButton")
onready var equippedUI:ColorRect = get_node("Content/HSplitContainer/DetailsPanel/Bg/MarginContainer/VBoxContainer/HBoxContainer/EquippedUI")

onready var sortAllButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/AllButton
onready var sortWeaponButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/WeaponButton
onready var sortArmorButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/ArmorButton
onready var sortRuneButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/RuneButton
onready var sortSpellButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/SpellButton

enum SORT_OPTIONS { ALL, WEAPON, ARMOR, RUNE, SPELL }
var _sortOption:int

var playerChar:Character
var itemButtons:Array
var itemDict:Dictionary = {}
var selectedIdx:int
var sortedItemList:Array

func _ready():
	hide()
	equipButton.connect("pressed", self, "_on_equip_selected_weapon_or_armor")
	equipButtonRune1.connect("pressed", self, "_on_equip_selected_rune1")
	equipButtonRune2.connect("pressed", self, "_on_equip_selected_rune2")
	equipButtonSpell1.connect("pressed", self, "_on_equip_selected_spell1")
	equipButtonSpell2.connect("pressed", self, "_on_equip_selected_spell2")
	equipButtonSpell3.connect("pressed", self, "_on_equip_selected_spell3")
	equipButtonSpell4.connect("pressed", self, "_on_equip_selected_spell4")
	unequipButton.connect("pressed", self, "_on_unequip_selected_item")
	consumeButton.connect("pressed", self, "_on_consume_selected_item")
	sortAllButton.connect("pressed", self, "_on_sort_all_button")
	sortWeaponButton.connect("pressed", self, "_on_sort_weapon_button")
	sortArmorButton.connect("pressed", self, "_on_sort_armor_button")
	sortRuneButton.connect("pressed", self, "_on_sort_rune_button")
	sortSpellButton.connect("pressed", self, "_on_sort_spell_button")
	
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
		if _sortOption == SORT_OPTIONS.WEAPON and !item.data.is_weapon():
			continue
		if _sortOption == SORT_OPTIONS.ARMOR and !item.data.is_armor():
			continue
		if _sortOption == SORT_OPTIONS.RUNE and !item.data.is_rune():
			continue
		if _sortOption == SORT_OPTIONS.SPELL and !item.data.is_spell():
			continue

		var itemButton:Button = InventoryItem.instance()
		itemList.add_child(itemButton)
		itemButton.text = item.get_display_name()
		itemButton.clip_text = true
		itemButton.connect("pressed", self, "_on_item_selected", [idx])
		itemButtons.append(itemButton)
		itemDict[itemButton] = item
		sortedItemList.append(item)
		idx = idx + 1

	if idx>0:
		_show_selected()
	else:
		noContent.visible = true

func _show_selected():
	var selectedItemButton:Button = itemButtons[selectedIdx]
	var selectedItem:Item = sortedItemList[selectedIdx]
	selectedItemButton.self_modulate = Color.orange
	nameLabel.text = selectedItem.get_display_name() 
	descLabel.text = selectedItem.get_full_description()
	typeLabel.text = selectedItem.data.get_type_string()
	consumeButton.visible = false
	equipButton.visible = false
	unequipButton.visible = false
	equipButtonRune1.visible = false
	equipButtonRune2.visible = false
	equipButtonSpell1.visible = false
	equipButtonSpell2.visible = false
	equipButtonSpell3.visible = false
	equipButtonSpell4.visible = false
	equippedUI.visible = false
	if selectedItem.data.is_consumable():
		consumeButton.visible = true
	else:
		var isEquippedItem:bool = playerChar.equipment.equippedItems.has(selectedItem)
		unequipButton.visible = isEquippedItem
		if !isEquippedItem:
			equipButton.visible = (selectedItem.data.is_weapon() or selectedItem.data.is_armor())
			equipButtonRune1.visible = selectedItem.data.is_rune()
			equipButtonRune2.visible = selectedItem.data.is_rune()
			equipButtonSpell1.visible = selectedItem.data.is_spell()
			equipButtonSpell2.visible = selectedItem.data.is_spell()
			equipButtonSpell3.visible = selectedItem.data.is_spell() and playerChar.maxSpellSlots>2
			equipButtonSpell4.visible = selectedItem.data.is_spell() and playerChar.maxSpellSlots>3
		equippedUI.visible = isEquippedItem
	

func _on_equip_selected_weapon_or_armor():
	var selectedItem:Item = sortedItemList[selectedIdx]
	var slot:int = 0
	if selectedItem.data.is_weapon():
		slot = Constants.ITEM_EQUIP_SLOT.WEAPON
	elif selectedItem.data.is_armor():
		slot = Constants.ITEM_EQUIP_SLOT.ARMOR
	playerChar.equipment.equip_item(selectedItem, slot)
	_refresh_ui()

func _on_equip_selected_rune1():
	var selectedItem:Item = sortedItemList[selectedIdx]
	playerChar.equipment.equip_item(selectedItem, Constants.ITEM_EQUIP_SLOT.RUNE_1)
	_refresh_ui()

func _on_equip_selected_rune2():
	var selectedItem:Item = sortedItemList[selectedIdx]
	playerChar.equipment.equip_item(selectedItem, Constants.ITEM_EQUIP_SLOT.RUNE_2)
	_refresh_ui()

func _on_equip_selected_spell1():
	var selectedItem:Item = sortedItemList[selectedIdx]
	playerChar.equipment.equip_item(selectedItem, Constants.ITEM_EQUIP_SLOT.SPELL_1)
	_refresh_ui()

func _on_equip_selected_spell2():
	var selectedItem:Item = sortedItemList[selectedIdx]
	playerChar.equipment.equip_item(selectedItem, Constants.ITEM_EQUIP_SLOT.SPELL_2)
	_refresh_ui()

func _on_equip_selected_spell3():
	var selectedItem:Item = sortedItemList[selectedIdx]
	playerChar.equipment.equip_item(selectedItem, Constants.ITEM_EQUIP_SLOT.SPELL_3)
	_refresh_ui()

func _on_equip_selected_spell4():
	var selectedItem:Item = sortedItemList[selectedIdx]
	playerChar.equipment.equip_item(selectedItem, Constants.ITEM_EQUIP_SLOT.SPELL_4)
	_refresh_ui()

func _on_unequip_selected_item():
	var selectedItem:Item = sortedItemList[selectedIdx]
	playerChar.equipment.unequip_item(selectedItem, playerChar.equipment.get_slot_for_item(selectedItem))
	_refresh_ui()

func _on_consume_selected_item():
	var selectedItem:Item = sortedItemList[selectedIdx]
	playerChar.inventory.consume_item(selectedItem)
	selectedIdx = 0
	_refresh_ui()

func _on_item_selected(idx):
	selectedIdx = idx
	_refresh_ui()

func _on_sort_all_button():
	_sortOption = SORT_OPTIONS.ALL
	selectedIdx = 0
	_refresh_ui()

func _on_sort_weapon_button():
	_sortOption = SORT_OPTIONS.WEAPON
	selectedIdx = 0
	_refresh_ui()

func _on_sort_armor_button():
	_sortOption = SORT_OPTIONS.ARMOR
	selectedIdx = 0
	_refresh_ui()

func _on_sort_rune_button():
	_sortOption = SORT_OPTIONS.RUNE
	selectedIdx = 0
	_refresh_ui()

func _on_sort_spell_button():
	_sortOption = SORT_OPTIONS.SPELL
	selectedIdx = 0
	_refresh_ui()

func clear_items():
	for itemButton in itemButtons:
		if !weakref(itemButton).get_ref():
			continue

		itemButton.queue_free()
	itemButtons.clear()
	itemDict.clear()
	sortedItemList.clear()
	
	nameLabel.text = ""
	descLabel.text = ""
	typeLabel.text = ""
	equipButton.visible = false
	equipButtonRune1.visible = false
	equipButtonRune2.visible = false
	equipButtonSpell1.visible = false
	equipButtonSpell2.visible = false
	equipButtonSpell3.visible = false
	equipButtonSpell4.visible = false
	consumeButton.visible = false
	equippedUI.visible = false
	noContent.visible = false

func clean_up():
	clear_items()
	selectedIdx = -1
	hide()
