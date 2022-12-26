extends Action

class_name ActionModifyVisual

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
    var modifyVisualData:ActionModifyVisualData = actionData as ActionModifyVisualData

    if !modifyVisualData.tintColor.empty():
        character.self_modulate = Color(modifyVisualData.tintColor)

    if modifyVisualData.resetToOriginalTint:
        character.reset_color()