extends Action

class_name ActionApplyStatusEffect

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
    var actionStatusEffectData:ActionApplyStatusEffectData = actionData as ActionApplyStatusEffectData
    if actionStatusEffectData.target == "SELF":
        character.add_status_effect(GameGlobals.dataManager.get_status_effect_data(actionStatusEffectData.statusEffectId))