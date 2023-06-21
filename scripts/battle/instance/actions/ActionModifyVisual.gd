
class_name ActionModifyVisual extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var modifyVisualData:ActionModifyVisualData = actionData as ActionModifyVisualData

	if !modifyVisualData.tintColor.is_empty():
		character.self_modulate = Color(modifyVisualData.tintColor)

	if modifyVisualData.resetToOriginalTint:
		character.reset_color()
