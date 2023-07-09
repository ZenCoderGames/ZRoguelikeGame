extends PanelContainer

class_name PlayerSpecialAbilityUI

@onready var SpecialProgressBar:ProgressBar = $"%PlayerAbilityProgressBar"
@onready var SpecialActiveButton:Button = $"%PlayerAbilityActiveButton"
@onready var ResourceContainer:GridContainer = $"%ResourceContainer"
const ResourceSlotUI := preload("res://ui/battle/ResourceSlotUI.tscn")
var resourceSlots:Array = []

func _ready():
	self.visible = false
	SpecialActiveButton.disabled = true
	SpecialActiveButton.connect("pressed",Callable(self,"_on_special_pressed"))
	SpecialActiveButton.connect("mouse_entered",Callable(self,"_on_mouse_entered_active"))
	SpecialActiveButton.connect("mouse_exited",Callable(self,"_on_mouse_exited_active"))
	
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnCleanUpForDungeonRecreation",Callable(self,"_on_cleanup_for_dungeon"))

func _on_dungeon_init():
	SpecialActiveButton.disabled = true
	_init_resource_slots()
	GameGlobals.dungeon.player.special.connect("OnReady",Callable(self,"_on_ability_ready"))
	GameGlobals.dungeon.player.special.connect("OnReset",Callable(self,"_on_ability_reset"))
	GameGlobals.dungeon.player.connect("OnSpecialModifierAdded",Callable(self,"_on_player_resource_updated"))
	GameGlobals.dungeon.player.connect("OnSpecialModifierRemoved",Callable(self,"_on_player_resource_updated"))

func _on_ability_ready():
	SpecialActiveButton.disabled = false

func _on_ability_reset():
	SpecialActiveButton.disabled = true

func _on_special_pressed():
	CombatEventManager.on_player_special_ability_pressed()

func _on_mouse_entered_active():
	CombatEventManager.on_show_info("Special", GameGlobals.dungeon.player.special.data.description)

func _on_mouse_exited_active():
	CombatEventManager.on_hide_info()

func _on_cleanup_for_dungeon(fullRefreshDungeon:bool=true):
	if fullRefreshDungeon:
		_clean_up_resource_slots()

# RESOURCES
func _init_resource_slots():
	_create_all_resource_slots()
	#GameGlobals.dungeon.player.connect("OnResourceStatChanged", Callable(self,"_on_player_resource_updated"))
	GameGlobals.dungeon.player.get_stat(StatData.STAT_TYPE.ENERGY).connect("OnUpdated",Callable(self,"_on_player_resource_updated"))

func _create_all_resource_slots():
	var maxEnergy:int = GameGlobals.dungeon.player.get_max_energy()
	for i in maxEnergy:
		_create_resource_slot()
	_refresh_resources()

func _create_resource_slot():
	var resourceSlot := ResourceSlotUI.instantiate()
	ResourceContainer.add_child(resourceSlot)
	resourceSlots.append(resourceSlot)

func _refresh_resources():
	var currentEnergy:int = GameGlobals.dungeon.player.get_energy()
	var maxEnergy:int = GameGlobals.dungeon.player.get_max_energy()
	var maxSpecialCount:int = GameGlobals.dungeon.player.special.get_max_count()

	if resourceSlots.size() != maxEnergy:
		_clean_up_resource_slots()
		_create_all_resource_slots()

	for i in maxEnergy:
		resourceSlots[i].clear()
		if i<maxSpecialCount:
			resourceSlots[i].set_as_special_count()
		if currentEnergy<=i:
			resourceSlots[i].set_empty()
		else:
			resourceSlots[i].set_filled()

func _on_player_resource_updated():
	_refresh_resources()

func _clean_up_resource_slots():
	for resourceSlot in resourceSlots:
		resourceSlot.queue_free()
	resourceSlots.clear()
