extends Panel

class_name CharacterSelectUI

@onready var charSelectHolder:HBoxContainer = $"%CharSelectHolder"
@onready var buffHolder:HBoxContainer = $"%BuffHolder"
@onready var infoPanel:Panel = $"%InfoPanel"
@onready var infoLabel:RichTextLabel = $"%InfoLabel"
@onready var backButton:TextureButton = $"%BackButton"
@onready var titleLabel:Label = $"%TitleLabel"

const CharacterSelectItemUIClass := preload("res://ui/characterSelect/CharacterSelectItemUI.tscn")
const CharacterSelectBuffUIClass := preload("res://ui/characterSelect/CharacterSelectBuffUI.tscn")

var charSelectItems:Array
var charBuffItems:Array

signal OnBackPressed

func init_from_data(levelId:String):
	clean_up()
	hide_info()
	var levelData:LevelData = GameGlobals.dataManager.get_level_data(levelId)
	
	titleLabel.text = levelData.description

	for heroData in GameGlobals.dataManager.heroDataList:
		if heroData.isInCharacterSelect:
			var charSelectItem = CharacterSelectItemUIClass.instantiate()
			charSelectHolder.add_child(charSelectItem)
			charSelectItems.append(charSelectItem)
			charSelectItem.init_from_data(heroData, levelData.dungeonPath)
			charSelectItem.connect("OnActiveOrPassiveInFocus",Callable(self,"show_info"))
			charSelectItem.connect("OnActiveOrPassiveOutOfFocus",Callable(self,"hide_info"))

	for dungeonModifier in levelData.dungeonModifiers:
		var charBuffItem = CharacterSelectBuffUIClass.instantiate()
		buffHolder.add_child(charBuffItem)
		charBuffItems.append(charBuffItem)
		charBuffItem.init(GameGlobals.dataManager.get_dungeon_modifier_data(dungeonModifier))
		charBuffItem.connect("OnInFocus",Callable(self,"show_info"))
		charBuffItem.connect("OnOutOfFocus",Callable(self,"hide_info"))

	backButton.connect("pressed",Callable(self,"_on_back_button_pressed"))

func show_info(str:String):
	infoPanel.visible = true
	infoLabel.text = Utils.format_text(str)
	
func hide_info():
	infoPanel.visible = false

func clean_up():
	# charholders
	for charSelectItem in charSelectItems:
		charSelectHolder.remove_child(charSelectItem)
		charSelectItem.queue_free()
	charSelectItems.clear()
	# buffholders
	for charBuffItem in charBuffItems:
		buffHolder.remove_child(charBuffItem)
		charBuffItem.queue_free()
	charBuffItems.clear()
	
	backButton.disconnect("pressed",Callable(self,"_on_back_button_pressed"))

func _on_back_button_pressed():
	emit_signal("OnBackPressed")
