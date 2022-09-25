extends PanelContainer

class_name CharacterSelectItemUI

onready var charLabel:Label = $"%CharNameLabel"
onready var descLabel:Label = $"%DescLabel"
onready var chooseBtn:Button = $"%ChooseButton"

var myCharData:CharacterData

func init_from_data(charData:CharacterData):
	myCharData = charData
	charLabel.text = Utils.convert_to_camel_case(charData.id)
	var statStr:String = ""
	for statData in charData.statDataList:
		statStr = statStr + Utils.convert_to_camel_case(statData.get_stat_name()) + ": " + str(statData.value) + "\n"
	statStr.erase(statStr.length()-1, 1)
	descLabel.text = statStr
	chooseBtn.connect("button_up", self, "_on_item_chosen")

func _on_item_chosen():
	GameEventManager.on_character_chosen(myCharData)
	GameEventManager.ready_to_battle()
