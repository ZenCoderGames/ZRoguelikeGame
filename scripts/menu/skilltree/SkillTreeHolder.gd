extends Node

@onready var skillTree:SkillTree = $"%SkillTreeNodeParent"

func _ready():
	self.visible = false
	UIEventManager.connect("ShowSkillTree", Callable(self, "_show"))

func _show(val:bool, skillTreeId:String):
	self.visible = val

	if val:
		skillTree.init_from_data(skillTreeId)
