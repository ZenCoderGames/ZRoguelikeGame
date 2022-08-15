class_name Equipment

var equippedItems:Array = []
var equippedSlots:Dictionary = {}
var equippedSpells:Array = []

var character

signal OnItemEquipped(item)
signal OnItemUnEquipped(item)
signal OnSpellEquipped(item)
signal OnSpellUnEquipped(item)
signal OnSpellActivated(item)

func _init(characterRef):
	character = characterRef
	equippedSlots[Constants.ITEM_EQUIP_SLOT.WEAPON] = null
	equippedSlots[Constants.ITEM_EQUIP_SLOT.BODY] = null

func get_stat_bonus_from_equipped_items(statType):
	var statValue:int = 0
	# iterate through items
	for item in equippedItems:
		for statData in item.data.statDataList:
			if statData.type == statType:
				statValue = statValue + statData.value
	
	return statValue

func get_stat_base_bonus_from_equipped_items(statType):
	var statBaseValue:int = 0
	# iterate through items
	for item in equippedItems:
		for statData in item.data.statDataList:
			if statData.type == statType:
				statBaseValue = statBaseValue + statData.baseValue

	return statBaseValue

func equip_item(item):
	if item.is_spell():
		if equippedSpells.size() == Constants.SPELL_MAX_SLOTS:
			emit_signal("OnSpellUnEquipped", equippedSpells[0])
			equippedSpells.remove(0)
		equippedSpells.append(item)
		emit_signal("OnSpellEquipped", item)
	else:
		var slotType:int = item.data.slot
		if equippedSlots[slotType] != null:
			equippedItems.erase(equippedSlots[slotType])
			emit_signal("OnItemUnEquipped", equippedSlots[slotType])
		equippedItems.append(item)
		equippedSlots[slotType] = item
		emit_signal("OnItemEquipped", item)

func unequip_item(item):
	if item.is_spell():
		emit_signal("OnSpellUnEquipped", item)
		equippedSpells.erase(item)
	else:
		var slotType:int = item.data.slot
		if equippedSlots[slotType] != null:
			equippedItems.erase(equippedSlots[slotType])
			emit_signal("OnItemUnEquipped", equippedSlots[slotType])

func activate_spell(spellItem):
	spellItem.activate()
	equippedSpells.erase(spellItem)
	character.inventory.remove_item(spellItem)
	emit_signal("OnSpellActivated", spellItem)
