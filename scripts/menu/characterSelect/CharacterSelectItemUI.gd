extends PanelContainer

class_name CharacterSelectItemUI

@onready var charLabel:Label = $"%CharNameLabel"
@onready var levelLabel:Label = $"%LevelLabel"
@onready var descLabel:Label = $"%DescLabel"
@onready var portrait:TextureRect = $"%Portrait"
@onready var active:TextureRect = $"%Active"
@onready var passive:TextureRect = $"%Passive"

@onready var background:PanelContainer = $"%Bg"
@onready var selectBtn:Button = $"%SelectButton"
@onready var confirmBtn:Button = $"%ConfirmButton"
@onready var unlockBtn:Button = $"%UnlockButton"

@onready var levelHolder:HBoxContainer = $"%LevelHolder"
@onready var xpProgressBar:ProgressBar = $"%XPProgressBar"

var myCharData:CharacterData

signal OnSelected(itemUI)
signal OnActiveOrPassiveInFocus(data)
signal OnActiveOrPassiveOutOfFocus
signal OnUnlocked

func init_from_data(charData:CharacterData):
	myCharData = charData
	var xp:int = PlayerDataManager.currentPlayerData.get_hero_xp_for_next_level(charData.id)
	var level:int = PlayerDataManager.currentPlayerData.get_hero_level(charData.id)
	charLabel.text = Utils.convert_to_camel_case(charData.description)
	var statStr:String = ""
	for statData in charData.statDataList:
		if _is_showable_stat(statData):
			statStr = statStr + Utils.convert_to_camel_case(statData.get_stat_name()) + ": " + str(statData.value) + "\n"
	#statStr.erase(statStr.length()-1, 1)
	levelLabel.text = str("Level: ", level)
	descLabel.text = statStr
	selectBtn.connect("button_up",Callable(self,"_on_item_selected"))
	confirmBtn.connect("button_up",Callable(self,"_on_item_chosen"))
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
		
	xpProgressBar.value = xp
	
	_checkForUnlock()
	
	levelHolder.visible = is_unlocked()

func _on_item_selected():
	emit_signal("OnSelected", self)

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
		selectBtn.visible = false
		confirmBtn.visible = false
		background.modulate = Color.DIM_GRAY
	else:
		unlockBtn.visible = false
		selectBtn.visible = true
		confirmBtn.visible = false
		background.modulate = Color.WHITE

func _on_unlock():
	if is_unlockable():
		PlayerDataManager.unlock_character(myCharData)
		emit_signal("OnUnlocked")

func refresh():
	_checkForUnlock()

func select():
	selectBtn.modulate = Color.YELLOW
	unlockBtn.modulate = Color.YELLOW
	selectBtn.visible = false
	confirmBtn.visible = true
	GameGlobals.currentSelectedHero = myCharData
	
func deselect():
	selectBtn.modulate = Color.WHITE
	unlockBtn.modulate = Color.WHITE
	_checkForUnlock()
	
func confirm():
	if is_unlocked():
		confirmBtn.emit_signal("button_up")
	else:
		unlockBtn.emit_signal("button_up")

func is_unlocked():
	return PlayerDataManager.has_character_been_unlocked(myCharData)
	
func is_unlockable():
	return PlayerDataManager.can_unlock_character(myCharData)
