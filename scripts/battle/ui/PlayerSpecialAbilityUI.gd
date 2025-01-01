extends PanelContainer

class_name PlayerSpecialAbilityUI

@onready var SpecialActiveButton:Button = $"%PlayerAbilityActiveButton"
@onready var ResourceContainer:GridContainer = $"%ResourceContainer"
const ResourceSlotUI := preload("res://ui/battle/ResourceSlotUI.tscn")
var resourceSlots:Array = []

var _parentChar:Character
var _special:Special

func init(parentChar:Character, special:Special):
	_parentChar = parentChar
	_special = special
	SpecialActiveButton.disabled = true
	_init_resource_slots()
	_special.connect("OnReady",Callable(self,"_on_ability_ready"))
	_special.connect("OnReset",Callable(self,"_on_ability_reset"))
	_special.connect("OnSpecialModifierAdded",Callable(self,"_on_player_resource_updated"))
	_special.connect("OnSpecialModifierRemoved",Callable(self,"_on_player_resource_updated"))
	self.connect("mouse_entered", Callable(self,"_on_mouse_entered"))
	SpecialActiveButton.connect("mouse_entered", Callable(self,"_on_mouse_entered"))
	self.connect("mouse_exited", Callable(self,"_on_mouse_exited"))
	SpecialActiveButton.connect("mouse_exited", Callable(self,"_on_mouse_exited"))
	SpecialActiveButton.connect("pressed", Callable(self,"_on_special_pressed"))
	CombatEventManager.connect("OnStartTurn",Callable(self,"_on_start_turn"))
	SpecialActiveButton.text = special.data.name

func _on_ability_ready(_specialVar:Special):
	_refresh_ui()

func _on_ability_reset(_specialVar:Special):
	_refresh_ui()

func _on_special_pressed():
	CombatEventManager.emit_signal("OnPlayerSpecialAbilityPressed", _special)
	_refresh_ui()

func _on_mouse_entered():
	CombatEventManager.on_show_info("Special", _special.data.description)

func _on_mouse_exited():
	CombatEventManager.on_hide_info()

func _cleanup():
	_clean_up_resource_slots()

	if _special!=null:
		_special.disconnect("OnReady",Callable(self,"_on_ability_ready"))
		_special.disconnect("OnReset",Callable(self,"_on_ability_reset"))
		_special.disconnect("OnSpecialModifierAdded",Callable(self,"_on_player_resource_updated"))
		_special.disconnect("OnSpecialModifierRemoved",Callable(self,"_on_player_resource_updated"))
	
	CombatEventManager.disconnect("OnStartTurn",Callable(self,"_on_start_turn"))

# RESOURCES
func _init_resource_slots():
	_create_all_resource_slots()
	_special.connect("OnCountUpdated",Callable(self,"_on_player_resource_updated"))
	_refresh_ui()

func _create_all_resource_slots():
	var maxEnergy:int = _special.get_max_count()
	for i in maxEnergy:
		_create_resource_slot()
	_refresh_resources()

func _create_resource_slot():
	var resourceSlot := ResourceSlotUI.instantiate()
	ResourceContainer.add_child(resourceSlot)
	resourceSlots.append(resourceSlot)

func _refresh_resources():
	var currentEnergy:int = _parentChar.get_energy()
	var maxEnergy:int = _special.get_max_count()

	if resourceSlots.size() != maxEnergy:
		_clean_up_resource_slots()
		_create_all_resource_slots()

	for i in maxEnergy:
		resourceSlots[i].clear()
		if currentEnergy<=i:
			resourceSlots[i].set_empty()
		else:
			resourceSlots[i].set_filled()

	_refresh_ui()

func _on_player_resource_updated(_character):
	_refresh_resources()

func _clean_up_resource_slots():
	for resourceSlot in resourceSlots:
		resourceSlot.queue_free()
	resourceSlots.clear()

# COOLDOWN
func _on_start_turn():
	_refresh_ui()

func _refresh_ui():
	if _special.InSelectionMode:
		SpecialActiveButton.disabled = true
		return
		
	var currentEnergy:int = _parentChar.get_energy()
	var maxEnergy:int = _special.get_max_count()
	var remainingCooldown:int = _special.get_remaining_cooldown()
	if remainingCooldown>0:
		SpecialActiveButton.text = _special.data.name + "\n(CD: " + str(remainingCooldown) + ")"
		SpecialActiveButton.disabled = true
	else:
		SpecialActiveButton.text = _special.data.name
		SpecialActiveButton.disabled = (currentEnergy < maxEnergy)
