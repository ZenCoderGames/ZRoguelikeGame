extends Panel

class_name CharacterSelectUI

@onready var charSelectHolder:HBoxContainer = $"%CharSelectHolder"
@onready var buffHolder:HBoxContainer = $"%BuffHolder"
@onready var infoPanel:Panel = $"%InfoPanel"
@onready var infoLabel:RichTextLabel = $"%InfoLabel"
@onready var backButton:TextureButton = $"%BackButton"
@onready var titleLabel:Label = $"%TitleLabel"

const CharacterSelectItemUIClass := preload("res://ui/characterSelect/CharacterSelectItemUI.tscn")

var charSelectItems:Array
var charBuffItems:Array

signal OnBackPressed

func init_from_data():
	clean_up()
	hide_info()

	for heroData in GameGlobals.dataManager.heroDataList:
		if heroData.isInCharacterSelect:
			add_character(heroData)
		
	backButton.connect("pressed",Callable(self,"_on_back_button_pressed"))

func add_character(heroData:CharacterData):
	var charSelectItem = CharacterSelectItemUIClass.instantiate()
	charSelectHolder.add_child(charSelectItem)
	charSelectItems.append(charSelectItem)
	charSelectItem.init_from_data(heroData)
	charSelectItem.connect("OnActiveOrPassiveInFocus",Callable(self,"show_info"))
	charSelectItem.connect("OnActiveOrPassiveOutOfFocus",Callable(self,"hide_info"))

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
