extends Control

class_name PlayerSpecialAbilityUI

@onready var SpecialProgressBar:ProgressBar = $VBoxContainer/ProgressBar
@onready var SpecialActiveButton:Button = $VBoxContainer/ActiveButton
@onready var SpecialPassiveButton:Button = $VBoxContainer/PassiveButton

func _ready():
	self.visible = false
	SpecialProgressBar.value = 0
	SpecialActiveButton.disabled = true
	SpecialActiveButton.connect("pressed",Callable(self,"_on_special_pressed"))
	SpecialActiveButton.connect("mouse_entered",Callable(self,"_on_mouse_entered_active"))
	SpecialActiveButton.connect("mouse_exited",Callable(self,"_on_mouse_exited_active"))
	
	#SpecialPassiveButton.disabled = true
	SpecialPassiveButton.connect("mouse_entered",Callable(self,"_on_mouse_entered_passive"))
	SpecialPassiveButton.connect("mouse_exited",Callable(self,"_on_mouse_exited_passive"))
	
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnNewLevelLoaded",Callable(self,"_on_dungeon_init"))

	CombatEventManager.connect("OnPlayerSpecialAbilityProgress",Callable(self,"_on_ability_progress"))
	CombatEventManager.connect("OnPlayerSpecialAbilityReady",Callable(self,"_on_ability_ready"))
	CombatEventManager.connect("OnPlayerSpecialAbilityReset",Callable(self,"_on_ability_reset"))

func _on_dungeon_init():
	pass

func _on_ability_progress(percent:float):
	SpecialProgressBar.value = percent * 100

func _on_ability_ready():
	SpecialActiveButton.disabled = false

func _on_ability_reset():
	SpecialProgressBar.value = 0
	SpecialActiveButton.disabled = true

func _on_special_pressed():
	CombatEventManager.on_player_special_ability_pressed()

func _on_mouse_entered_active():
	CombatEventManager.on_show_info("Special", GameGlobals.dungeon.player.special.data.description)

func _on_mouse_exited_active():
	CombatEventManager.on_hide_info()

func _on_mouse_entered_passive():
	CombatEventManager.on_show_info("Trait", GameGlobals.dungeon.player.specialPassive.data.description)

func _on_mouse_exited_passive():
	CombatEventManager.on_hide_info()
