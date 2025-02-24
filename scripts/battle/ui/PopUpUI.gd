extends Control

class_name PopUpUI

@onready var title:Label = $"%Title"
@onready var description:Label = $"%Description"
@onready var confirmBtn:Button = $"%ConfirmButton"
@onready var backBtn:TextureButton = $"%BackButton"

signal OnConfirm
signal OnBack

func init(titleStr:String, descStr:String):
	title.text = titleStr
	description.text = descStr
	confirmBtn.text = str(_get_input_str(), " JOURNEY ON...")
	
	confirmBtn.connect("button_up",Callable(self,"_on_confirm"))
	backBtn.connect("button_up",Callable(self,"_on_back"))
	GameEventManager.connect("OnBackButtonPressed",Callable(self,"_on_back"))

func _on_confirm():
	emit_signal("OnConfirm")
	
func _on_back():
	emit_signal("OnBack")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Constants.INPUT_VENDOR_OPTION1):
		_on_confirm()

func _get_input_str():
	if Utils.is_joystick_enabled():
		return "(A) "
	else:
		return "(Q) "
	
	return ""
