extends AbilityUpgrade

class_name AbilityUpgradeModifyStatusEffect

func _init(abilityUpgradeData, parentChar).(abilityUpgradeData, parentChar):
	pass

func execute():
    var abilityUpgradeStatusEffectData:AbilityUpgradeModifyStatusEffectData = abilityUpgradeData as AbilityUpgradeModifyStatusEffectData

    var statusEffectModifier:StatusEffectModifier = StatusEffectModifier.new(abilityUpgradeStatusEffectData)
    
    character.add_status_effect_modifier(statusEffectModifier)