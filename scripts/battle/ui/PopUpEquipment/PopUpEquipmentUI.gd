extends Control

class_name PopUpEquipmentUI

@onready var itemHolder:HBoxContainer = $"%Items"
@onready var title:Label = $"%Title"
@onready var backBtn:TextureButton = $"%BackButton"
@onready var noItemsLabel:Label = $"%NoItemsLabel"
@onready var attackLabel:Label = $"%AttackLabel"
@onready var healthLabel:Label = $"%HealthLabel"

const PopUpEquipmentItemUIClass := preload("res://ui/battle/PopUpEquipmentItemSelectUI.tscn")

var initialized:bool = false

var _popUpItemList:Array
var _newItem:Item
var _slotTypeArray:Array

signal OnStateChanged

func init(newItem:Item, slotTypeArray:Array):
	_newItem = newItem
	_slotTypeArray = slotTypeArray
	title.text = Equipment.GET_SLOT_TYPE_NAME(slotTypeArray)

	if initialized:
		for popUpItem in _popUpItemList:
			popUpItem.refresh()
		return

	_update_player_stats()
	GameGlobals.dungeon.player.connect("OnStatChanged",Callable(self,"_on_char_stat_changed"))

	# Currently Slot
	for equipmentSlot in slotTypeArray:
		var currentSlotPopUpItem = PopUpEquipmentItemUIClass.instantiate()
		itemHolder.add_child(currentSlotPopUpItem)
		if GameGlobals.dungeon.player.equipment.is_slot_free(equipmentSlot):	
			currentSlotPopUpItem.init(_popUpItemList.size(), self, null, equipmentSlot)
		else:
			currentSlotPopUpItem.init(_popUpItemList.size(), self, GameGlobals.dungeon.player.equipment.get_item_for_slot(equipmentSlot), equipmentSlot)
		_popUpItemList.append(currentSlotPopUpItem)

	# New Item
	if newItem!=null:
		var newPopUpItem = PopUpEquipmentItemUIClass.instantiate()
		itemHolder.add_child(newPopUpItem)
		newPopUpItem.init(_popUpItemList.size(), self, newItem, -1)
		_popUpItemList.append(newPopUpItem)

	backBtn.visible = newItem==null
	backBtn.connect("button_up",Callable(self,"_on_back_pressed"))

	UIEventManager.emit_signal("OnGenericUIEvent")
	GameEventManager.connect("OnBackButtonPressed",Callable(self,"_on_back_pressed"))

	initialized = true

func _on_back_pressed():
	clean_up()

func _on_char_stat_changed(_statChangeChar):
	_update_player_stats()

func _update_player_stats():
	attackLabel.text = str(GameGlobals.dungeon.player.get_damage())
	var health:int = GameGlobals.dungeon.player.get_health()
	var maxHealth:int = GameGlobals.dungeon.player.get_max_health()
	healthLabel.text = str(health)
	if health<maxHealth:
		healthLabel.self_modulate = Color.INDIAN_RED
	else:
		healthLabel.self_modulate = Color.WHITE

func item_equipped(_item:Item, slot:int):
	var currentSlotItem:Item = GameGlobals.dungeon.player.equipment.get_item_for_slot(slot)
	if currentSlotItem==null:
		GameGlobals.dungeon.player.equipment.equip_item(_newItem, slot)
		emit_signal("OnStateChanged", null, _slotTypeArray)
	else:
		GameGlobals.dungeon.player.equipment.unequip_item(currentSlotItem, slot)
		GameGlobals.dungeon.player.equipment.equip_item(_newItem, slot)
		emit_signal("OnStateChanged", currentSlotItem, _slotTypeArray)

func item_discarded(_item:Item, slot:int):
	if GameGlobals.dungeon.player.equipment.is_equipped(_item):
		GameGlobals.dungeon.player.equipment.unequip_item(_item, GameGlobals.dungeon.player.equipment.get_slot_for_item(_item))
	GameGlobals.dungeon.player.inventory.remove_item(_item)
	GameGlobals.dungeon.player.gain_souls(_item.data.soulCost)
	if slot!=-1:
		emit_signal("OnStateChanged", _newItem, _slotTypeArray)
	else:
		emit_signal("OnStateChanged", null, _slotTypeArray)

func clean_up():
	CombatEventManager.emit_signal("OnPopUpEquipmentClosed")
	UIEventManager.emit_signal("OnGenericUIEvent")
	if GameGlobals.dungeon.player!=null:
		GameGlobals.dungeon.player.disconnect("OnStatChanged",Callable(self,"_on_char_stat_changed"))

# UTILS
func has_new_item():
	return _newItem
