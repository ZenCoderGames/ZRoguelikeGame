extends Control

class_name VendorUI

@onready var itemHolder:HBoxContainer = $"%Items"
@onready var title:Label = $"%Title"
@onready var backBtn:TextureButton = $"%BackButton"
@onready var noItemsLabel:Label = $"%NoItemsLabel"
@onready var attackLabel:Label = $"%AttackLabel"
@onready var healthLabel:Label = $"%HealthLabel"

const VendorItemSelectUI := preload("res://ui/battle/VendorItemSelectUI.tscn")

var initialized:bool = false

var _vendorChar:VendorCharacter
var _vendorData:VendorData
var _vendorItemList:Array

func _ready():
	backBtn.connect("button_up",Callable(self,"_on_back_pressed"))
	GameEventManager.connect("OnBackButtonPressed",Callable(self,"_on_back_pressed"))

func init(vendorChar:VendorCharacter, vendorData:VendorData):
	_update_player_stats()
	GameGlobals.dungeon.player.connect("OnStatChanged",Callable(self,"_on_char_stat_changed"))
	
	if initialized:
		for vendorItem in _vendorItemList:
			vendorItem.refresh()
		return

	_vendorChar = vendorChar
	_vendorData = vendorData
	title.text = vendorData.displayName
	var maxItemsToDisplay:int = vendorData.numItemsShown

	var itemsToConsider:Array = []

	if vendorData.abilities.size()>0:
		for abilityId in vendorData.abilities:
			var abilityData:AbilityData = GameGlobals.dataManager.get_ability_data(abilityId)
			if !_vendorData.onlyUniquePurchases or !_is_upgrade_owned(abilityData):
				if GameGlobals.battleInstance.startWithClasses:
					if abilityData.characterId!="" and abilityData.characterId!=GameGlobals.dungeon.player.charData.id:
						continue
				itemsToConsider.append(abilityData)

	if vendorData.specials.size()>0:
		for specialId in vendorData.specials:
			var specialData:SpecialData = GameGlobals.dataManager.get_special_data(specialId)
			if !_vendorData.onlyUniquePurchases or !_is_upgrade_owned(specialData):
				itemsToConsider.append(specialData)

	if vendorData.passives.size()>0:
		for passiveId in vendorData.passives:
			var passiveData:PassiveData = GameGlobals.dataManager.get_passive_data(passiveId)
			if !_vendorData.onlyUniquePurchases or !_is_upgrade_owned(passiveData):
				itemsToConsider.append(passiveData)

	if vendorData.items.size()>0:
		for itemId in vendorData.items:
			var itemData:ItemData = GameGlobals.dataManager.get_item_data(itemId)
			if !_vendorData.onlyUniquePurchases or !_is_upgrade_owned(itemData):
				itemsToConsider.append(itemData)

	if vendorData.runes.size()>0:
		for runeId in vendorData.runes:
			var itemData:ItemData = GameGlobals.dataManager.get_item_data(runeId)
			if !_vendorData.onlyUniquePurchases or !_is_upgrade_owned(itemData):
				itemsToConsider.append(itemData)

	itemsToConsider.shuffle()

	if itemsToConsider.size()==0:
		noItemsLabel.visible = true
	else:
		noItemsLabel.visible = false
		for item in itemsToConsider:
			var vendorItem = VendorItemSelectUI.instantiate()
			itemHolder.add_child(vendorItem)
			vendorItem.init(_vendorItemList.size(), self, item)
			_vendorItemList.append(vendorItem)
			maxItemsToDisplay = maxItemsToDisplay - 1
			if _vendorItemList.size()==0:
				vendorItem.set_selected(true)
			if maxItemsToDisplay==0:
				break

	UIEventManager.emit_signal("OnGenericUIEvent")

	initialized = true

func _on_back_pressed():
	CombatEventManager.emit_signal("OnVendorClosed")
	UIEventManager.emit_signal("OnGenericUIEvent")
	if GameGlobals.dungeon.player:
		GameGlobals.dungeon.player.disconnect("OnStatChanged",Callable(self,"_on_char_stat_changed"))

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

func _is_upgrade_owned(_data):
	if _data is AbilityData:
		return GameGlobals.dungeon.player.has_ability(_data)
	elif _data is SpecialData:
		return GameGlobals.dungeon.player.has_special(_data)
	elif _data is PassiveData:
		return GameGlobals.dungeon.player.has_passive(_data)
	elif _data is ItemData:
		return GameGlobals.dungeon.player.inventory.has_item(_data)

	return false

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
