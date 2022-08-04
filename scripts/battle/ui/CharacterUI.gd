extends Node

onready var baseContainer:PanelContainer = get_node(".")
onready var nameLabel:Label = get_node("VBoxContainer/PanelContainer/NameLabel")
onready var healthBar:ColorRect = get_node("VBoxContainer/PanelContainer3/HealthBar")
onready var healthLabel:Label = get_node("VBoxContainer/PanelContainer3/HealthLabel")
onready var descLabel:Label = get_node("VBoxContainer/PanelContainer2/DescLabel")

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
	_update_ui()

func _on_stat_changed(characterRef):
	baseContainer.self_modulate = baseContainerFlashColor
	healthBar.color = healthBarFlashColor
	yield(get_tree().create_timer(0.075), "timeout")
	_update_ui()
	healthBar.color = originalHealthBarColor
	baseContainer.self_modulate = Color.white
	
func _update_ui():
	healthLabel.text = str("Health: ", character.get_health())
	var pctHealth:float = float(character.get_health())/float(character.get_max_health())
	healthBar.rect_size = Vector2(pctHealth * originalHealthRect.x, originalHealthRect.y)

func has_entity(entity):
	return character == entity
