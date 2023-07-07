extends Control

class_name PlayerSpecialAbilityUI

@onready var SpecialProgressBar:ProgressBar = $"%PlayerAbilityProgressBar"
@onready var SpecialActiveButton:Button = $"%PlayerAbilityActiveButton"
@onready var SpecialPassiveButton:Button = $"%PlayerAbilityPassiveButton"
@onready var ResourceContainer:GridContainer = $"%ResourceContainer"
const ResourceSlotUI := preload("res://ui/battle/ResourceSlotUI.tscn")
var resourceSlots:Array = []

func _ready():
	self.visible = false
	SpecialProgressBar.value = 0
	SpecialActiveButton.disabled = true
	SpecialActiveButton.connect("pressed",Callable(self,"_on_special_pressed"))
	SpecialActiveButton.connect("mouse_entered",Callable(self,"_on_mouse_entered_active"))
	SpecialActiveButton.connect("mouse_exited",Callable(self,"_on_mouse_exited_active"))
	
	#SpecialPassiveButton.disabled = true
	SpecialPassiveButton.connect("mouse_entered",Callable(self,"_on_mouse_entered_passive"))
	SpecialPassiveButton.connect("mouse_exited",Callable(self,"_on_mouse_exited_passive"))
	
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnCleanUpForDungeonRecreation",Callable(self,"_on_cleanup_for_dungeon"))

func _on_dungeon_init():
	_init_resource_slots()
	GameGlobals.dungeon.player.special.connect("OnProgress",Callable(self,"_on_ability_progress"))
	GameGlobals.dungeon.player.special.connect("OnReady",Callable(self,"_on_ability_ready"))
	GameGlobals.dungeon.player.special.connect("OnReset",Callable(self,"_on_ability_reset"))

func _on_ability_progress(percent:float):
	SpecialProgressBar.value = percent * 100

func _on_ability_ready():
	SpecialActiveButton.disabled = false

func _on_ability_reset():
	SpecialProgressBar.value = 0
	SpecialActiveButton.disabled = true

func _on_special_pressed():
	CombatEventManager.on_player_special_ability_pressed()

func _on_mouse_entered_active():
	CombatEventManager.on_show_info("Special", GameGlobals.dungeon.player.special.data.description)

func _on_mouse_exited_active():
	CombatEventManager.on_hide_info()

func _on_mouse_entered_passive():
	CombatEventManager.on_show_info("Trait", GameGlobals.dungeon.player.specialPassive.data.description)

func _on_mouse_exited_passive():
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
	resourceSlot.self_modulate = Color.GRAY

func _refresh_resources():
	var currentEnergy:int = GameGlobals.dungeon.player.get_energy()
	var maxEnergy:int = GameGlobals.dungeon.player.get_max_energy()

	if resourceSlots.size() != maxEnergy:
		_clean_up_resource_slots()
		_create_all_resource_slots()

	#var startScale:Vector2 = Vector2(1, 1)
	#var endScale:Vector2 = Vector2(1.5, 1.5)
	for i in maxEnergy:
		if currentEnergy<=i:
			resourceSlots[i].self_modulate = Color.GRAY
		else:
			#Utils.create_tween_vector2(resourceSlots[i], "self_modulate", Color.WHITE, Color.GREEN, 0.1, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
			resourceSlots[i].self_modulate = Color.GREEN

func _on_player_resource_updated():
	_refresh_resources()

func _clean_up_resource_slots():
	for resourceSlot in resourceSlots:
		resourceSlot.queue_free()
	resourceSlots.clear()
