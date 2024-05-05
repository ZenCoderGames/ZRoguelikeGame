extends Node2D

class_name SkillTreeNode

@export var id:String
var _skillData:SkillData
var _isUnlocked:bool
var _isLocked:bool
var _isStartNode:bool
var _parentNode:SkillTreeNode

signal OnSkillSelected(skillData, isLocked)

func init_from_data(skillDataVal:SkillData, isUnlockedVal:bool, isLockedVal:bool):
	_skillData = skillDataVal
	_isUnlocked = isUnlockedVal
	_isLocked = isLockedVal
	self.connect("button_up",Callable(self,"_on_item_chosen"))
	set_to_default_state()

func _on_item_chosen():
	UIEventManager.emit_signal("OnCharacterSelectButton")
	emit_signal("OnSkillSelected", _skillData, _isLocked)

func get_skill_data():
	return _skillData

func has_skill_data(skillData:SkillData):
	return _skillData == skillData

func set_selected(isSelected:bool):
	if isSelected:
		self.self_modulate = Color.YELLOW
	else:
		set_to_default_state()

func set_as_start_node():
	_isStartNode = true
	set_to_default_state()

func set_to_default_state():
	if _isStartNode:
		self.self_modulate = Color.DARK_SLATE_BLUE
	elif _isUnlocked:
		self.self_modulate = Color.GREEN
	elif _isLocked:
		self.self_modulate = Color.BLACK
	else:
		self.self_modulate = Color.DIM_GRAY

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
		_on_item_chosen()

func get_child_nodes():
	return _skillData.children

func has_parent():
	return _parentNode!=null

func set_parent(parentSkillTreeNode:SkillTreeNode):
	_parentNode = parentSkillTreeNode
	
func get_parent_node():
	return _parentNode
