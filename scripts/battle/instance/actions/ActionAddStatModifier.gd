
class_name ActionAddStatModifier extends Action

func _init(actionData,parentChar):
	super(actionData, parentChar)
	pass

func execute():
	var actionStatModifierData:ActionAddStatModifierData = actionData as ActionAddStatModifierData
	for statModifier in actionStatModifierData.statModifiers:
		character.modify_stat_value_from_modifier(statModifier)
