extends Node

func _ready():
	self.visible = false
	GameEventManager.connect("ShowSkillTree", Callable(self,"_show"))

func _show(val:bool):
	self.visible = val
