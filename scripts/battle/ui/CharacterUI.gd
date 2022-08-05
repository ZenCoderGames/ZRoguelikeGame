extends Node

class_name CharacterUI

onready var baseContainer:PanelContainer = get_node(".")
onready var listContainer:VBoxContainer = get_node("VBoxContainer")
onready var nameBg:ColorRect = get_node("VBoxContainer/Name/Bg")
onready var nameLabel:Label = get_node("VBoxContainer/Name/NameLabel")
onready var healthBar:ColorRect = get_node("VBoxContainer/Health/HealthBar")
onready var healthLabel:Label = get_node("VBoxContainer/Health/HealthLabel")
onready var descLabel:Label = get_node("VBoxContainer/Damage/DescLabel")

const EquippedItemUI := preload("res://ui/battle/EquippedItemUI.tscn")

export var playerTintColor:Color
export var enemyTintColor:Color

export var baseContainerFlashColor:Color
export var healthBarFlashColor:Color

var originalHealthRect
var originalHealthBarColor:Color
var character:Character

func _ready():
	originalHealthRect = healthBar.rect_size
	originalHealthBarColor = healthBar.color

func init(entityObj):
	character = entityObj as Character
	nameLabel.text = character.displayName
	descLabel.text = str("Damage: ", character.get_damage())
	character.connect("OnStatChanged", self, "_on_stat_changed")
	character.connect("OnItemEquipped", self, "_on_item_equipped")
	if character.team == Constants.TEAM.PLAYER:
		nameBg.color = playerTintColor
	elif character.team == Constants.TEAM.ENEMY:
		nameBg.color = enemyTintColor
	_update_ui()

func _on_stat_changed(characterRef):
	baseContainer.self_modulate = baseContainerFlashColor
	healthBar.color = healthBarFlashColor
	yield(get_tree().create_timer(0.075), "timeout")
	_update_ui()
	healthBar.color = originalHealthBarColor
	baseContainer.self_modulate = Color.white
	
func _on_item_equipped(item):
	var newItemUI = EquippedItemUI.instance()
	listContainer.add_child(newItemUI)
	newItemUI.init(item)
	_update_ui()
	
func _update_ui():
	healthLabel.text = str("Health: ", character.get_health(), "/", character.get_max_health())
	var pctHealth:float = float(character.get_health())/float(character.get_max_health())
	healthBar.rect_size = Vector2(pctHealth * originalHealthRect.x, originalHealthRect.y)
	descLabel.text = str("Damage: ", character.get_damage())
	
func has_entity(entity):
	return character == entity
