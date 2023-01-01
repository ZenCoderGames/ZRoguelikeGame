class_name AbilityUpgradeDataTypes

static func create(dataJS)->AbilityUpgradeData:
	var abilityUpgradeType = dataJS["type"]
	if abilityUpgradeType==AbilityUpgradeModifyStatusEffectData.ID:
		return AbilityUpgradeModifyStatusEffectData.new(dataJS)
	elif abilityUpgradeType==AbilityUpgradeModifySpecialData.ID:
		return AbilityUpgradeModifySpecialData.new(dataJS)
	elif abilityUpgradeType==AbilityUpgradeAddPassiveData.ID:
		return AbilityUpgradeAddPassiveData.new(dataJS)

	print_debug("[ERROR] Invalid Ability Upgrade Data Type", abilityUpgradeType)
	return null
