extends Action

class_name ActionAddStatusEffect

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
	var actionStatusEffectData:ActionAddStatusEffectData = actionData as ActionAddStatusEffectData
	if actionStatusEffectData.applyToSource:
		character.add_status_effect(character, GameGlobals.dataManager.get_status_effect_data(actionStatusEffectData.statusEffectId))
	elif actionStatusEffectData.applyToTargets:
		var targets = character.get_targets()
		for target in targets:
			if !target.isDead:
				target.add_status_effect(character, GameGlobals.dataManager.get_status_effect_data(actionStatusEffectData.statusEffectId))