extends Control

class_name SkillTreeUI_v2

@onready var charPortrait:TextureRect = $"%CharPortrait"
@onready var soulsLabel:Label = $"%SoulsLabel"
@onready var infoPanel:Panel = $"%InfoPanel"
@onready var infoTitle:RichTextLabel = $"%InfoTitle"
@onready var infoDesc:RichTextLabel = $"%InfoDesc"
@onready var backButton:TextureButton = $"%BackButton"
@onready var unlockButton:Button = $"%UnlockButton"
@onready var enableButton:Button = $"%EnableButton"
@onready var disableButton:Button = $"%DisableButton"
@onready var gridContainer:GridContainer = $"%GridContainer"

const SkillTreeNodeClass := preload("res://ui/skilltree/SkillTreeNode_v2.tscn")

var _skillTreeData:SkillTreeData
var _selectedSkillData:SkillData

var _skillTreeNodes:Array
var _skillTreeDict:Dictionary

signal OnBackPressed

var _initialized:bool
var _availableSouls:int

func _init():
	UIEventManager.connect("OnSkillNodeSelected", Callable(self, "_on_skill_selected"))

func init_from_data(skillTreeId:String):
	clean_up()
	hide_info()

	if !_initialized:
		_skillTreeData = GameGlobals.dataManager.skilltreeDict[skillTreeId]
		
		for skillData:SkillData in _skillTreeData.skillList:
			var skillTreeNode = SkillTreeNodeClass.instantiate(PackedScene.GEN_EDIT_STATE_MAIN_INHERITED)
			var hasBeenUnlocked:bool = PlayerDataManager.has_skill_been_unlocked(skillData.id)
			var isLocked:bool = false
			var hasParent:bool = !skillData.parentSkillId.is_empty()
			skillTreeNode.init_from_data(skillData, hasBeenUnlocked, false)
			skillTreeNode.connect("OnSkillSelected",Callable(self,"_on_skill_selected"))
			gridContainer.add_child(skillTreeNode)
			_skillTreeNodes.append(skillTreeNode)
			_skillTreeDict[skillData] = skillTreeNode
			
		_setup_keyboard_focus()
	else:
		for skillTreeNode in _skillTreeNodes:
			skillTreeNode.refresh()
		
	backButton.connect("pressed",Callable(self,"_on_back_button_pressed"))
	unlockButton.connect("pressed",Callable(self,"_on_unlock_button_pressed"))
	unlockButton.visible = false
	
	charPortrait.texture = load(str("res://",GameGlobals.currentSelectedHero.portraitPath))
	_availableSouls = PlayerDataManager.currentPlayerData.get_hero_level(GameGlobals.currentSelectedHero.id)
	soulsLabel.text = str(_availableSouls)
	infoPanel.visible = false
	
	emit_signal("item_rect_changed")
	UIEventManager.emit_signal("ShowSkillTree", true, skillTreeId)
	
	_skillTreeNodes[0]._on_item_chosen()
	
	_initialized = true

func _on_skill_selected(skillData:SkillData, isLocked:bool):
	var skillName:String = skillData.name
	unlockButton.visible = !isLocked
	unlockButton.disabled = !PlayerDataManager.can_unlock_skill(skillData)
	unlockButton.text = str(" Unlock: x", skillData.unlockCost)
	if skillData.isStartNode:
		unlockButton.visible = false
	if PlayerDataManager.has_skill_been_unlocked(skillData.id):
		unlockButton.visible = false

	_selectedSkillData = skillData
	infoTitle.text = Utils.format_text(skillName)
	infoDesc.text = Utils.format_text(skillData.description)
	infoPanel.visible = true
	
	for skillTreeNode in _skillTreeNodes:
		skillTreeNode.set_selected(skillTreeNode.has_skill_data(skillData))
	
func hide_info():
	infoPanel.visible = false

func clean_up():
	backButton.disconnect("pressed",Callable(self,"_on_back_button_pressed"))
	unlockButton.disconnect("pressed",Callable(self,"_on_ready_button_pressed"))

func _on_back_button_pressed():
	emit_signal("OnBackPressed")

func _on_unlock_button_pressed():
	PlayerDataManager.unlock_skill(_selectedSkillData)
	UIEventManager.emit_signal("OnSkillUnlocked")
	unlockButton.visible = false
	_skillTreeDict[_selectedSkillData].refresh()

# KEYBOARD FOCUS
var _keyboardFocusList:Array
var _keyboardFocusIdx:int
var _prevKeyboardFocusIdx:int
var _timeSinceLastInput:float

func _setup_keyboard_focus():
	_keyboardFocusIdx = 0
	_keyboardFocusList.clear()
	for skillTreeNode in _skillTreeNodes:
		_keyboardFocusList.append(skillTreeNode)
	_update_keyboard_focus()

func _input(event: InputEvent) -> void:
	if _timeSinceLastInput>0 and GlobalTimer.get_time_since(_timeSinceLastInput)<0.25:
		return
		
	if GameGlobals.is_in_state(GameGlobals.STATES.SKILL_TREE):
		if _keyboardFocusList.is_empty():
			return
	
		if event.is_action_pressed(Constants.INPUT_MOVE_LEFT):
			_keyboardFocusIdx = _keyboardFocusIdx - 1
			_update_keyboard_focus()
		elif event.is_action_pressed(Constants.INPUT_MOVE_RIGHT):
			_keyboardFocusIdx = _keyboardFocusIdx + 1
			_update_keyboard_focus()
		elif event.is_action_pressed(Constants.INPUT_MOVE_UP):
			if _keyboardFocusIdx-8>0:
				_keyboardFocusIdx = _keyboardFocusIdx - 8
			_update_keyboard_focus()
		elif event.is_action_pressed(Constants.INPUT_MOVE_DOWN):
			if _keyboardFocusIdx+8<_skillTreeNodes.size():
				_keyboardFocusIdx = _keyboardFocusIdx + 8
			_update_keyboard_focus()
	
		if event.is_action_pressed(Constants.INPUT_MENU_ACCEPT):
			_on_unlock_button_pressed()

func _update_keyboard_focus():
	if _keyboardFocusIdx<0:
		_keyboardFocusIdx = 0
	elif _keyboardFocusIdx>_keyboardFocusList.size()-1:
		_keyboardFocusIdx = _keyboardFocusList.size()-1

	'''if !_keyboardFocusList[_keyboardFocusIdx].is_unlocked() and !_keyboardFocusList[_keyboardFocusIdx].is_unlockable():
		_keyboardFocusIdx = _prevKeyboardFocusIdx
		return'''

	_keyboardFocusList[_keyboardFocusIdx]._on_item_chosen()
	_prevKeyboardFocusIdx = _keyboardFocusIdx
	
	_timeSinceLastInput = GlobalTimer.get_current_time()
