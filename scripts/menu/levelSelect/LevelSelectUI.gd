extends Panel

class_name LevelSelectUI

@onready var levelSelectHolder:HBoxContainer = $"%LevelSelectHolder"
@onready var buffHolder:HBoxContainer = $"%BuffHolder"
@onready var infoPanel:Panel = $"%InfoPanel"
@onready var infoLabel:RichTextLabel = $"%InfoLabel"
@onready var backButton:TextureButton = $"%BackButton"
@onready var titleLabel:Label = $"%TitleLabel"
@onready var levelLabel:Label = $"%LevelLabel"
@onready var readyButton:Button = $"%ReadyButton"
@export var mapNodes:Array[Control]

const LevelSelectItemUIClass := preload("res://ui/levelSelect/LevelSelectItemUI.tscn")
const CharacterSelectBuffUIClass := preload("res://ui/characterSelect/CharacterSelectBuffUI.tscn")

var levelSelectItems:Array
var dungeonModifierBuffItems:Array

var _myCharData:CharacterData
var _selectedLevelData:LevelData
var _levels:Array[String] = []
var _completedLevels:Array[String] = []
var _foundLastCompleted:bool

signal OnBackPressed

func init_from_data(charData:CharacterData):
	clean_up()
	hide_info()

	_myCharData = charData

	_foundLastCompleted = false
	_levels.clear()
	_completedLevels.clear()
	_levels.append("LEVEL_TUTORIAL")
	_completedLevels.append("LEVEL_TUTORIAL")
	init_level("LEVEL_01")
	init_level("LEVEL_02")
	init_level("LEVEL_03")
	init_level("LEVEL_04")
	init_level("LEVEL_BOSS")
	levelLabel.text = ""

	backButton.connect("pressed",Callable(self,"_on_back_button_pressed"))
	readyButton.connect("pressed",Callable(self,"_on_ready_button_pressed"))
	readyButton.visible = false

	var idx:int = 0
	for levelId in _levels:
		var levelData:LevelData = GameGlobals.dataManager.get_level_data(levelId)
		add_level(levelData, idx)
		idx = idx + 1

func init_level(levelId:String):
	_levels.append(levelId)
	if PlayerDataManager.is_level_completed(_myCharData, levelId):
		_completedLevels.append(levelId)

func add_level(levelData:LevelData, idx:int):
	var levelSelectItem = LevelSelectItemUIClass.instantiate()
	mapNodes[idx].add_child(levelSelectItem)
	levelSelectItems.append(levelSelectItem)
	var isCompleted:bool = _completedLevels.has(levelData.id)
	levelSelectItem.init_from_data(_myCharData, levelData, isCompleted, _foundLastCompleted)
	levelSelectItem.connect("OnLevelSelected",Callable(self,"_on_level_selected"))
	if !isCompleted and !_foundLastCompleted:
		_foundLastCompleted = true
		_on_level_selected(levelData, false)

func _on_level_selected(levelData:LevelData, isLocked:bool):
	readyButton.visible = !isLocked
	_selectedLevelData = levelData
	levelLabel.text = _selectedLevelData.name
	show_info(_selectedLevelData.description)

	for levelSelectItem in levelSelectItems:
		levelSelectItem.set_selected(levelSelectItem.has_level_data(levelData))

	_clean_up_buffs()
	for dungeonModifier in levelData.dungeonModifiers:
		var charBuffItem = CharacterSelectBuffUIClass.instantiate()
		buffHolder.add_child(charBuffItem)
		dungeonModifierBuffItems.append(charBuffItem)
		charBuffItem.init(GameGlobals.dataManager.get_dungeon_modifier_data(dungeonModifier))
		charBuffItem.connect("OnInFocus",Callable(self,"show_info"))
		charBuffItem.connect("OnOutOfFocus",Callable(self,"hide_info"))

func show_info(str:String):
	infoPanel.visible = true
	infoLabel.text = Utils.format_text(str)
	await get_tree().create_timer(0.75).timeout
	hide_info()
	
func hide_info():
	infoPanel.visible = false

func clean_up():
	_selectedLevelData = null
	# charholders
	if levelSelectHolder!=null:
		for levelSelectItem in levelSelectItems:
			levelSelectHolder.remove_child(levelSelectItem)
			levelSelectItem.queue_free()
		levelSelectItems.clear()
	# buffholders
	_clean_up_buffs()
	
	backButton.disconnect("pressed",Callable(self,"_on_back_button_pressed"))
	readyButton.disconnect("pressed",Callable(self,"_on_ready_button_pressed"))

func _clean_up_buffs():
	for levelBuffItem in dungeonModifierBuffItems:
		buffHolder.remove_child(levelBuffItem)
		levelBuffItem.queue_free()
	dungeonModifierBuffItems.clear()

func _on_back_button_pressed():
	emit_signal("OnBackPressed")

func _on_ready_button_pressed():
	GameEventManager.ready_to_battle(_selectedLevelData)
