
class_name ActionShowCharacterUITextData extends ActionData

const ID:String = "SHOW_CHARACTER_UI_TEXT"

var text:String
var duration:float

func _init(dataJS):
	super(dataJS)
	text = Utils.get_data_from_json(dataJS["params"], "text", "")
	duration = Utils.get_data_from_json(dataJS["params"], "duration", 0.75)
