class_name Equipment

var equippedItems:Array = []
var equippedSlots:Dictionary = {}

var character

signal OnItemEquipped(item)
signal OnItemUnEquipped(item)
signal OnSpellActivated(item)

func _init(characterRef):
	character = characterRef
	equippedSlots[Constants.ITEM_EQUIP_SLOT.WEAPON] = null
	equippedSlots[Constants.ITEM_EQUIP_SLOT.ARMOR] = null
	equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_1] = null
	equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_2] = null
	equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_3] = null
	equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_4] = null
	equippedSlots[Constants.ITEM_EQUIP_SLOT.RUNE_1] = null
	equippedSlots[Constants.ITEM_EQUIP_SLOT.RUNE_2] = null
	character.inventory.connect("OnItemAdded", self, "_on_item_added")

func _on_item_added(item:Item):
	var freeSlot:int = _get_free_slot(item.data)
	if freeSlot>=0:
		equip_item(item, freeSlot)

func get_stat_bonus_from_equipped_items(statType):
	var statValue:int = 0
	# iterate through items
	for item in equippedItems:
		for statData in item.data.statDataList:
			if statData.type == statType:
				statValue = statValue + statData.value
			else:
				if GameGlobals.dataManager.is_complex_stat_data(statData.type):
					var complexStatData:ComplexStatData = GameGlobals.dataManager.get_complex_stat_data(statData.type)
					if complexStatData.linkedStatType == statType:
						statValue = statValue + statData.value * complexStatData.linkedStatMultiplier
	
	return statValue

func get_stat_base_bonus_from_equipped_items(statType):
	var statBaseValue:int = 0
	# iterate through items
	for item in equippedItems:
		for statData in item.data.statDataList:
			if statData.type == statType:
				statBaseValue = statBaseValue + statData.baseValue

	return statBaseValue

func equip_item(item, slotType:int):
	if equippedSlots[slotType] != null:
		unequip_item(equippedSlots[slotType], slotType)
	equippedItems.append(item)
	equippedSlots[slotType] = item
	item.on_equipped(character)
	emit_signal("OnItemEquipped", item)

func unequip_item(item, slotType:int):
	equippedItems.erase(equippedSlots[slotType])
	item.on_unequipped(character)
	equippedSlots[slotType] = null
	emit_signal("OnItemUnEquipped", item)

func activate_spell(spellItem):
	spellItem.activate()
	#character.inventory.remove_item(spellItem)
	emit_signal("OnSpellActivated", spellItem)
	character.on_spell_activated(spellItem)

# SLOTS
func _get_free_slot(itemData:ItemData):
	if itemData.is_weapon():
		if equippedSlots[Constants.ITEM_EQUIP_SLOT.WEAPON] == null:
			return Constants.ITEM_EQUIP_SLOT.WEAPON
	elif itemData.is_armor():
		if equippedSlots[Constants.ITEM_EQUIP_SLOT.ARMOR] == null:
			return Constants.ITEM_EQUIP_SLOT.ARMOR	
	elif itemData.is_rune():
		if equippedSlots[Constants.ITEM_EQUIP_SLOT.RUNE_1] == null:
			return Constants.ITEM_EQUIP_SLOT.RUNE_1
		elif equippedSlots[Constants.ITEM_EQUIP_SLOT.RUNE_2] == null:
			return Constants.ITEM_EQUIP_SLOT.RUNE_2
	elif itemData.is_spell():
		if character.maxSpellSlots>=2:
			if equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_1] == null:
				return Constants.ITEM_EQUIP_SLOT.SPELL_1
			if equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_2] == null:
				return Constants.ITEM_EQUIP_SLOT.SPELL_2
		if character.maxSpellSlots>=3:
			if equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_3] == null:
				return Constants.ITEM_EQUIP_SLOT.SPELL_3
		if character.maxSpellSlots>=4:
			if equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_4] == null:
				return Constants.ITEM_EQUIP_SLOT.SPELL_4
	
	return -1

func get_slot_for_item(item):
	if equippedSlots[Constants.ITEM_EQUIP_SLOT.WEAPON] == item:
		return Constants.ITEM_EQUIP_SLOT.WEAPON
	elif equippedSlots[Constants.ITEM_EQUIP_SLOT.ARMOR] == item:
		return Constants.ITEM_EQUIP_SLOT.ARMOR
	elif equippedSlots[Constants.ITEM_EQUIP_SLOT.RUNE_1] == item:
		return Constants.ITEM_EQUIP_SLOT.RUNE_1
	elif equippedSlots[Constants.ITEM_EQUIP_SLOT.RUNE_2] == item:
		return Constants.ITEM_EQUIP_SLOT.RUNE_2
	elif equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_1] == item:
		return Constants.ITEM_EQUIP_SLOT.SPELL_1
	elif equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_2] == item:
		return Constants.ITEM_EQUIP_SLOT.SPELL_2
	elif equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_3] == item:
		return Constants.ITEM_EQUIP_SLOT.SPELL_3
	elif equippedSlots[Constants.ITEM_EQUIP_SLOT.SPELL_4] == item:
		return Constants.ITEM_EQUIP_SLOT.SPELL_4

	return -1



