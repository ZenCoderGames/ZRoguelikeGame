class_name AbilityUpgradeTypes

static func create(abilityUpgradeData:AbilityUpgradeData, parentChar):
	if abilityUpgradeData.type==AbilityUpgradeModifyStatusEffectData.ID:
		return AbilityUpgradeModifyStatusEffect.new(abilityUpgradeData, parentChar)
	elif abilityUpgradeData.type==AbilityUpgradeModifySpecialData.ID:
		return AbilityUpgradeModifySpecial.new(abilityUpgradeData, parentChar)
	elif abilityUpgradeData.type==AbilityUpgradeAddPassiveData.ID:
		return AbilityUpgradeAddPassive.new(abilityUpgradeData, parentChar)

	print_debug("[ERROR] Invalid Ability Upgrade Type", abilityUpgradeData.type)
	return null
