extends Panel

class_name CharacterSelectUI

@onready var charSelectHolder:HBoxContainer = $"%CharSelectHolder"

const CharacterSelectItemUIClass := preload("res://ui/characterSelect/CharacterSelectItemUI.tscn")

var initialized:bool = false

func init_from_data(dungeonPath:String):
	if initialized:
		return
		
	for heroData in GameGlobals.dataManager.heroDataList:
		if heroData.isGeneric:
			continue
		var charSelectItem = CharacterSelectItemUIClass.instantiate()
		charSelectHolder.add_child(charSelectItem)
		charSelectItem.init_from_data(heroData, dungeonPath)
	initialized = true

