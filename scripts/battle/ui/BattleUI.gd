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
@onready var zoomInBtn:Button = $TouchControls/ZoomIn
@onready var zoomOutBtn:Button = $TouchControls/ZoomOut
# details
@onready var detailsUI:Node = get_node("DetailsUI")
@onready var detailsLabel:RichTextLabel = $"%DetailsLabel"
# player xp/equipment
@onready var playerPanel:Node = get_node("PlayerPanel")
var playerUI:CharacterUI
# info panel
@onready var infoPanel:Node = get_node("InfoPanel")
var infoPanelObjects:Array = []
var registeredEnemies:Dictionary = {}
# level up
var levelUpUI:LevelUpUI
const LevelUpUI := preload("res://ui/battle/LevelUpUI.tscn")
const CharacterUI := preload("res://ui/battle/CharacterUI.tscn")
const ItemUI := preload("res://ui/battle/ItemUI.tscn")
# vendor
var vendorUI:VendorUI
const VendorUI := preload("res://ui/battle/VendorUI.tscn")
var vendorDict:Dictionary = {}
# inventory UI
const InventoryUI := preload("res://ui/battle/InventoryUI.tscn")
var inventoryUI:InventoryUI = null
# info UI
const InfoUI := preload("res://ui/battle/InfoUI.tscn")
var infoUI:InfoUI = null
# special UI
@onready var playerAbilitiesListUI:Node = $"%PlayerAbilities"
const SpecialAbilityUI := preload("res://ui/battle/PlayerAbilityUI.tscn")
var _playerAbilityList:Array

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
	CombatEventManager.connect("OnLevelUpAbilitySelected",Callable(self,"_on_levelup_ability_selected"))
	CombatEventManager.connect("ShowUpgrade",Callable(self,"_on_show_upgrade"))
	CombatEventManager.connect("ShowVendor",Callable(self,"_on_show_vendor"))
	CombatEventManager.connect("OnVendorClosed",Callable(self,"_on_vendor_closed"))
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
	GameGlobals.dungeon.player.connect("OnSpecialAdded",Callable(self,"_on_player_special_added"))
	#GameGlobals.dungeon.player.connect("OnLevelUp",Callable(self,"_on_show_upgrade"))
	
	#await get_tree().create_timer(0.1).timeout

	playerUI.init(GameGlobals.dungeon.player)
	levelLabel.text = str(GameGlobals.battleInstance.get_current_level(), "/", GameGlobals.dataManager.get_max_levels())

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
	_show_detail_info_text(str(attacker.displayName, " attacked ", defender.displayName, " for ", damage, " damage"), 3)
	
func _on_kill(attacker, defender, _finalDmg):
	# Info panel
	_info_panel_handle_death(defender)
	
	# Details panel
	_show_detail_info_text(str(attacker.displayName, " killed ", defender.displayName), 5)
	
func _on_item_picked_by_player(item):
	_show_detail_info_text(str(item.data.name, " picked up "), 5)

func _show_detail_info_text(strVal, duration):
	detailsUI.visible = true
	detailsLabel.text = Utils.format_text(strVal)
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
	elif entity is Item or entity is Upgrade or entity is VendorCharacter or entity is TutorialPickup:
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
	zoomInBtn.connect("pressed",Callable(self,"_on_zoom_in_pressed"))
	zoomOutBtn.connect("pressed",Callable(self,"_on_zoom_out_pressed"))

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

func _on_zoom_in_pressed():
	CombatEventManager.emit_signal("OnZoomIn")

func _on_zoom_out_pressed():
	CombatEventManager.emit_signal("OnZoomOut")

func _on_cleanup_for_dungeon(fullRefreshDungeon:bool=true):
	if fullRefreshDungeon:
		_clean_up()
		var player = GameGlobals.dungeon.player
		if player!=null and !player.is_queued_for_deletion():
			player.disconnect("OnCharacterMoveToCell",Callable(self,"_on_player_move"))
			player.disconnect("OnNearbyEntityFound",Callable(self,"_on_entity_nearby"))
			player.inventory.disconnect("OnItemAdded",Callable(self,"_on_item_picked_by_player"))

		for playerAbilityUI in _playerAbilityList:
			playerAbilityUI._cleanup()
			playerAbilitiesListUI.remove_child(playerAbilityUI)
		_playerAbilityList.clear()

# LEVEL UP
func _on_show_upgrade(upgradeType:Upgrade.UPGRADE_TYPE):
	levelUpUI = LevelUpUI.instantiate()
	add_child(levelUpUI)

	var hasALevelUpItem:bool = levelUpUI.init_from_data(upgradeType)
	if !hasALevelUpItem:
		_remove_level_up_ui()
	else:
		UIEventManager.emit_signal("OnSelectionMenuOn")

func _on_levelup_ability_selected(_abilityData:AbilityData):
	_remove_level_up_ui()

func _remove_level_up_ui():
	remove_child(levelUpUI)
	levelUpUI.queue_free()
	levelUpUI = null
	UIEventManager.emit_signal("OnSelectionMenuOff")

# VENDOR
func _on_show_vendor(vendorChar:VendorCharacter, vendorData:VendorData):
	if vendorDict.has(vendorChar):
		vendorUI = vendorDict[vendorChar]
	else:
		vendorUI = VendorUI.instantiate()
		vendorDict[vendorChar] = vendorUI
	add_child(vendorUI)
	vendorUI.init(vendorChar, vendorData)
	UIEventManager.emit_signal("OnSelectionMenuOn")
	GameGlobals.dungeon.inBackableMenu = true

func _on_vendor_closed():
	remove_child(vendorUI)
	#vendorUI.queue_free()
	vendorUI = null
	UIEventManager.emit_signal("OnSelectionMenuOff")
	GameGlobals.dungeon.inBackableMenu = false

# SPECIALS
func _on_player_special_added(character:Character, special:Special):
	var playerSpecialAbilityUI:PlayerSpecialAbilityUI = SpecialAbilityUI.instantiate()
	playerAbilitiesListUI.add_child(playerSpecialAbilityUI)
	_playerAbilityList.append(playerSpecialAbilityUI)
	playerSpecialAbilityUI.init(character, special)
