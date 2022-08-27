extends Node

class_name MainMenuUI

onready var newGameButton:Button = $"%NewGameButton"
onready var saveGameButton:Button = $"%SaveGameButton"
onready var loadGameButton:Button = $"%LoadGameButton"
onready var settingsButton:Button = $"%SettingsButton"

onready var deathUI:Node = $"%DeathUI"

signal OnNewGamePressed()

# Called when the node enters the scene tree for the first time.
func _ready():
	newGameButton.connect("button_up", self, "on_new_game")
	saveGameButton.connect("button_up", self, "on_save_game")
	loadGameButton.connect("button_up", self, "on_load_game")
	settingsButton.connect("button_up", self, "on_settings")
	deathUI.visible = false
	
	Dungeon.battleInstance.connect("OnDungeonInitialized", self, "_on_dungeon_init")
	Dungeon.battleInstance.connect("OnDungeonRecreated", self, "_on_dungeon_recreated")
	
func _on_dungeon_init():
	_shared_init()

func _on_dungeon_recreated():
	_clean_up()
	_shared_init()

func _shared_init():
	Dungeon.player.connect("OnDeath", self, "_on_game_over")

func on_new_game():
	emit_signal("OnNewGamePressed")
	
func on_save_game():
	pass
	
func on_load_game():
	pass
	
func on_settings():
	pass

func _on_game_over():
	get_node(".").visible = true
	deathUI.visible = true

func _clean_up():
	deathUI.visible = false
