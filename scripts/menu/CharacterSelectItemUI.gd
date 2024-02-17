extends PanelContainer

class_name CharacterSelectItemUI

@onready var charLabel:Label = $"%CharNameLabel"
@onready var descLabel:Label = $"%DescLabel"
@onready var chooseBtn:Button = $"%ChooseButton"
@onready var portrait:TextureRect = $"%Portrait"
@onready var active:TextureRect = $"%Active"
@onready var passive:TextureRect = $"%Passive"

var myCharData:CharacterData
var myDungeonPath:String

func init_from_data(charData:CharacterData, dungeonPath:String):
	myCharData = charData
	myDungeonPath = dungeonPath
	charLabel.text = Utils.convert_to_camel_case(charData.id)
	var statStr:String = ""
	for statData in charData.statDataList:
		if _is_showable_stat(statData):
			statStr = statStr + Utils.convert_to_camel_case(statData.get_stat_name()) + ": " + str(statData.value) + "\n"
	#statStr.erase(statStr.length()-1, 1)
	descLabel.text = statStr
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))
	var portraitTex = load(str("res://",myCharData.portraitPath))
	portrait.texture = portraitTex
	if !charData.specialId.is_empty():
		active.tooltip_text = GameGlobals.dataManager.get_special_data(charData.specialId).description
	else:
		active.self_modulate = Color.GRAY
	if !charData.passiveId.is_empty():
		passive.tooltip_text = GameGlobals.dataManager.get_passive_data(charData.passiveId).description
	else:
		passive.self_modulate = Color.GRAY

func _on_item_chosen():
	UIEventManager.emit_signal("OnCharacterSelectButton")
	GameEventManager.on_character_chosen(myCharData)
	GameGlobals.battleInstance.startWithClasses = !myCharData.isGeneric
	GameEventManager.ready_to_battle(myDungeonPath)

func _is_showable_stat(statData):
	if statData.type == StatData.STAT_TYPE.HEALTH or\
		statData.type == StatData.STAT_TYPE.DAMAGE or\
		statData.type == StatData.STAT_TYPE.ARMOR:
		return true

	return false
