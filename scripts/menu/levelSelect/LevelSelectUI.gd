extends Panel

class_name LevelSelectUI

@onready var levelSelectHolder:HBoxContainer = $"%LevelSelectHolder"
@onready var buffHolder:HBoxContainer = $"%BuffHolder"
@onready var infoPanel:Panel = $"%InfoPanel"
@onready var infoLabel:RichTextLabel = $"%InfoLabel"
@onready var backButton:TextureButton = $"%BackButton"
@onready var titleLabel:Label = $"%TitleLabel"
@onready var readyButton:Button = $"%ReadyButton"

const LevelSelectItemUIClass := preload("res://ui/levelSelect/LevelSelectItemUI.tscn")
const CharacterSelectBuffUIClass := preload("res://ui/characterSelect/CharacterSelectBuffUI.tscn")

var levelSelectItems:Array
var dungeonModifierBuffItems:Array

var _myCharData:CharacterData
var _selectedLevelData:LevelData

signal OnBackPressed

func init_from_data(charData:CharacterData):
	clean_up()
	hide_info()

	_myCharData = charData

	var levels:Array = []
	levels.append("LEVEL_TUTORIAL")
	levels.append("LEVEL_EASY")
	levels.append("LEVEL_BALANCED")
	levels.append("LEVEL_HARD")

	for levelId in levels:
		var levelData:LevelData = GameGlobals.dataManager.get_level_data(levelId)
		add_level(levelData)

	backButton.connect("pressed",Callable(self,"_on_back_button_pressed"))
	readyButton.connect("pressed",Callable(self,"_on_ready_button_pressed"))
	readyButton.visible = false

func add_level(levelData:LevelData):
	var levelSelectItem = LevelSelectItemUIClass.instantiate()
	levelSelectHolder.add_child(levelSelectItem)
	levelSelectItems.append(levelSelectItem)
	levelSelectItem.init_from_data(_myCharData, levelData)
	levelSelectItem.connect("OnLevelSelected",Callable(self,"_on_level_selected"))

func _on_level_selected(levelData:LevelData):
	readyButton.visible = true
	_selectedLevelData = levelData

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
	
func hide_info():
	infoPanel.visible = false

func clean_up():
	_selectedLevelData = null
	# charholders
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
