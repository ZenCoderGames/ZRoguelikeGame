extends PanelContainer

class_name LevelSelectItemUI

@onready var charLabel:Label = $"%CharNameLabel"
@onready var descLabel:Label = $"%DescLabel"
@onready var chooseBtn:Button = $"%ChooseButton"
@onready var portrait:TextureRect = $"%Portrait"

var myCharData:CharacterData
var myLevelData:LevelData

signal OnLevelSelected(levelData)

func init_from_data(charData:CharacterData, levelData:LevelData):
	myCharData = charData
	myLevelData = levelData
	charLabel.text = Utils.convert_to_camel_case(levelData.name)
	#statStr.erase(statStr.length()-1, 1)
	descLabel.text = levelData.description
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))
	var portraitTex = load(str("res://",myCharData.portraitPath))
	portrait.texture = portraitTex

func _on_item_chosen():
	UIEventManager.emit_signal("OnCharacterSelectButton")
	GameGlobals.battleInstance.startWithClasses = !myCharData.isGeneric
	emit_signal("OnLevelSelected", myLevelData)
	#GameEventManager.on_character_chosen(myCharData)
	#GameEventManager.ready_to_battle(myLevelData)

func has_level_data(levelData:LevelData):
	return myLevelData == levelData

func set_selected(isSelected:bool):
	chooseBtn.disabled = isSelected
	if isSelected:
		chooseBtn.text = "Selected"
	else:
		chooseBtn.text = "Select"
