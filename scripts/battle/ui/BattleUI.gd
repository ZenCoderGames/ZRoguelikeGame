extends Node

class_name BattleUI

@onready var levelLabel:Label = get_node("BattleProgressPanel/LevelContainer/LevelLabel")
@onready var turnLabel:Label = get_node("BattleProgressPanel/TurnContainer/TurnLabel")
# touchControls
@onready var touchControls:Node = $TouchControls
@onready var upArrowBtn:Button = $TouchControls/UpArrow
@onready var downArrowBtn:Button = $TouchControls/DownArrow
@onready var leftArrowBtn:Button = $TouchControls/LeftArrow
@onready var rightArrowBtn:Button = $TouchControls/RightArrow
@onready var skipTurnBtn:Button = $TouchControls/SkipTurn
# details
@onready var detailsUI:Node = get_node("DetailsUI")
@onready var detailsLabel:Label = get_node("DetailsUI/DetailsLabel")
# player xp/equipment
@onready var playerPanel:Node = get_node("PlayerPanel")
var playerUI:CharacterUI
# player ability
@onready var playerSpecialUI:Node = get_node("PlayerAbilityPanel")
# info panel
@onready var infoPanel:Node = get_node("InfoPanel")
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

const SKIP_TURN_COLOR:Color = Color("#74a09c9c")
const SKIP_TURN_DISABLED_COLOR:Color = Color("#800000")

func _ready():
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnCleanUpForDungeonRecreation",Callable(self,"_on_cleanup_for_dungeon"))
	GameEventManager.connect("OnNewLevelLoaded",Callable(self,"_on_new_level_loaded"))
	CombatEventManager.connect("OnToggleInventory",Callable(self,"_on_toggle_inventory"))
	CombatEventManager.connect("OnShowInfo",Callable(self,"_on_show_info"))
	CombatEventManager.connect("OnHideInfo",Callable(self,"_on_hide_info"))
	CombatEventManager.connect("OnEndTurn",Callable(self,"_on_turn_taken"))
	CombatEventManager.connect("OnDetailInfoShow",Callable(self,"_show_detail_info_text"))
	HitResolutionManager.connect("OnPostHit",Callable(self,"_on_attack"))
	HitResolutionManager.connect("OnKill",Callable(self,"_on_kill"))

	inventoryUI = InventoryUI.instantiate()
	self.add_child(inventoryUI)
	
	infoUI = InfoUI.instantiate()
	self.add_child(infoUI)
	infoUI.hide()
	
	_setup_touch_buttons()
	
func _on_dungeon_init():
	_shared_init()

func _shared_init():
	touchControls.visible = true
	
	playerUI = CharacterUI.instantiate()
	playerPanel.add_child(playerUI)

	inventoryUI.init(GameGlobals.dungeon.player)
	
	GameGlobals.dungeon.player.connect("OnCharacterMoveToCell",Callable(self,"_on_player_move"))
	GameGlobals.dungeon.player.connect("OnNearbyEntityFound",Callable(self,"_on_entity_nearby"))
	GameGlobals.dungeon.player.inventory.connect("OnItemAdded",Callable(self,"_on_item_picked_by_player"))
	
	playerUI.init(GameGlobals.dungeon.player)
	levelLabel.text = str(GameGlobals.battleInstance.get_current_level(), "/", GameGlobals.dataManager.get_max_levels())
	playerSpecialUI.visible = true

func _on_new_level_loaded():
	levelLabel.text = str(GameGlobals.battleInstance.get_current_level(), "/", GameGlobals.dataManager.get_max_levels())

func _on_turn_taken():
	_refresh_ui()

func _refresh_ui():
	turnLabel.text = str(GameGlobals.dungeon.turnsTaken)
	if GameGlobals.dungeon.player.can_skip_turn():
		skipTurnBtn.self_modulate = SKIP_TURN_COLOR
	else:
		skipTurnBtn.self_modulate = SKIP_TURN_DISABLED_COLOR
	
func _on_attack(attacker, defender, damage):
	detailsLabel.text = str(attacker.displayName, " attacked ", defender.displayName, " for ", damage, " damage")
	
func _on_kill(attacker, defender, _finalDmg):
	# Info panel
	_info_panel_handle_death(defender)
	
	# Details panel
	_show_detail_info_text(str(attacker.displayName, " killed ", defender.displayName), 1)
	
func _on_item_picked_by_player(item):
	_show_detail_info_text(str(item.data.displayName, " picked up "), 1)

func _show_detail_info_text(strVal, duration):
	detailsUI.visible = true
	detailsLabel.text = strVal
	await get_tree().create_timer(duration).timeout
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
		#var newCharUI = CharacterUI.instantiate()
		#infoPanel.add_child(newCharUI)
		#infoPanelObjects.append(newCharUI)
		#newCharUI.init(entity)
	elif entity is Item:
		var newItemUI = ItemUI.instantiate()
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
	if playerUI!=null:
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
	if inventoryUI!=null:
		inventoryUI.clean_up()

	playerSpecialUI.visible = false

# INFO UI
func _on_show_info(title:String, content:String):
	infoUI.showUI(title, content)
	
func _on_hide_info():
	infoUI.hideUI()

# TOUCH BUTTON UI
func _setup_touch_buttons():
	leftArrowBtn.connect("pressed",Callable(self,"_on_left_touch_pressed"))
	upArrowBtn.connect("pressed",Callable(self,"_on_up_touch_pressed"))
	rightArrowBtn.connect("pressed",Callable(self,"_on_right_touch_pressed"))
	downArrowBtn.connect("pressed",Callable(self,"_on_down_touch_pressed"))
	skipTurnBtn.connect("pressed",Callable(self,"_on_skip_turn_pressed"))

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
	_refresh_ui()

func _on_cleanup_for_dungeon(fullRefreshDungeon:bool=true):
	if fullRefreshDungeon:
		_clean_up()
		var player = GameGlobals.dungeon.player
		if player!=null and !player.is_queued_for_deletion():
			player.disconnect("OnCharacterMoveToCell",Callable(self,"_on_player_move"))
			player.disconnect("OnNearbyEntityFound",Callable(self,"_on_entity_nearby"))
			player.inventory.disconnect("OnItemAdded",Callable(self,"_on_item_picked_by_player"))
