
class_name ActionHideCharacterUIData extends ActionData

const ID:String = "HIDE_CHARACTER_UI"

var hide:bool

func _init(dataJS):
	super(dataJS)
	hide = Utils.get_data_from_json(dataJS["params"], "hide", true)
