extends Node

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

func _ready():
	Dungeon.battleInstance.connect("OnDungeonInitialized", self, "_on_dungeon_init")
	
func _on_dungeon_init():
	Dungeon.connect("OnTurnCompleted", self, "_on_turn_taken")
	Dungeon.connect("OnAttack", self, "_on_attack")
	Dungeon.connect("OnKill", self, "_on_kill")
	originalHealthRect = Vector2(healthBar.rect_size.x, healthBar.rect_size.y)
	Dungeon.player.connect("OnHealthChanged", self, "_on_player_health_changed")
	
func _on_turn_taken():
	turnLabel.text = str("Turns: ", Dungeon.turnsTaken)

func _on_attack(attacker, defender, damage):
	#detailsUI.visible = true
	enemyHealthUI.visible = true
	detailsLabel.text = str(attacker.characterName, " attacked ", defender.characterName, " for ", damage, " damage")
	
	if defender.team==Constants.TEAM.ENEMY and !registeredEnemies.has(defender):
		defender.connect("OnHealthChanged", self, "_on_enemy_health_changed")
		registeredEnemies[defender] = true
		
	#yield(get_tree().create_timer(10), "timeout")
	#detailsUI.visible = false
	#enemyHealthUI.visible = false
	#detailsLabel.text = ""
	
func _on_kill(attacker, defender):
	detailsUI.visible = true
	detailsLabel.text = str(attacker.characterName, " killed ", defender.characterName)
	if defender.team==Constants.TEAM.ENEMY:
		enemyHealthUI.visible = false
	yield(get_tree().create_timer(1), "timeout")
	detailsUI.visible = false

func _on_player_health_changed(charName:String, newVal:int, maxHealth:int):
	healthLabel.text = str("Player Health: ", newVal)
	var pctHealth:float = float(newVal)/float(maxHealth)
	healthBar.rect_size = Vector2(pctHealth * originalHealthRect.x, originalHealthRect.y)

func _on_enemy_health_changed(charName:String, newVal:int, maxHealth:int):
	enemyHealthLabel.text = str(charName, " Health: ", newVal)
	var pctHealth:float = float(newVal)/float(maxHealth)
	enemyHealthBar.rect_size = Vector2(pctHealth * originalHealthRect.x, originalHealthRect.y)
