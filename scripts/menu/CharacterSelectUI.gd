extends Panel

class_name CharacterSelectUI

@onready var charSelectHolder:HBoxContainer = $"%CharSelectHolder"

const CharacterSelectItemUI := preload("res://ui/characterSelect/CharacterSelectItemUI.tscn")

var initialized:bool = false

func init_from_data():
	if initialized:
		return
		
	for heroData in GameGlobals.dataManager.heroDataList:
		var charSelectItem = CharacterSelectItemUI.instantiate()
		charSelectHolder.add_child(charSelectItem)
		charSelectItem.init_from_data(heroData)
	initialized = true

