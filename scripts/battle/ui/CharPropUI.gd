extends Node2D

class_name CharPropUI

onready var attackPanel:Sprite = $Attack
onready var attackLabel:Label = $Attack/AttackLabel
onready var healthPanel:Sprite = $Health
onready var healthLabel:Label = $Health/HealthLabel

var parentCharacter:Character

var prevDamageVal:int
var prevHealthVal:int

func _ready():
	get_parent().connect("OnInitialized", self, "init_parent_char")

func init_parent_char():
	parentCharacter = get_parent()
	_update_stats()
	
	parentCharacter.connect("OnStatChanged", self, "_on_char_stat_changed")

func _on_char_stat_changed(statChangeChar):
	if parentCharacter==statChangeChar:
		_update_stats()

func _update_stats():
	update_attack(parentCharacter.get_damage())
	update_health(parentCharacter.get_health())

func update_attack(val:int):
	if prevDamageVal!=val:
		attackLabel.text = str(val)
		animate_panel(attackPanel, attackLabel, val)
	prevDamageVal = val
	
func update_health(val:int):
	if prevHealthVal!=val:
		healthLabel.text = str(val)
		animate_panel(healthPanel, healthLabel, val)
	prevHealthVal = val

func animate_panel(panel, label, newVal):
	var startScale:Vector2 = Vector2(0.5, 0.5)
	var endScale:Vector2 = Vector2(0.8, 0.8)
	Utils.create_return_tween_vector2(panel, "scale", startScale, endScale, 0.15, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR, 0.5)
	yield(get_tree().create_timer(0.15), "timeout")
	#label.color = Color.green
	label.text = str(newVal)
	yield(get_tree().create_timer(0.5), "timeout")
	#label.color = Color.white

func on_mouse_entered():
	var desc:String = parentCharacter.charData.get_description() + " " + parentCharacter.get_summary()
	CombatEventManager.on_show_info(parentCharacter.charData.get_display_name(), desc)

func on_mouse_exited():
	CombatEventManager.on_hide_info()
