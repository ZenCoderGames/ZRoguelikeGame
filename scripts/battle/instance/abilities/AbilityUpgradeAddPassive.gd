extends AbilityUpgrade

class_name AbilityUpgradeAddPassive

func _init(abilityUpgradeData, parentChar).(abilityUpgradeData, parentChar):
	pass

func execute():
	var abilityUpgradeAddPassiveData:AbilityUpgradeAddPassiveData = abilityUpgradeData as AbilityUpgradeAddPassiveData

	var passiveData:PassiveData = GameGlobals.dataManager.get_passive_data(abilityUpgradeAddPassiveData.passiveId)
	if passiveData!=null:
		character.add_passive(passiveData)
	
