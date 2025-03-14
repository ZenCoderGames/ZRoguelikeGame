extends Panel

class_name SkillTreeNode_v2

var _skillData:SkillData
var _isUnlocked:bool
var _parentNode:SkillTreeNode

@export var nameLabel:Label
@export var selectedPanel:Panel
@export var enabledTex:TextureRect
@export var disabledTex:TextureRect

signal OnSkillSelected(skillData)

func init_from_data(skillDataVal:SkillData, isUnlockedVal:bool, isLockedVal:bool):
	_skillData = skillDataVal
	_isUnlocked = isUnlockedVal
	refresh()
	nameLabel.text = _skillData.name

func _on_item_chosen():
	UIEventManager.emit_signal("OnCharacterSelectButton")
	emit_signal("OnSkillSelected", _skillData)

func get_skill_data():
	return _skillData

func has_skill_data(skillData:SkillData):
	return _skillData == skillData

func set_selected(isSelected:bool):
	selectedPanel.visible = isSelected

func refresh():
	var isEnabled:bool = PlayerDataManager.is_skill_enabled(GameGlobals.currentSelectedHero, _skillData)
	if PlayerDataManager.has_skill_been_unlocked(_skillData.id):
		self.self_modulate = Color.GREEN
		enabledTex.visible = isEnabled
		disabledTex.visible = !isEnabled
	else:
		self.self_modulate = Color.DIM_GRAY
		enabledTex.visible = false
		disabledTex.visible = false

func get_child_nodes():
	return _skillData.children

func has_parent():
	return _parentNode!=null

func set_parent(parentSkillTreeNode:SkillTreeNode):
	_parentNode = parentSkillTreeNode
	
func get_parent_node():
	return _parentNode

func _on_button_pressed() -> void:
	_on_item_chosen()
