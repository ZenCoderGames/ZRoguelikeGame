extends Panel

class_name SkillTreeUI

@onready var infoPanel:Panel = $"%InfoPanel"
@onready var infoLabel:RichTextLabel = $"%InfoLabel"
@onready var backButton:TextureButton = $"%BackButton"
@onready var titleLabel:Label = $"%TitleLabel"
@onready var skillNameLabel:Label = $"%SkillNameLabel"
@onready var unlockButton:Button = $"%UnlockButton"

var _skillTreeData:SkillTreeData
var _selectedSkillData:SkillData

signal OnBackPressed

func _init():
	UIEventManager.connect("OnSkillNodeSelected", Callable(self, "_on_skill_selected"))

func init_from_data(skillTreeId:String):
	clean_up()
	hide_info()

	_skillTreeData = GameGlobals.dataManager.skilltreeDict[skillTreeId]

	backButton.connect("pressed",Callable(self,"_on_back_button_pressed"))
	unlockButton.connect("pressed",Callable(self,"_on_unlock_button_pressed"))
	unlockButton.visible = false
	
	emit_signal("item_rect_changed")
	UIEventManager.emit_signal("ShowSkillTree", true, skillTreeId)

func _on_skill_selected(skillData:SkillData, isLocked:bool):
	var skillName:String = skillData.name
	unlockButton.visible = !isLocked
	unlockButton.disabled = !PlayerDataManager.can_unlock_skill(skillData)
	unlockButton.text = str(" Unlock: ", skillData.unlockCost)
	if skillData.isStartNode:
		unlockButton.visible = false
	if PlayerDataManager.has_skill_been_unlocked(skillData.id):
		unlockButton.visible = false
		skillName = str(skillName, " (Unlocked)")

	_selectedSkillData = skillData
	skillNameLabel.text = skillName
	show_info(skillData.description)

func show_info(val:String):
	infoPanel.visible = true
	infoLabel.text = Utils.format_text(val)
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
	UIEventManager.emit_signal("OnSkillUnlocked")
	unlockButton.visible = false
