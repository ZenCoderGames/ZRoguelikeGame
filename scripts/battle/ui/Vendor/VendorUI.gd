extends Control

class_name VendorUI

@onready var itemHolder:HBoxContainer = $"%Items"
@onready var title:Label = $"%Title"
@onready var backBtn:TextureButton = $"%BackButton"

const VendorItemUI := preload("res://ui/battle/VendorItemUI.tscn")

var initialized:bool = false

var _vendorChar:VendorCharacter
var _vendorData:VendorData
var _vendorItemList:Array

func init(vendorChar:VendorCharacter, vendorData:VendorData):
	if initialized:
		return

	_vendorChar = vendorChar
	_vendorData = vendorData
	title.text = vendorData.displayName
	var maxItemsToDisplay:int = vendorData.numItemsShown

	var itemsToConsider:Array = []

	if vendorData.abilities.size()>0:
		for abilityId in vendorData.abilities:
			itemsToConsider.append(GameGlobals.dataManager.get_ability_data(abilityId))

	if vendorData.specials.size()>0:
		for specialId in vendorData.specials:
			itemsToConsider.append(GameGlobals.dataManager.get_special_data(specialId))

	if vendorData.passives.size()>0:
		for passiveId in vendorData.passives:
			itemsToConsider.append(GameGlobals.dataManager.get_passive_data(passiveId))

	if vendorData.items.size()>0:
		for itemId in vendorData.items:
			itemsToConsider.append(GameGlobals.dataManager.get_item_data(itemId))

	if vendorData.runes.size()>0:
		for runeId in vendorData.runes:
			itemsToConsider.append(GameGlobals.dataManager.get_item_data(runeId))

	itemsToConsider.shuffle()
	for item in itemsToConsider:
		var vendorItem = VendorItemUI.instantiate()
		itemHolder.add_child(vendorItem)
		_vendorItemList.append(vendorItem)
		vendorItem.init(self, item)
		maxItemsToDisplay = maxItemsToDisplay - 1
		if maxItemsToDisplay==0:
			break

	backBtn.connect("button_up",Callable(self,"_on_back_pressed"))

	UIEventManager.emit_signal("OnGenericUIEvent")

	initialized = true

func _on_back_pressed():
	CombatEventManager.emit_signal("OnVendorClosed")
	UIEventManager.emit_signal("OnGenericUIEvent")

func item_bought():
	if !_vendorData.oneTimePurchaseOnly:
		for vendorItem in _vendorItemList:
			vendorItem.refresh()
	else:
		CombatEventManager.emit_signal("OnVendorClosed")
		UIEventManager.emit_signal("OnGenericUIEvent")
		_vendorChar.cell.room.clear_entity_in_cell(_vendorChar.cell)

func onlyUniquePurchases():
	return _vendorData.onlyUniquePurchases
