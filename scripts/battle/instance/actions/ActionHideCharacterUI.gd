
class_name ActionHideCharacterUI extends Action

func _init(actionData,parentChar):
	super(actionData, parentChar)
	pass

func execute():
	var hideCharacterUIData:ActionHideCharacterUIData = actionData as ActionHideCharacterUIData
	character.emit_signal("HideCharacterUI", hideCharacterUIData.hide)
