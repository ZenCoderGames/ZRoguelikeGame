extends PanelContainer

class_name CharacterSelectItemUI

@onready var charLabel:Label = $"%CharNameLabel"
@onready var descLabel:Label = $"%DescLabel"
@onready var chooseBtn:Button = $"%ChooseButton"
@onready var portrait:TextureRect = $"%Portrait"
@onready var active:TextureRect = $"%Active"
@onready var passive:TextureRect = $"%Passive"

@onready var background:PanelContainer = $"%Bg"
@onready var unlockBtn:Button = $"%UnlockButton"

var myCharData:CharacterData

signal OnActiveOrPassiveInFocus(data)
signal OnActiveOrPassiveOutOfFocus
signal OnUnlocked

func init_from_data(charData:CharacterData):
	myCharData = charData
	charLabel.text = Utils.convert_to_camel_case(charData.description)
	var statStr:String = ""
	for statData in charData.statDataList:
		if _is_showable_stat(statData):
			statStr = statStr + Utils.convert_to_camel_case(statData.get_stat_name()) + ": " + str(statData.value) + "\n"
	#statStr.erase(statStr.length()-1, 1)
	descLabel.text = statStr
	chooseBtn.connect("button_up",Callable(self,"_on_item_chosen"))
	unlockBtn.connect("button_up",Callable(self,"_on_unlock"))
	var portraitTex = load(str("res://",myCharData.portraitPath))
	portrait.texture = portraitTex
	if !charData.specials.is_empty():
		active.connect("mouse_entered",Callable(self,"_on_active_in_focus"))
		active.connect("mouse_exited",Callable(self,"_on_active_out_of_focus"))
	else:
		active.self_modulate = Color.GRAY
	if !charData.passives.is_empty():
		passive.connect("mouse_entered",Callable(self,"_on_passive_in_focus"))
		passive.connect("mouse_exited",Callable(self,"_on_passive_out_of_focus"))
	else:
		passive.self_modulate = Color.GRAY

	_checkForUnlock()

func _on_item_chosen():
	UIEventManager.emit_signal("OnCharacterSelectButton")
	GameGlobals.battleInstance.startWithClasses = !myCharData.isGeneric
	GameEventManager.on_character_chosen(myCharData)

func _is_showable_stat(statData):
	if statData.type == StatData.STAT_TYPE.HEALTH or\
		statData.type == StatData.STAT_TYPE.DAMAGE or\
		statData.type == StatData.STAT_TYPE.ARMOR:
		return true

	return false

func _on_active_in_focus():
	emit_signal("OnActiveOrPassiveInFocus", GameGlobals.dataManager.get_special_data(myCharData.specials[0]).description)

func _on_active_out_of_focus():
	emit_signal("OnActiveOrPassiveOutOfFocus")

func _on_passive_in_focus():
	emit_signal("OnActiveOrPassiveInFocus", GameGlobals.dataManager.get_passive_data(myCharData.passives[0]).description)

func _on_passive_out_of_focus():
	emit_signal("OnActiveOrPassiveOutOfFocus")

# Unlocking
func _checkForUnlock():
	if !is_unlocked():
		if is_unlockable():
			unlockBtn.text = str("Unlock (x", myCharData.unlockCost, ")")
			unlockBtn.disabled = false
			unlockBtn.modulate = Color.GREEN
		else:
			unlockBtn.text = str("Unlock (x", myCharData.unlockCost, ")")
			unlockBtn.disabled = true
			unlockBtn.modulate = Color.RED
		unlockBtn.visible = true
		chooseBtn.visible = false
		background.modulate = Color.DIM_GRAY
	else:
		unlockBtn.visible = false
		chooseBtn.visible = true
		background.modulate = Color.WHITE

func _on_unlock():
	PlayerDataManager.unlock_character(myCharData)
	emit_signal("OnUnlocked")

func refresh():
	_checkForUnlock()

func select():
	chooseBtn.modulate = Color.YELLOW
	unlockBtn.modulate = Color.YELLOW
	
func deselect():
	chooseBtn.modulate = Color.WHITE
	unlockBtn.modulate = Color.WHITE
	_checkForUnlock()
	
func confirm():
	if is_unlocked():
		chooseBtn.emit_signal("button_up")
	else:
		unlockBtn.emit_signal("button_up")

func is_unlocked():
	return PlayerDataManager.has_character_been_unlocked(myCharData)
	
func is_unlockable():
	return PlayerDataManager.can_unlock_character(myCharData)
