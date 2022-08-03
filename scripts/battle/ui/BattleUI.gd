extends Node

class_name BattleUI

onready var turnLabel:Label = get_node("TurnLabel")
# details
onready var detailsUI:Node = get_node("DetailsUI")
onready var detailsLabel:Label = get_node("DetailsUI/DetailsLabel")
# health
onready var healthBar:ColorRect = get_node("PlayerStats/PlayerHealth/HealthBar")
onready var healthLabel:Label = get_node("PlayerStats/PlayerHealth/HealthLabel")
var originalHealthRect:Vector2
onready var enemyHealthUI:Node = get_node("PlayerStats/EnemyHealth")
onready var enemyHealthBar:ColorRect = get_node("PlayerStats/EnemyHealth/HealthBar")
onready var enemyHealthLabel:Label = get_node("PlayerStats/EnemyHealth/HealthLabel")
var registeredEnemies:Dictionary = {}
# death UI
onready var deathUI:Node = get_node("DeathUI")

func _ready():
	deathUI.visible = false
	originalHealthRect = Vector2(healthBar.rect_size.x, healthBar.rect_size.y)
	Dungeon.battleInstance.connect("OnDungeonInitialized", self, "_on_dungeon_init")
	Dungeon.battleInstance.connect("OnDungeonRecreated", self, "_on_dungeon_init")
	
func _on_dungeon_init():
	deathUI.visible = false
	
	Dungeon.connect("OnTurnCompleted", self, "_on_turn_taken")
	Dungeon.connect("OnAttack", self, "_on_attack")
	Dungeon.connect("OnKill", self, "_on_kill")
	
	Dungeon.player.connect("OnStatChanged", self, "_on_player_stat_changed")
	Dungeon.player.connect("OnDeath", self, "_on_player_death")
	
	Dungeon.player.connect("OnItemPicked", self, "_on_item_picked")
	
	_on_player_stat_changed(Dungeon.player)
	
func _on_turn_taken():
	turnLabel.text = str("Turns: ", Dungeon.turnsTaken)

func _on_attack(attacker, defender, damage):
	#detailsUI.visible = true
	enemyHealthUI.visible = true
	detailsLabel.text = str(attacker.displayName, " attacked ", defender.displayName, " for ", damage, " damage")
	
	if defender.team==Constants.TEAM.ENEMY and !registeredEnemies.has(defender):
		defender.connect("OnStatChanged", self, "_on_enemy_stat_changed")
		registeredEnemies[defender] = true
	
	if defender.team==Constants.TEAM.ENEMY:
		_on_enemy_stat_changed(defender)
	else:
		_on_enemy_stat_changed(attacker)
	
func _on_kill(attacker, defender):
	detailsUI.visible = true
	detailsLabel.text = str(attacker.displayName, " killed ", defender.displayName)
	if defender.team==Constants.TEAM.ENEMY:
		enemyHealthUI.visible = false
	yield(get_tree().create_timer(1), "timeout")
	detailsUI.visible = false
	
func _on_item_picked(item):
	detailsUI.visible = true
	detailsLabel.text = str(item.data.name, " picked up ")
	yield(get_tree().create_timer(1), "timeout")
	detailsUI.visible = false

func _on_player_stat_changed(character):
	# Update Health
	healthLabel.text = str("Player Health: ", character.get_health())
	var pctHealth:float = float(character.get_health())/float(character.get_max_health())
	healthBar.rect_size = Vector2(pctHealth * originalHealthRect.x, originalHealthRect.y)

func _on_enemy_stat_changed(character:Character):
	# Update Health
	enemyHealthLabel.text = str(character.displayName, " Health: ", character.get_health())
	var pctHealth:float = float(character.get_health())/float(character.get_max_health())
	enemyHealthBar.rect_size = Vector2(pctHealth * originalHealthRect.x, originalHealthRect.y)

func _on_player_death():
	deathUI.visible = true
