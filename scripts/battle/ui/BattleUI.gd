extends Node

class_name BattleUI

onready var turnLabel:Label = get_node("TurnContainer/TurnLabel")
# details
onready var detailsUI:Node = get_node("DetailsUI")
onready var detailsLabel:Label = get_node("DetailsUI/DetailsLabel")
# player health
onready var playerPanel:Node = get_node("PlayerPanel")
var playerUI:CharacterUI
# info panel
onready var infoPanel:Node = get_node("InfoPanel")
var infoPanelObjects:Array = []
var registeredEnemies:Dictionary = {}
const CharacterUI := preload("res://ui/battle/CharacterUI.tscn")
const ItemUI := preload("res://ui/battle/ItemUI.tscn")
# inventory UI
const InventoryUI := preload("res://ui/battle/InventoryUI.tscn")
var inventoryUI:InventoryUI = null
# death UI
onready var deathUI:Node = get_node("DeathUI")

func _ready():
	deathUI.visible = false
	Dungeon.battleInstance.connect("OnDungeonInitialized", self, "_on_dungeon_init")
	Dungeon.battleInstance.connect("OnDungeonRecreated", self, "_on_dungeon_recreated")
	Dungeon.battleInstance.connect("OnToggleInventory", self, "_on_toggle_inventory")

	inventoryUI = InventoryUI.instance()
	self.add_child(inventoryUI)
	
func _on_dungeon_init():
	_shared_init()
	
	Dungeon.connect("OnEndTurn", self, "_on_turn_taken")
	HitResolutionManager.connect("OnPostHit", self, "_on_attack")
	HitResolutionManager.connect("OnKill", self, "_on_kill")

func _on_dungeon_recreated():
	_clean_up()
	_shared_init()

func _shared_init():
	deathUI.visible = false
	playerUI = CharacterUI.instance()
	playerPanel.add_child(playerUI)

	inventoryUI.init(Dungeon.player)
	
	Dungeon.player.connect("OnDeath", self, "_on_player_death")
	Dungeon.player.connect("OnCharacterMoveToCell", self, "_on_player_move")
	Dungeon.player.connect("OnNearbyEntityFound", self, "_on_entity_nearby")
	Dungeon.player.inventory.connect("OnItemAdded", self, "_on_item_picked_by_player")
	
	playerUI.init(Dungeon.player)

	
func _on_turn_taken():
	turnLabel.text = str("Turns: ", Dungeon.turnsTaken)
	
func _on_attack(attacker, defender, damage):
	detailsLabel.text = str(attacker.displayName, " attacked ", defender.displayName, " for ", damage, " damage")
	
func _on_kill(attacker, defender):
	# Info panel
	_info_panel_handle_death(defender)
	
	# Details panel
	detailsUI.visible = true
	detailsLabel.text = str(attacker.displayName, " killed ", defender.displayName)
	yield(get_tree().create_timer(1), "timeout")
	detailsUI.visible = false
	
func _on_item_picked_by_player(item):
	detailsUI.visible = true
	detailsLabel.text = str(item.data.displayName, " picked up ")
	yield(get_tree().create_timer(1), "timeout")
	detailsUI.visible = false

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

# INVENTORY PANEL
var isInventoryOpen:bool = false
func _on_toggle_inventory():
	isInventoryOpen = !isInventoryOpen
	if isInventoryOpen:
		inventoryUI.show()
	else:
		inventoryUI.hide()

func _clean_up():
	playerPanel.remove_child(playerUI)
	playerUI.queue_free()

	for infoObject in infoPanelObjects:
		if !weakref(infoObject).get_ref():
			continue
			
		infoPanel.remove_child(infoObject)
		infoObject.queue_free()

	infoPanelObjects.clear()
	detailsLabel.text = ""

	isInventoryOpen = false
	inventoryUI.clean_up()
