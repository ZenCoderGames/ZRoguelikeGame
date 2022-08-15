extends Node

class_name CharacterUI

onready var baseContainer:PanelContainer = get_node(".")
onready var listContainer:VBoxContainer = get_node("HSplitContainer/VBoxContainer")
onready var nameBg:ColorRect = get_node("HSplitContainer/VBoxContainer/Name/Bg")
onready var nameLabel:Label = get_node("HSplitContainer/VBoxContainer/Name/NameLabel")
onready var healthBar:ProgressBar = get_node("HSplitContainer/VBoxContainer/Health/HealthBar")
onready var healthLabel:Label = get_node("HSplitContainer/VBoxContainer/Health/HealthLabel")
onready var descLabel:Label = get_node("HSplitContainer/VBoxContainer/Damage/DescLabel")
const EquippedItemUI := preload("res://ui/battle/EquippedItemUI.tscn")

onready var spellContainer:VBoxContainer = get_node("HSplitContainer/SpellContainer")
const SpellButtonUI := preload("res://ui/battle/SpellButtonUI.tscn")

export var playerTintColor:Color
export var enemyTintColor:Color

export var baseContainerFlashColor:Color
export var healthBarFlashColor:Color

var originalHealthBarColor:Color
var character:Character

var equippedItems:Dictionary = {}
var equippedSpells:Dictionary = {}

func _ready():
	originalHealthBarColor = healthBar.self_modulate

func init(entityObj):
	character = entityObj as Character
	nameLabel.text = character.displayName
	descLabel.text = str("Damage: ", character.get_damage())
	character.connect("OnStatChanged", self, "_on_stat_changed")
	character.equipment.connect("OnItemEquipped", self, "_on_item_equipped")
	character.equipment.connect("OnItemUnEquipped", self, "_on_item_unequipped")
	character.equipment.connect("OnSpellEquipped", self, "_on_spell_equipped")
	character.equipment.connect("OnSpellUnEquipped", self, "_on_spell_unequipped")
	character.equipment.connect("OnSpellActivated", self, "_on_spell_activated")
	if character.team == Constants.TEAM.PLAYER:
		nameBg.color = playerTintColor
	elif character.team == Constants.TEAM.ENEMY:
		nameBg.color = enemyTintColor
	_update_ui()

func _on_stat_changed(characterRef):
	baseContainer.self_modulate = baseContainerFlashColor
	healthBar.self_modulate = healthBarFlashColor
	yield(get_tree().create_timer(0.075), "timeout")
	_update_ui()
	healthBar.self_modulate = originalHealthBarColor
	baseContainer.self_modulate = Color.white
	
func _on_item_equipped(item):
	var newItemUI = EquippedItemUI.instance()
	listContainer.add_child(newItemUI)
	newItemUI.init(item)
	equippedItems[item] = newItemUI
	_on_stat_changed(character)

func _on_item_unequipped(item):
	if equippedItems.has(item):
		listContainer.remove_child(equippedItems[item])
		equippedItems.erase(item)
	_on_stat_changed(character)

func _on_spell_equipped(spellItem):
	var newSpellUI = SpellButtonUI.instance()
	spellContainer.add_child(newSpellUI)
	newSpellUI.text = spellItem.get_display_name()
	equippedSpells[spellItem] = newSpellUI

	newSpellUI.connect("pressed", self, "_on_equip_spell_selected", [spellItem])
	
	spellContainer.visible = true

func _on_spell_unequipped(spellItem):
	if equippedSpells.has(spellItem):
		spellContainer.remove_child(equippedSpells[spellItem])
		equippedSpells.erase(spellItem)
		
	if equippedSpells.size()==0:
		spellContainer.visible = false
	
func _on_equip_spell_selected(spellItem):
	character.equipment.activate_spell(spellItem)

func _on_spell_activated(spellItem):
	_on_spell_unequipped(spellItem)

func _update_ui():
	healthLabel.text = str("Health: ", character.get_health(), "/", character.get_max_health())
	var pctHealth:float = float(character.get_health())/float(character.get_max_health())
	healthBar.value = pctHealth * 100
	descLabel.text = str("Damage: ", character.get_damage())
	
func has_entity(entity):
	return character == entity
