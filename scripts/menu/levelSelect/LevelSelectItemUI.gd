extends TextureButton

class_name LevelSelectItemUI

var myCharData:CharacterData
var myLevelData:LevelData
var isCompleted:bool
var isLocked:bool

signal OnLevelSelected(levelData, isLocked)

func init_from_data(charData:CharacterData, levelData:LevelData, isCompletedVal:bool, isLockedVal:bool):
	myCharData = charData
	myLevelData = levelData
	isCompleted = isCompletedVal
	isLocked = isLockedVal
	self.connect("button_up",Callable(self,"_on_item_chosen"))
	set_to_default_state()

func _on_item_chosen():
	UIEventManager.emit_signal("OnCharacterSelectButton")
	GameGlobals.battleInstance.startWithClasses = !myCharData.isGeneric
	emit_signal("OnLevelSelected", myLevelData, isLocked)

func has_level_data(levelData:LevelData):
	return myLevelData == levelData

func set_selected(isSelected:bool):
	if isSelected:
		self.self_modulate = Color.YELLOW
	else:
		set_to_default_state()

func set_to_default_state():
	if isCompleted:
		self.self_modulate = Color.GREEN
	elif isLocked:
		self.self_modulate = Color.BLACK
	else:
		self.self_modulate = Color.DARK_SLATE_GRAY
