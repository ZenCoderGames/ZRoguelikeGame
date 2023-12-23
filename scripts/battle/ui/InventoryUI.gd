extends Node

class_name InventoryUI

@onready var itemList:VBoxContainer = get_node("Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/MarginContainer/ItemList/VBoxContainer")
const InventoryItem := preload("res://ui/battle/InventoryItem.tscn")

@onready var noContent:Node = get_node("NoContent")

@onready var nameLabel:Label = $"%NameLabel"
@onready var typeLabel:Label = $"%TypeLabel"
@onready var descLabel:Label = $"%DescLabel"
@onready var equipButton:Button = $"%EquipButton"
@onready var equipButtonRune1:Button = $"%EquipButton_Rune1"
@onready var equipButtonRune2:Button = $"%EquipButton_Rune2"
@onready var equipButtonSpell1:Button = $"%EquipButton_Spell1"
@onready var equipButtonSpell2:Button = $"%EquipButton_Spell2"
@onready var equipButtonSpell3:Button = $"%EquipButton_Spell3"
@onready var equipButtonSpell4:Button = $"%EquipButton_Spell4"

@onready var unequipButton:Button = $"%UnequipButton"
@onready var consumeButton:Button = $"%ConsumeButton"
@onready var convertToSoulsButton:Button = $"%ConvertToSouls"

@onready var equippedUI:ColorRect = $"%EquippedUI"

@onready var sortAllButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/AllButton
@onready var sortWeaponButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/WeaponButton
@onready var sortArmorButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/ArmorButton
@onready var sortRuneButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/RuneButton
@onready var sortSpellButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/SpellButton
@onready var sortItemButton:Button = $Content/HSplitContainer/ItemPanel/Bg/VBoxContainer/HBoxContainer/ItemButton

enum SORT_OPTIONS { ALL, WEAPON, ARMOR, RUNE, SPELL, ITEM }
var _sortOption:int

var playerChar:Character
var itemButtons:Array
var itemDict:Dictionary = {}
var selectedIdx:int
var sortedItemList:Array

func _ready():
	hide()
	equipButton.connect("pressed",Callable(self,"_on_equip_selected_weapon_or_armor"))
	equipButtonRune1.connect("pressed",Callable(self,"_on_equip_selected_rune1"))
	equipButtonRune2.connect("pressed",Callable(self,"_on_equip_selected_rune2"))
	equipButtonSpell1.connect("pressed",Callable(self,"_on_equip_selected_spell1"))
	equipButtonSpell2.connect("pressed",Callable(self,"_on_equip_selected_spell2"))
	equipButtonSpell3.connect("pressed",Callable(self,"_on_equip_selected_spell3"))
	equipButtonSpell4.connect("pressed",Callable(self,"_on_equip_selected_spell4"))
	unequipButton.connect("pressed",Callable(self,"_on_unequip_selected_item"))
	consumeButton.connect("pressed",Callable(self,"_on_consume_selected_item"))
	convertToSoulsButton.connect("pressed",Callable(self,"_on_convert_to_souls_selected"))
	sortAllButton.connect("pressed",Callable(self,"_on_sort_all_button"))
	sortWeaponButton.connect("pressed",Callable(self,"_on_sort_weapon_button"))
	sortArmorButton.connect("pressed",Callable(self,"_on_sort_armor_button"))
	sortRuneButton.connect("pressed",Callable(self,"_on_sort_rune_button"))
	sortSpellButton.connect("pressed",Callable(self,"_on_sort_spell_button"))
	sortItemButton.connect("pressed",Callable(self,"_on_sort_item_button"))
	
func init(character):
	playerChar = character
	playerChar.inventory.connect("OnItemAdded",Callable(self,"_on_item_added_to_inventory"))
	playerChar.equipment.connect("OnSpellActivated",Callable(self,"_on_spell_activated"))
	
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
		if _sortOption == SORT_OPTIONS.ITEM and !item.data.is_consumable():
			continue

		var itemButton:Button = InventoryItem.instantiate()
		itemList.add_child(itemButton)
		itemButton.text = item.get_display_name()
		itemButton.clip_text = true
		itemButton.connect("pressed",Callable(self,"_on_item_selected").bind(idx))
		itemButtons.append(itemButton)
		itemDict[itemButton] = item
		sortedItemList.append(item)
		idx = idx + 1

	if idx>0:
		_show_selected()
	else:
		noContent.visible = true
		await get_tree().create_timer(0.5).timeout
		_on_sort_all_button()

func _show_selected():
	var selectedItemButton:Button = itemButtons[selectedIdx]
	var selectedItem:Item = sortedItemList[selectedIdx]
	selectedItemButton.self_modulate = Color.ORANGE
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
	convertToSoulsButton.visible = false
	if selectedItem.data.is_consumable():
		consumeButton.visible = true
		convertToSoulsButton.visible = true
		convertToSoulsButton.text = str("Convert to Souls (", str(selectedItem.data.soulCost), ")")
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
		convertToSoulsButton.text = str("Convert to Souls (", str(selectedItem.data.soulCost), ")")
		convertToSoulsButton.visible = true
	

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

func _on_convert_to_souls_selected():
	var selectedItem:Item = sortedItemList[selectedIdx]
	if playerChar.equipment.is_equipped(selectedItem):
		playerChar.equipment.unequip_item(selectedItem, playerChar.equipment.get_slot_for_item(selectedItem))
	playerChar.inventory.remove_item(selectedItem)
	playerChar.gain_souls(selectedItem.data.soulCost)
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

func _on_sort_item_button():
	_sortOption = SORT_OPTIONS.ITEM
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
