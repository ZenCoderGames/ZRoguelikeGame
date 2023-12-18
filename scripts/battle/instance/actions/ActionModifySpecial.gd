
class_name ActionModifySpecial extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var data:ActionModifySpecialData = actionData as ActionModifySpecialData
	
	if data.refill:
		character.force_special_ready(data.specialId)
	else:
		var specialModifier:SpecialModifier = SpecialModifier.new(data.countModifier)
		character.add_special_modifier(data.specialId, specialModifier)
