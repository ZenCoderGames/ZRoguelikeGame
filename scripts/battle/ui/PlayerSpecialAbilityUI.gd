extends Control

class_name PlayerSpecialAbilityUI

onready var SpecialProgressBar:ProgressBar = $VBoxContainer/ProgressBar
onready var SpecialButton:Button = $VBoxContainer/Button

func _ready():
	self.visible = false
	SpecialProgressBar.value = 0
	SpecialButton.disabled = true
	SpecialButton.connect("pressed", self, "_on_special_pressed")
	Dungeon.battleInstance.connect("OnDungeonInitialized", self, "_on_dungeon_init")

func _on_dungeon_init():
	Dungeon.connect("OnPlayerSpecialAbilityProgress", self, "_on_ability_progress")
	Dungeon.connect("OnPlayerSpecialAbilityReady", self, "_on_ability_ready")
	Dungeon.connect("OnPlayerSpecialAbilityReset", self, "_on_ability_reset")

func _on_ability_progress(percent:float):
	SpecialProgressBar.value = percent * 100

func _on_ability_ready():
	SpecialButton.disabled = false

func _on_ability_reset():
	SpecialProgressBar.value = 0
	SpecialButton.disabled = true

func _on_special_pressed():
	CombatEventManager.on_player_special_ability_pressed()

func _on_mouse_entered():
	CombatEventManager.on_show_info("Special Ability", Dungeon.player.special.data.description)

func _on_mouse_exited():
	CombatEventManager.on_hide_info()
