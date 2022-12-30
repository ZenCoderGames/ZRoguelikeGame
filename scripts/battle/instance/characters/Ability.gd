class_name Ability

var character
var data:AbilityData
var abilityUpgrades:Array = []

func _init(parentChar, abilityData:AbilityData):
	character = parentChar
	data = abilityData

	for abilityUpgradeData in data.abilityUpgrades:
		var abilityUpgrade:AbilityUpgrade = AbilityUpgradeTypes.create(abilityUpgradeData, character)
		if(abilityUpgrade!=null):
			abilityUpgrades.append(abilityUpgrade)

	activate()

func activate():
	for abilityUpgrade in abilityUpgrades:
		abilityUpgrade.execute()
