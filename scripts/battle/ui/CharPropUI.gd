extends Node2D

class_name CharPropUI

@onready var attackPanel:Sprite2D = $Attack
@onready var attackLabel:Label = $Attack/AttackLabel
@onready var healthPanel:Sprite2D = $Health
@onready var healthLabel:Label = $Health/HealthLabel

var parentCharacter:Character

var prevDamageVal:int
var prevHealthVal:int

func _ready():
	get_parent().connect("OnInitialized",Callable(self,"init_parent_char"))

func init_parent_char():
	parentCharacter = get_parent()
	_update_stats()
	
	parentCharacter.connect("OnStatChanged",Callable(self,"_on_char_stat_changed"))
	parentCharacter.connect("OnDeath",Callable(self,"_on_char_death"))
	parentCharacter.connect("OnReviveStart",Callable(self,"_on_char_revive_start"))
	parentCharacter.connect("OnReviveEnd",Callable(self,"_on_char_revive_end"))
	parentCharacter.connect("HideCharacterUI",Callable(self,"_hide_ui"))

func _on_char_stat_changed(statChangeChar):
	if parentCharacter==statChangeChar:
		_update_stats()

func _on_char_death():
	self.visible = false

func _on_char_revive_start():
	self.visible = false

func _on_char_revive_end():
	self.visible = true

func _update_stats():
	update_attack(parentCharacter.get_damage(), parentCharacter.stat_compare(StatData.STAT_TYPE.DAMAGE), attackPanel, attackLabel)
	update_health(parentCharacter.get_health(), parentCharacter.stat_compare(StatData.STAT_TYPE.HEALTH), healthPanel, healthLabel)

func update_attack(val:int, compareWithMax:int, panel, label):
	if prevDamageVal!=val:
		label.text = str(val)
		animate_panel(panel, label, val)
	prevDamageVal = val
	_update_stat_color(label, compareWithMax)
	
func update_health(val:int, compareWithMax:int, panel, label):
	if prevHealthVal!=val:
		label.text = str(val)
		animate_panel(panel, label, val)
	prevHealthVal = val
	_update_stat_color(label, compareWithMax)

func _update_stat_color(label, compareWithMax):
	if compareWithMax==0:
		label.self_modulate = Color.WHITE
	elif compareWithMax==-1:
		label.self_modulate = Color.INDIAN_RED
	elif compareWithMax==1:
		label.self_modulate = Color.LAWN_GREEN

func animate_panel(panel, label, newVal):
	var startScale:Vector2 = Vector2(0.5, 0.5)
	var endScale:Vector2 = Vector2(0.8, 0.8)
	Utils.create_return_tween_vector2(panel, "scale", startScale, endScale, 0.15, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR, 0.5)
	await get_tree().create_timer(0.15).timeout
	label.text = str(newVal)
	await get_tree().create_timer(0.5).timeout

func on_mouse_entered():
	var desc:String = parentCharacter.charData.get_description() + " " + parentCharacter.get_summary()
	CombatEventManager.on_show_info(parentCharacter.charData.get_display_name(), desc)

func on_mouse_exited():
	CombatEventManager.on_hide_info()

func _hide_ui(hideVal:bool):
	self.visible = !hideVal
