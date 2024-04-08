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

func add_character(heroData:CharacterData):
	var charSelectItem = CharacterSelectItemUIClass.instantiate()
	charSelectHolder.add_child(charSelectItem)
	charSelectItems.append(charSelectItem)
	charSelectItem.init_from_data(heroData)
	charSelectItem.connect("OnActiveOrPassiveInFocus",Callable(self,"_show_info"))
	charSelectItem.connect("OnActiveOrPassiveOutOfFocus",Callable(self,"_hide_info"))
	charSelectItem.connect("OnUnlocked",Callable(self,"_on_unlocked"))

func _show_info(val:String):
	infoPanel.visible = true
	infoLabel.text = Utils.format_text(val)
	
func _hide_info():
	infoPanel.visible = false

func _on_unlocked():
	for charSelectItem in charSelectItems:
		charSelectItem.refresh()

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
