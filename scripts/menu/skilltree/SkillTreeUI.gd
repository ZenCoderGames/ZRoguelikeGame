extends Panel

class_name SkillTreeUI

@onready var infoPanel:Panel = $"%InfoPanel"
@onready var infoLabel:RichTextLabel = $"%InfoLabel"
@onready var backButton:TextureButton = $"%BackButton"
@onready var titleLabel:Label = $"%TitleLabel"
@onready var skillNameLabel:Label = $"%SkillNameLabel"
@onready var unlockButton:Button = $"%UnlockButton"
@export var skillItemUIList:Array[SkillTreeItemUI]

var _skillTreeData:SkillTreeData
var _selectedSkillData:SkillData

signal OnBackPressed

func _ready():
	for skillTreeItemUI in skillItemUIList:
		skillTreeItemUI.connect("OnSkillSelected",Callable(self,"_on_skill_selected"))

func init_from_data(skillTreeData:SkillTreeData):
	clean_up()
	hide_info()

	_skillTreeData = skillTreeData

	for skillData in skillTreeData.skillList:
		init_skill(skillData)

	backButton.connect("pressed",Callable(self,"_on_back_button_pressed"))
	unlockButton.connect("pressed",Callable(self,"_on_unlock_button_pressed"))
	unlockButton.visible = false
	
	emit_signal("item_rect_changed")
	GameEventManager.emit_signal("ShowSkillTree", true)

func init_skill(skillData:SkillData):
	var skillTreeItemUI:SkillTreeItemUI = _findSkillTreeItemUI(skillData.uiHolderId)
	if skillTreeItemUI!=null:
		var hasBeenUnlocked:bool = PlayerDataManager.has_skill_been_unlocked(skillData.id)
		var isLocked:bool = false
		var hasParent:bool = !skillData.parentSkillId.is_empty()
		if hasParent:
			var isParentUnlocked:bool = PlayerDataManager.has_skill_been_unlocked(skillData.parentSkillId)
			isLocked = !isParentUnlocked
		skillTreeItemUI.init_from_data(skillData, hasBeenUnlocked, isLocked)

func _findSkillTreeItemUI(skillTreeItemUIId:String):
	for skillTreeItemUI in skillItemUIList:
		if skillTreeItemUI.id == skillTreeItemUIId:
			return skillTreeItemUI

	return null

func _on_skill_selected(skillData:SkillData, isLocked:bool):
	unlockButton.visible = !isLocked
	unlockButton.disabled = !PlayerDataManager.can_unlock_skill(skillData)
	unlockButton.text = str(" Unlock: ", skillData.unlockCost)
	_selectedSkillData = skillData
	skillNameLabel.text = skillData.name
	show_info(_selectedSkillData.description)

	for skillItemUI in skillItemUIList:
		skillItemUI.set_selected(skillItemUI.has_skill_data(skillData))

func show_info(str:String):
	infoPanel.visible = true
	infoLabel.text = Utils.format_text(str)
	#await get_tree().create_timer(0.75).timeout
	#hide_info()
	
func hide_info():
	infoPanel.visible = false

func clean_up():
	backButton.disconnect("pressed",Callable(self,"_on_back_button_pressed"))
	unlockButton.disconnect("pressed",Callable(self,"_on_ready_button_pressed"))

func _on_back_button_pressed():
	emit_signal("OnBackPressed")

func _on_unlock_button_pressed():
	PlayerDataManager.unlock_skill(_selectedSkillData)
	for skillData in _skillTreeData.skillList:
		init_skill(skillData)
	unlockButton.visible = false
