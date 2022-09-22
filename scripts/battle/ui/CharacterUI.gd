extends Node

class_name CharacterUI

onready var baseContainer:PanelContainer = get_node(".")
onready var listContainer:VBoxContainer = get_node("HSplitContainer/Base")
onready var nameBg:ColorRect = get_node("HSplitContainer/Base/Name/Bg")
onready var nameLabel:Label = get_node("HSplitContainer/Base/Name/NameLabel")
onready var xpUI:PanelContainer = get_node("HSplitContainer/Base/XP")
onready var xpBar:ProgressBar = get_node("HSplitContainer/Base/XP/XPBar")
onready var levelUpBar:ProgressBar = get_node("HSplitContainer/Base/XP/LevelUpBar")
onready var xpLabel:Label = get_node("HSplitContainer/Base/XP/XPLabel")
onready var healthBar:ProgressBar = get_node("HSplitContainer/Base/Health/HealthBar")
onready var healthLabel:Label = get_node("HSplitContainer/Base/Health/HealthLabel")
onready var descLabel:Label = get_node("HSplitContainer/Base/Damage/DescLabel")
const EquippedItemUI := preload("res://ui/battle/EquippedItemUI.tscn")

onready var nonBaseContainer:HSplitContainer = get_node("HSplitContainer/NonBase")

onready var spellContainer:VBoxContainer = get_node("HSplitContainer/NonBase/SpellContainer")
const SpellButtonUI := preload("res://ui/battle/SpellButtonUI.tscn")

onready var effectContainer:VBoxContainer = get_node("HSplitContainer/NonBase/EffectContainer")
const EffectItemUI := preload("res://ui/battle/EffectItemUI.tscn")

export var playerTintColor:Color
export var enemyTintColor:Color

export var baseContainerFlashColor:Color
export var healthBarFlashColor:Color

var originalHealthBarColor:Color
var character:Character

var equippedItems:Dictionary = {}
var equippedSpells:Dictionary = {}
var equippedEffects:Dictionary = {}

var isPlayer:bool

var xpTween:Tween = null

func _ready():
	originalHealthBarColor = healthBar.self_modulate

func init(entityObj):
	character = entityObj as Character
	nameLabel.text = character.displayName
	descLabel.text = str("Damage: ", character.get_damage())
	character.connect("OnStatChanged", self, "_on_stat_changed")
	character.connect("OnPassiveAdded", self, "on_passive_added")
	character.connect("OnPassiveRemoved", self, "on_passive_removed")
	character.connect("OnStatusEffectAdded", self, "on_status_effect_added")
	character.connect("OnStatusEffectRemoved", self, "on_status_effect_removed")
	character.equipment.connect("OnItemEquipped", self, "_on_item_equipped")
	character.equipment.connect("OnItemUnEquipped", self, "_on_item_unequipped")
	character.equipment.connect("OnSpellEquipped", self, "_on_spell_equipped")
	character.equipment.connect("OnSpellUnEquipped", self, "_on_spell_unequipped")
	character.equipment.connect("OnSpellActivated", self, "_on_spell_activated")
	if character.team == Constants.TEAM.PLAYER:
		nameBg.color = playerTintColor
		isPlayer = true
		xpUI.visible = true
		var playerChar:PlayerCharacter = character as PlayerCharacter
		playerChar.connect("OnXPGained", self, "_update_base_ui")
		playerChar.connect("OnLevelUp", self, "_show_level_up")
	elif character.team == Constants.TEAM.ENEMY:
		nameBg.color = enemyTintColor
		xpUI.visible = false
	_update_base_ui()

func _on_stat_changed(characterRef):
	baseContainer.self_modulate = baseContainerFlashColor
	healthBar.self_modulate = healthBarFlashColor
	if get_tree()!=null:
		yield(get_tree().create_timer(0.075), "timeout")
	_update_base_ui()
	healthBar.self_modulate = originalHealthBarColor
	baseContainer.self_modulate = Color.white
	
func _update_base_ui():
	if inLevelUpSequence:
		return
	healthLabel.text = str("Health: ", character.get_health(), "/", character.get_max_health())
	var pctHealth:float = float(character.get_health())/float(character.get_max_health())
	healthBar.value = pctHealth * 100
	descLabel.text = str("Damage: ", character.get_damage())
	if isPlayer:
		var playerChar:PlayerCharacter = character as PlayerCharacter
		nameLabel.text = str(character.displayName, " (Lvl ", playerChar.get_level()+1, ")")
		var xpToLevelUp:float = float(playerChar.get_xp_to_level_xp())
		if playerChar.is_at_max_level():
			xpLabel.text = "Max Level"
		else:
			xpLabel.text = str("Xp: ", playerChar.get_xp_from_current_level(), "/", playerChar.get_xp_to_level_xp())
		var pctXP:float = 1
		if xpToLevelUp>0:
			pctXP = float(playerChar.get_xp_from_current_level())/xpToLevelUp
		#xpBar.value = pctXP * 100
		xpTween = Utils.create_tween_float(xpBar, "value", xpBar.value, pctXP * 100, 0.25, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	
var inLevelUpSequence:bool
func _show_level_up():
	inLevelUpSequence = true
	if xpTween!=null:
		xpTween.stop_all()
	levelUpBar.visible = true
	xpLabel.text = "Level Up!"
	if get_tree()!=null:
		yield(get_tree().create_timer(1.0), "timeout") 
	levelUpBar.visible = false
	inLevelUpSequence = false
	_update_base_ui()

# ITEMS
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

# SPELLS
func _on_spell_equipped(spellItem):
	var newSpellUI = SpellButtonUI.instance()
	spellContainer.add_child(newSpellUI)
	newSpellUI.text = spellItem.get_display_name()
	equippedSpells[spellItem] = newSpellUI

	newSpellUI.connect("pressed", self, "_on_equip_spell_selected", [spellItem])
	
	spellContainer.visible = true
	_update_non_base_ui()

func _on_spell_unequipped(spellItem):
	if equippedSpells.has(spellItem):
		spellContainer.remove_child(equippedSpells[spellItem])
		equippedSpells.erase(spellItem)
		
	if equippedSpells.size()==0:
		spellContainer.visible = false
		
	_update_non_base_ui()

func _on_equip_spell_selected(spellItem):
	if spellItem.can_activate():
		character.equipment.activate_spell(spellItem)

func _on_spell_activated(spellItem):
	_on_spell_unequipped(spellItem)

# EFFECTS
func on_passive_added(character, passive):
	var newEffectUI = EffectItemUI.instance()
	effectContainer.add_child(newEffectUI)
	newEffectUI.get_child(0).text = passive.data.get_display_name()
	equippedEffects[passive] = newEffectUI

	effectContainer.visible = true
	_update_non_base_ui()

func on_passive_removed(character, passive):
	if equippedEffects.has(passive):
		effectContainer.remove_child(equippedEffects[passive])
		equippedEffects.erase(passive)
		
	if equippedEffects.size()==0:
		effectContainer.visible = false
		
	_update_non_base_ui()

func on_status_effect_added(character, statusEffect):
	var newEffectUI = EffectItemUI.instance()
	effectContainer.add_child(newEffectUI)
	newEffectUI.get_node("NameLabel").text = statusEffect.data.get_display_name()
	equippedEffects[statusEffect] = newEffectUI

	effectContainer.visible = true
	_update_non_base_ui()

func on_status_effect_removed(character, statusEffect):
	if equippedEffects.has(statusEffect):
		effectContainer.remove_child(equippedEffects[statusEffect])
		equippedEffects.erase(statusEffect)
		
	if equippedEffects.size()==0:
		effectContainer.visible = false
		
	_update_non_base_ui()

func _update_non_base_ui():
	nonBaseContainer.visible = equippedSpells.size()>0 or equippedEffects.size()>0
	
func has_entity(entity):
	return character == entity
