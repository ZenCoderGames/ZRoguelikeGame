extends Action

class_name ActionAddStatModifier

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
    var actionStatModifierData:ActionAddStatModifierData = actionData as ActionAddStatModifierData
    for statModifier in actionStatModifierData.statusModifiers:
        character.modify_stat_value_from_modifier(statModifier)