extends Node

class_name BattleUI

onready var turnLabel:Label = get_node("TurnLabel")
# details
onready var detailsUI:Node = get_node("DetailsUI")
onready var detailsLabel:Label = get_node("DetailsUI/DetailsLabel")
# player health
onready var healthBar:ColorRect = get_node("PlayerStats/PlayerHealth/HealthBar")
onready var healthLabel:Label = get_node("PlayerStats/PlayerHealth/HealthLabel")
var originalHealthRect:Vector2
# info panel
onready var infoPanel:Node = get_node("InfoPanel")
var infoPanelObjects:Array = []
var registeredEnemies:Dictionary = {}
const CharacterUI := preload("res://ui/battle/CharacterUI.tscn")
const ItemUI := preload("res://ui/battle/ItemUI.tscn")
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
	
	Dungeon.player.connect("OnCharacterMoveToCell", self, "_on_player_move")
	Dungeon.player.connect("OnNearbyEntityFound", self, "_on_entity_nearby")
	Dungeon.player.connect("OnItemPicked", self, "_on_item_picked")
	
	_on_player_stat_changed(Dungeon.player)
	
func _on_turn_taken():
	turnLabel.text = str("Turns: ", Dungeon.turnsTaken)
	
func _on_attack(attacker, defender, damage):
	detailsLabel.text = str(attacker.displayName, " attacked ", defender.displayName, " for ", damage, " damage")
	
	#_refresh_info_panel()
	
	""""
	if defender.team==Constants.TEAM.ENEMY and !registeredEnemies.has(defender):
		defender.connect("OnStatChanged", self, "_on_enemy_stat_changed")
		registeredEnemies[defender] = true
	
	if defender.team==Constants.TEAM.ENEMY:
		_on_enemy_stat_changed(defender)
	else:
		_on_enemy_stat_changed(attacker)"""
	
func _on_kill(attacker, defender):
	# Info panel
	_info_panel_handle_death(defender)
	
	# Details panel
	detailsUI.visible = true
	detailsLabel.text = str(attacker.displayName, " killed ", defender.displayName)
	yield(get_tree().create_timer(1), "timeout")
	detailsUI.visible = false
	
func _on_item_picked(item):
	detailsUI.visible = true
	detailsLabel.text = str(item.data.displayName, " picked up ")
	yield(get_tree().create_timer(1), "timeout")
	detailsUI.visible = false

func _on_player_stat_changed(character):
	# Update Health
	healthLabel.text = str("Player Health: ", character.get_health())
	var pctHealth:float = float(character.get_health())/float(character.get_max_health())
	healthBar.rect_size = Vector2(pctHealth * originalHealthRect.x, originalHealthRect.y)

func _on_player_death():
	deathUI.visible = true
	
# INFO PANEL
func _on_player_move():
	for infoObject in infoPanelObjects:
		infoPanel.remove_child(infoObject)
		if weakref(infoObject).get_ref():
			infoObject.queue_free()
		
	infoPanelObjects.clear()

func _on_entity_nearby(entity):
	if _info_panel_has_entity(entity):
		return
		
	if entity is Character:
		var newCharUI = CharacterUI.instance()
		infoPanel.add_child(newCharUI)
		infoPanelObjects.append(newCharUI)
		newCharUI.init(entity)
	elif entity is Item:
		var newItemUI = ItemUI.instance()
		infoPanel.add_child(newItemUI)
		infoPanelObjects.append(newItemUI)
		newItemUI.init(entity)

func _refresh_info_panel():
	for infoObject in infoPanelObjects:
		infoObject.update_ui()

func _info_panel_handle_death(character):
	for infoObject in infoPanelObjects:
		if !weakref(infoObject).get_ref():
			continue
			
		if infoObject.has_entity(character):
			infoPanel.remove_child(infoObject)
			infoObject.queue_free()

func _info_panel_has_entity(entity):
	for infoObject in infoPanelObjects:
		if !weakref(infoObject).get_ref():
			continue
			
		if infoObject.has_entity(entity):
			return true
	
	return false
