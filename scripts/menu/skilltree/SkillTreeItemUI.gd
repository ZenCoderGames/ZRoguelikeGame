extends TextureButton

class_name SkillTreeItemUI

@export var id:String
var _skillData:SkillData
var _isCompleted:bool
var _isLocked:bool

signal OnSkillSelected(skillData, isLocked)

func init_from_data(skillDataVal:SkillData, isCompletedVal:bool, isLockedVal:bool):
	_skillData = skillDataVal
	_isCompleted = isCompletedVal
	_isLocked = isLockedVal
	self.connect("button_up",Callable(self,"_on_item_chosen"))
	set_to_default_state()

func _on_item_chosen():
	UIEventManager.emit_signal("OnCharacterSelectButton")
	emit_signal("OnSkillSelected", _skillData, _isLocked)

func has_skill_data(skillData:SkillData):
	return _skillData == skillData

func set_selected(isSelected:bool):
	if isSelected:
		self.self_modulate = Color.YELLOW
	else:
		set_to_default_state()

func set_to_default_state():
	if _isCompleted:
		self.self_modulate = Color.GREEN
	elif _isLocked:
		self.self_modulate = Color.BLACK
	else:
		self.self_modulate = Color.DARK_SLATE_GRAY
