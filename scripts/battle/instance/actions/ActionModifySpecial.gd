
class_name ActionModifySpecial extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var data:ActionModifySpecialData = actionData as ActionModifySpecialData
	
	if data.refill:
		character.special.force_ready()
	else:
		var specialId:String = data.specialId
		if specialId == "":
			specialId = character.special.data.id
		var specialModifier:SpecialModifier = SpecialModifier.new(specialId, data.countModifier)
		character.add_special_modifier(specialModifier)
