extends Node

class_name VictoryUI

@onready var gridContainer:GridContainer = $"%VictoryGridContainer"
@onready var progressLabel:Label = $"%VictoryProgressLabel"
@onready var backBtn:TextureButton = $"%BackButton"

const BattleEndEnemyXPUIClass := preload("res://ui/battleEnd/BattleEndEnemyXPUI.tscn")

signal OnBackPressed

func _ready() -> void:
	backBtn.connect("button_up",Callable(self,"_on_back_pressed"))

func init_data():
	var dp:DungeonProgress = GameGlobals.dungeon.dungeonProgress
	for enemyKilledData in dp.enemyKilledList:
		var battleEndEnemyXPUI := BattleEndEnemyXPUIClass.instantiate()
		gridContainer.add_child(battleEndEnemyXPUI)
		battleEndEnemyXPUI.init(enemyKilledData, dp.get_enemy_count(enemyKilledData))

	progressLabel.text = GameGlobals.dungeon.dungeonProgress.get_progress_description()
	PlayerDataManager.add_hero_xp(GameGlobals.dungeon.player.charData.id, GameGlobals.dungeon.dungeonProgress.enemyXPEarned)
	PlayerDataManager.add_current_xp(GameGlobals.dungeon.dungeonProgress.get_progress())

func clean_up():
	var deathGridChildren:Array = gridContainer.get_children()
	for gridItem in deathGridChildren:
		gridContainer.remove_child(gridItem)
		gridItem.queue_free()

func _on_back_pressed():
	emit_signal("OnBackPressed")
