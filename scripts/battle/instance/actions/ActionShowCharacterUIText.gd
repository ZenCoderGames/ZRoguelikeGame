
class_name ActionShowCharacterUIText extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var showCharacterUITextData:ActionShowCharacterUITextData = actionData as ActionShowCharacterUITextData
	character.show_text_on_self(showCharacterUITextData.text, showCharacterUITextData.duration)
