extends Panel

class_name LevelSelectUI_v2

@onready var backButton:TextureButton = $"%BackButton"
@onready var titleLabel:Label = $"%TitleLabel"
@onready var readyButton_Tutorial:Button = $"%Button_Tutorial"
@onready var readyButton_Campaign:Button = $"%Button_Campaign"
@onready var readyButton_Challenges:Button = $"%Button_Challenges"

var _myCharData:CharacterData

signal OnBackPressed

func init_from_data(charData:CharacterData):
	clean_up()

	_myCharData = charData

	backButton.connect("pressed",Callable(self,"_on_back_button_pressed"))
	readyButton_Tutorial.connect("pressed",Callable(self,"_on_tutorial_button_pressed"))
	readyButton_Campaign.connect("pressed",Callable(self,"_on_campaign_button_pressed"))
	readyButton_Challenges.connect("pressed",Callable(self,"_on_challenges_button_pressed"))

	_setup_keyboard_focus()

func clean_up():
	backButton.disconnect("pressed",Callable(self,"_on_back_button_pressed"))
	readyButton_Tutorial.disconnect("pressed",Callable(self,"_on_tutorial_button_pressed"))
	readyButton_Campaign.disconnect("pressed",Callable(self,"_on_campaign_button_pressed"))
	readyButton_Challenges.disconnect("pressed",Callable(self,"_on_challenges_button_pressed"))

func _on_back_button_pressed():
	emit_signal("OnBackPressed")

func _on_tutorial_button_pressed():
	GameEventManager.ready_to_battle(GameGlobals.dataManager.levelDict["LEVEL_TUTORIAL"])

func _on_campaign_button_pressed():
	GameEventManager.ready_to_battle(GameGlobals.dataManager.levelDict["LEVEL_CAMPAIGN"])

func _on_challenges_button_pressed():
	GameEventManager.ready_to_battle(GameGlobals.dataManager.levelDict["LEVEL_CHALLENGE"])

# KEYBOARD FOCUS
var _keyboardFocusList:Array[Button]
var _keyboardFocusIdx:int
var _prevFocusedButton:Button

func _setup_keyboard_focus():
	_keyboardFocusList.append(readyButton_Tutorial)
	_keyboardFocusList.append(readyButton_Campaign)
	_update_keyboard_focus()

func _input(event: InputEvent) -> void:
	if GameGlobals.is_in_state(GameGlobals.STATES.LEVEL_SELECT):
		if _keyboardFocusList.is_empty():
			return
	
		if event.is_action_pressed(Constants.INPUT_MOVE_LEFT):
			_keyboardFocusIdx = _keyboardFocusIdx - 1
			_update_keyboard_focus()
		elif event.is_action_pressed(Constants.INPUT_MOVE_RIGHT):
			_keyboardFocusIdx = _keyboardFocusIdx + 1
			_update_keyboard_focus()
	
		if event.is_action_pressed(Constants.INPUT_MENU_ACCEPT):
			_keyboardFocusList[_keyboardFocusIdx].emit_signal("pressed")

func _update_keyboard_focus():
	if _keyboardFocusIdx<0:
		_keyboardFocusIdx = 0
	elif _keyboardFocusIdx>_keyboardFocusList.size()-1:
		_keyboardFocusIdx = _keyboardFocusList.size()-1

	if _prevFocusedButton!=null and _prevFocusedButton!=_keyboardFocusList[_keyboardFocusIdx]:
		_prevFocusedButton.modulate = Color.WHITE
	_keyboardFocusList[_keyboardFocusIdx].modulate = Color.YELLOW
	_prevFocusedButton = _keyboardFocusList[_keyboardFocusIdx]