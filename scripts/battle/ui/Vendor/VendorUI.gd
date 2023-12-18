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
enum UPGRADE_TYPE { ABILITY, SPECIAL, PASSIVE }
var _upgradeType:UPGRADE_TYPE

func init(vendorChar:VendorCharacter, vendorData:VendorData):
	if initialized:
		return

	_vendorChar = vendorChar
	_vendorData = vendorData
	title.text = vendorData.displayName
	var maxItemsToDisplay:int = vendorData.numItemsShown

	if vendorData.abilities.size()>0:
		_upgradeType = UPGRADE_TYPE.ABILITY
		for abilityId in vendorData.abilities:
			var vendorItem = VendorItemUI.instantiate()
			itemHolder.add_child(vendorItem)
			vendorItem.init_as_ability(self, GameGlobals.dataManager.get_ability_data(abilityId))
			_vendorItemList.append(vendorItem)
			maxItemsToDisplay = maxItemsToDisplay - 1
			if maxItemsToDisplay==0:
				break

	if vendorData.specials.size()>0:
		_upgradeType = UPGRADE_TYPE.SPECIAL
		for specialId in vendorData.specials:
			var vendorItem = VendorItemUI.instantiate()
			itemHolder.add_child(vendorItem)
			vendorItem.init_as_special(self, GameGlobals.dataManager.get_special_data(specialId))
			_vendorItemList.append(vendorItem)
			maxItemsToDisplay = maxItemsToDisplay - 1
			if maxItemsToDisplay==0:
				break

	if vendorData.passives.size()>0:
		_upgradeType = UPGRADE_TYPE.PASSIVE
		for passiveId in vendorData.passives:
			var vendorItem = VendorItemUI.instantiate()
			itemHolder.add_child(vendorItem)
			vendorItem.init_as_passive(self, GameGlobals.dataManager.get_passive_data(passiveId))
			_vendorItemList.append(vendorItem)
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

func is_ability():
	return _upgradeType == UPGRADE_TYPE.ABILITY

func is_special():
	return _upgradeType == UPGRADE_TYPE.SPECIAL

func is_passive():
	return _upgradeType == UPGRADE_TYPE.PASSIVE

func onlyUniquePurchases():
	return _vendorData.onlyUniquePurchases
