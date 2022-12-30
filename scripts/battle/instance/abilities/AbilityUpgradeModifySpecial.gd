extends AbilityUpgrade

class_name AbilityUpgradeModifySpecial

func _init(abilityUpgradeData, parentChar).(abilityUpgradeData, parentChar):
	pass

func execute():
	var abilityUpgradeSpecialData:AbilityUpgradeModifySpecialData = abilityUpgradeData as AbilityUpgradeModifySpecialData

	var specialModifier:SpecialModifier = SpecialModifier.new(abilityUpgradeSpecialData.specialId, abilityUpgradeSpecialData.countModifier)
	
	character.add_special_modifier(specialModifier)
