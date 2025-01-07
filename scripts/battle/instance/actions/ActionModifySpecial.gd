
class_name ActionModifySpecial extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var data:ActionModifySpecialData = actionData as ActionModifySpecialData
	
	if data.refill:
		if data.useLastSpecialAdded:
			character.force_special_ready(character.get_last_special_added().data.id)
		else:
			character.force_special_ready(data.specialId)
	else:
		var specialModifier:SpecialModifier = SpecialModifier.new(data.countModifier)
		if data.useLastSpecialAdded:
			character.add_special_modifier(character.get_last_special_added().data.id, specialModifier)
		else:
			character.add_special_modifier(data.specialId, specialModifier)
