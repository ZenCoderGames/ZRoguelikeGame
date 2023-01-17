extends Node

class_name BattleUI

onready var levelLabel:Label = get_node("BattleProgressPanel/LevelContainer/LevelLabel")
onready var turnLabel:Label = get_node("BattleProgressPanel/TurnContainer/TurnLabel")
# touchControls
onready var touchControls:Node = $TouchControls
onready var upArrowBtn:Button = $TouchControls/UpArrow
onready var downArrowBtn:Button = $TouchControls/DownArrow
onready var leftArrowBtn:Button = $TouchControls/LeftArrow
onready var rightArrowBtn:Button = $TouchControls/RightArrow
onready var skipTurnBtn:Button = $TouchControls/SkipTurn
# details
onready var detailsUI:Node = get_node("DetailsUI")
onready var detailsLabel:Label = get_node("DetailsUI/DetailsLabel")
# player xp/equipment
onready var playerPanel:Node = get_node("PlayerPanel")
var playerUI:CharacterUI
# player ability
onready var playerSpecialUI:Node = get_node("PlayerAbilityPanel")
# info panel
onready var infoPanel:Node = get_node("InfoPanel")
var infoPanelObjects:Array = []
var registeredEnemies:Dictionary = {}
const CharacterUI := preload("res://ui/battle/CharacterUI.tscn")
const ItemUI := preload("res://ui/battle/ItemUI.tscn")
# inventory UI
const InventoryUI := preload("res://ui/battle/InventoryUI.tscn")
var inventoryUI:InventoryUI = null
# info UI
const InfoUI := preload("res://ui/battle/InfoUI.tscn")
var infoUI:InfoUI = null

func _ready():
	GameEventManager.connect("OnDungeonInitialized", self, "_on_dungeon_init")
	GameEventManager.connect("OnDungeonRecreated", self, "_on_dungeon_recreated")
	GameEventManager.connect("OnNewLevelLoaded", self, "_on_new_level_loaded")
	CombatEventManager.connect("OnToggleInventory", self, "_on_toggle_inventory")
	CombatEventManager.connect("OnShowInfo", self, "_on_show_info")
	CombatEventManager.connect("OnHideInfo", self, "_on_hide_info")

	inventoryUI = InventoryUI.instance()
	self.add_child(inventoryUI)
	
	infoUI = InfoUI.instance()
	self.add_child(infoUI)
	infoUI.hide()
	
	_setup_touch_buttons()
	
func _on_dungeon_init():
	_shared_init()
	
	CombatEventManager.connect("OnEndTurn", self, "_on_turn_taken")
	HitResolutionManager.connect("OnPostHit", self, "_on_attack")
	HitResolutionManager.connect("OnKill", self, "_on_kill")

func _on_dungeon_recreated():
	_clean_up()
	_shared_init()

func _shared_init():
	touchControls.visible = true
	
	playerUI = CharacterUI.instance()
	playerPanel.add_child(playerUI)

	inventoryUI.init(GameGlobals.dungeon.player)
	
	GameGlobals.dungeon.player.connect("OnCharacterMoveToCell", self, "_on_player_move")
	GameGlobals.dungeon.player.connect("OnNearbyEntityFound", self, "_on_entity_nearby")
	GameGlobals.dungeon.player.inventory.connect("OnItemAdded", self, "_on_item_picked_by_player")
	
	playerUI.init(GameGlobals.dungeon.player)
	levelLabel.text = str("Level: ", GameGlobals.battleInstance.get_current_level(), "/", GameGlobals.dataManager.get_max_levels())
	playerSpecialUI.visible = true

func _on_new_level_loaded():
	levelLabel.text = str("Level: ", GameGlobals.battleInstance.get_current_level(), "/", GameGlobals.dataManager.get_max_levels())

func _on_turn_taken():
	turnLabel.text = str("Turns: ", GameGlobals.dungeon.turnsTaken)
	
func _on_attack(attacker, defender, damage):
	detailsLabel.text = str(attacker.displayName, " attacked ", defender.displayName, " for ", damage, " damage")
	
func _on_kill(attacker, defender, _finalDmg):
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
		pass
		#var newCharUI = CharacterUI.instance()
		#infoPanel.add_child(newCharUI)
		#infoPanelObjects.append(newCharUI)
		#newCharUI.init(entity)
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
	touchControls.visible = false
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

	playerSpecialUI.visible = false

# INFO UI
func _on_show_info(title:String, content:String):
	infoUI.showUI(title, content)
	
func _on_hide_info():
	infoUI.hideUI()

# TOUCH BUTTON UI
func _setup_touch_buttons():
	leftArrowBtn.connect("pressed", self, "_on_left_touch_pressed")
	upArrowBtn.connect("pressed", self, "_on_up_touch_pressed")
	rightArrowBtn.connect("pressed", self, "_on_right_touch_pressed")
	downArrowBtn.connect("pressed", self, "_on_down_touch_pressed")
	skipTurnBtn.connect("pressed", self, "_on_skip_turn_pressed")

func _on_left_touch_pressed():
	CombatEventManager.on_touch_button_pressed(0)

func _on_up_touch_pressed():
	CombatEventManager.on_touch_button_pressed(1)

func _on_right_touch_pressed():
	CombatEventManager.on_touch_button_pressed(2)

func _on_down_touch_pressed():
	CombatEventManager.on_touch_button_pressed(3)
	
func _on_skip_turn_pressed():
	CombatEventManager.on_skip_turn_pressed()
