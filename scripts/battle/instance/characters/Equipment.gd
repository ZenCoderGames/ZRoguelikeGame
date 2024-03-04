class_name Equipment

var equippedItems:Array = []
var equippedSlots:Dictionary = {}

var character

signal ShowEquipItemUI(item, slotTypeArray)
signal OnItemEquipped(item, slotType)
signal OnItemUnEquipped(item, slotType)
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
	character.inventory.connect("OnItemAdded",Callable(self,"_on_item_added"))

func _on_item_added(item:Item):
	if GameGlobals.battleInstance.usePopUpEquipment:
		if item.data.is_gear():
			_show_equip_ui(item)
	else:
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
	
	return statValue

func get_stat_max_bonus_from_equipped_items(statType):
	var statMaxValue:int = 0
	# iterate through items
	for item in equippedItems:
		for statData in item.data.statDataList:
			if statData.type == statType:
				statMaxValue = statMaxValue + statData.maxValue

	return statMaxValue

func is_slot_free(slotType:int)->bool:
	return equippedSlots[slotType] == null

func _show_equip_ui(item:Item):
	emit_signal("ShowEquipItemUI", item, Equipment.GET_SLOT_FOR_TYPE(item.data))

func show_equip_ui_for_slot(item:Item):
	emit_signal("ShowEquipItemUI", null, Equipment.GET_SLOT_FOR_TYPE(item.data))

func equip_item(item:Item, slotType:int):
	if equippedSlots[slotType] != null:
		unequip_item(equippedSlots[slotType], slotType)
	equippedItems.append(item)
	equippedSlots[slotType] = item
	item.on_equipped(character)
	emit_signal("OnItemEquipped", item, slotType)

func is_equipped(itemToCheck):
	for item in equippedItems:
		if item == itemToCheck:
			return true

	return false

func unequip_item(item, slotType:int):
	equippedItems.erase(equippedSlots[slotType])
	item.on_unequipped(character)
	equippedSlots[slotType] = null
	emit_signal("OnItemUnEquipped", item, slotType)

func activate_spell(spellItem):
	spellItem.activate()
	emit_signal("OnSpellActivated", spellItem)
	character.on_spell_activated(spellItem)
	unequip_item(spellItem, get_slot_for_item(spellItem))
	character.inventory.remove_item(spellItem)
	#pass

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

static func GET_SLOT_FOR_TYPE(itemData:ItemData):
	var slotTypes:Array = []
	if itemData.is_weapon():
		slotTypes.append(Constants.ITEM_EQUIP_SLOT.WEAPON)
	elif itemData.is_armor():
		slotTypes.append(Constants.ITEM_EQUIP_SLOT.ARMOR)
	elif itemData.is_rune():
		slotTypes.append(Constants.ITEM_EQUIP_SLOT.RUNE_1)
		slotTypes.append(Constants.ITEM_EQUIP_SLOT.RUNE_2)
	return slotTypes

static func GET_SLOT_TYPE_NAME(slotTypeArray:Array)->String:
	if slotTypeArray[0] == Constants.ITEM_EQUIP_SLOT.WEAPON:
		return "Weapon"
	elif slotTypeArray[0] == Constants.ITEM_EQUIP_SLOT.ARMOR:
		return "Armor"
	elif slotTypeArray[0] == Constants.ITEM_EQUIP_SLOT.RUNE_1:
		return "Runes"
	return ""

func get_slot_for_item(item:Item):
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

func get_item_for_slot(slotType:int):
	return equippedSlots[slotType]

func has_item_for_slot(slotType:int):
	return equippedSlots[slotType]!=null
