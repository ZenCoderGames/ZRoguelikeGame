extends Panel

class_name CharacterSelectUI

@onready var charSelectHolder:HBoxContainer = $"%CharSelectHolder"
@onready var infoPanel:Panel = $"%InfoPanel"
@onready var infoLabel:RichTextLabel = $"%InfoLabel"
@onready var backButton:TextureButton = $"%BackButton"
@onready var titleLabel:Label = $"%TitleLabel"
@onready var skillTreeButton:Button = $"%SkillTreeButton"

const CharacterSelectItemUIClass := preload("res://ui/characterSelect/CharacterSelectItemUI.tscn")

var charSelectItems:Array

signal OnSkillTreePressed
signal OnBackPressed

func init_from_data():
	clean_up()
	_hide_info()

	for heroData in GameGlobals.dataManager.heroDataList:
		if heroData.isInCharacterSelect:
			add_character(heroData)
		
	backButton.connect("pressed",Callable(self,"_on_back_button_pressed"))
	skillTreeButton.connect("pressed",Callable(self,"_on_skilltree_button_pressed"))
	skillTreeButton.text = "(E) SKILL TREE"
	if Utils.is_joystick_enabled():
		skillTreeButton.text = "(X) SKILL TREE"
			
	var prevChosenHero:CharacterData = GameGlobals.currentSelectedHero
			
	_setup_keyboard_focus()
	
	# Start at the last chosen character
	var idx:int = 0
	for charSelectItem in charSelectItems:
		if prevChosenHero == charSelectItem.myCharData:
			_keyboardFocusIdx = idx
			break
		idx = idx + 1
		
	_update_keyboard_focus()

func add_character(heroData:CharacterData):
	var charSelectItem = CharacterSelectItemUIClass.instantiate()
	charSelectHolder.add_child(charSelectItem)
	charSelectItems.append(charSelectItem)
	charSelectItem.init_from_data(heroData)
	charSelectItem.connect("OnActiveOrPassiveInFocus",Callable(self,"_show_info"))
	charSelectItem.connect("OnActiveOrPassiveOutOfFocus",Callable(self,"_hide_info"))
	charSelectItem.connect("OnUnlocked",Callable(self,"_on_unlocked"))
	charSelectItem.connect("OnSelected",Callable(self,"_on_selected"))

func _show_info(val:String):
	infoPanel.visible = true
	infoLabel.text = Utils.format_text(val)
	
func _hide_info():
	infoPanel.visible = false

func _on_unlocked():
	for charSelectItem in charSelectItems:
		charSelectItem.refresh()

func _on_selected(itemUI:CharacterSelectItemUI):
	for charSelectItem in charSelectItems:
		if (charSelectItem == itemUI):
			charSelectItem.select()
		else:
			charSelectItem.deselect()

func _on_skilltree_button_pressed():
	emit_signal("OnSkillTreePressed")

func clean_up():
	# charholders
	for charSelectItem in charSelectItems:
		charSelectHolder.remove_child(charSelectItem)
		charSelectItem.queue_free()
	charSelectItems.clear()
	
	backButton.disconnect("pressed",Callable(self,"_on_back_button_pressed"))

func _on_back_button_pressed():
	emit_signal("OnBackPressed")

# KEYBOARD FOCUS
var _keyboardFocusList:Array[CharacterSelectItemUI]
var _keyboardFocusIdx:int
var _prevFocusedButton:CharacterSelectItemUI
var _prevKeyboardFocusIdx:int
var _timeSinceLastInput:float

func _setup_keyboard_focus():
	_prevKeyboardFocusIdx = 0
	_keyboardFocusIdx = 0
	_keyboardFocusList.clear()
	for item in charSelectItems:
		_keyboardFocusList.append(item)
	_update_keyboard_focus()

func _input(event: InputEvent) -> void:
	if _timeSinceLastInput>0 and GlobalTimer.get_time_since(_timeSinceLastInput)<0.25:
		return
		
	if GameGlobals.is_in_state(GameGlobals.STATES.CHARACTER_SELECT):
		if _keyboardFocusList.is_empty():
			return
		
		var left_stick_x = 0
		var left_stick_y = 0
		var joyInputThreshold = 0.8
		if Utils.is_joystick_enabled():
			left_stick_x = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
			left_stick_y = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
			
		if (!Utils.is_joystick_enabled() and event.is_action(Constants.INPUT_MOVE_LEFT)) or (left_stick_x<-joyInputThreshold):
			_keyboardFocusIdx = _keyboardFocusIdx - 1
			_update_keyboard_focus()
		elif (!Utils.is_joystick_enabled() and event.is_action_pressed(Constants.INPUT_MOVE_RIGHT)) or (left_stick_x>joyInputThreshold):
			_keyboardFocusIdx = _keyboardFocusIdx + 1
			_update_keyboard_focus()
	
		if event.is_action_pressed(Constants.INPUT_MENU_ACCEPT):
			_keyboardFocusList[_keyboardFocusIdx].confirm()
			
		if event.is_action_pressed(Constants.INPUT_USE_SPECIAL2):
			_on_skilltree_button_pressed()

func _update_keyboard_focus():
	if _keyboardFocusIdx<0:
		_keyboardFocusIdx = 0
	elif _keyboardFocusIdx>_keyboardFocusList.size()-1:
		_keyboardFocusIdx = _keyboardFocusList.size()-1

	'''if !_keyboardFocusList[_keyboardFocusIdx].is_unlocked() and !_keyboardFocusList[_keyboardFocusIdx].is_unlockable():
		_keyboardFocusIdx = _prevKeyboardFocusIdx
		return'''

	if _prevFocusedButton!=null and _prevFocusedButton!=_keyboardFocusList[_keyboardFocusIdx]:
		_prevFocusedButton.deselect()
	_keyboardFocusList[_keyboardFocusIdx]._on_item_selected()
	_prevFocusedButton = _keyboardFocusList[_keyboardFocusIdx]
	_prevKeyboardFocusIdx = _keyboardFocusIdx
	
	_timeSinceLastInput = GlobalTimer.get_current_time()
