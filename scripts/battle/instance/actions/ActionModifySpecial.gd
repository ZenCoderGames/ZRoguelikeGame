extends Action

class_name ActionModifySpecial

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func execute():
	var data:ActionModifySpecialData = actionData as ActionModifySpecialData
	
	if data.refill:
		character.special.force_ready()
	else:
		var specialModifier:SpecialModifier = SpecialModifier.new(data.specialId, data.countModifier)
		character.add_special_modifier(specialModifier)
