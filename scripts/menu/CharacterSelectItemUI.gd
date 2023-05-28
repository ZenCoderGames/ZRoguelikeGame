extends PanelContainer

class_name CharacterSelectItemUI

@onready var charLabel:Label = $"%CharNameLabel"
@onready var descLabel:Label = $"%DescLabel"
@onready var chooseBtn:Button = $"%ChooseButton"
@onready var portrait:TextureRect = $"%Portrait"
@onready var active:TextureRect = $"%Active"
@onready var passive:TextureRect = $"%Passive"

var myCharData:CharacterData

func init_from_data(charData:CharacterData):
	myCharData = charData
	charLabel.text = Utils.convert_to_camel_case(charData.id)
	var statStr:String = ""
	for statData in charData.statDataList:
		statStr = statStr + Utils.convert_to_camel_case(statData.get_stat_name()) + ": " + str(statData.value) + "\n"
	#statStr.erase(statStr.length()-1, 1)
	descLabel.text = statStr
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))
	var portraitTex = load(str("res://",myCharData.portraitPath))
	portrait.texture = portraitTex
	active.tooltip_text = charData.active.description
	passive.tooltip_text = GameGlobals.dataManager.get_passive_data(charData.passive).description

func _on_item_chosen():
	GameEventManager.on_character_chosen(myCharData)
	GameEventManager.ready_to_battle()
