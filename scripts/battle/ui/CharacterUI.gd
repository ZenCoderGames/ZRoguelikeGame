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
var spellSlots:Array = []
var weaponSlot
var armorSlot
var runeSlots:Array = []

var isPlayer:bool

var xpTween:Tween = null

func init(entityObj):
	character = entityObj as Character
	#nameLabel.text = character.displayName
	#character.connect("OnStatChanged", self, "_on_stat_changed")
	character.connect("OnPassiveAdded", self, "on_passive_added")
	character.connect("OnPassiveRemoved", self, "on_passive_removed")
	character.connect("OnStatusEffectAdded", self, "on_status_effect_added")
	character.connect("OnStatusEffectRemoved", self, "on_status_effect_removed")
	character.connect("OnAbilityAdded", self, "on_ability_added")
	character.connect("OnAbilityRemoved", self, "on_ability_removed")
	character.equipment.connect("OnItemEquipped", self, "_on_item_equipped")
	character.equipment.connect("OnItemUnEquipped", self, "_on_item_unequipped")
	if character.team == Constants.TEAM.PLAYER:
		nameBg.color = playerTintColor
		isPlayer = true
		xpUI.visible = true
		var playerChar = character
		playerChar.connect("OnXPGained", self, "_update_base_ui")
		playerChar.connect("OnLevelUp", self, "_show_level_up")
	elif character.team == Constants.TEAM.ENEMY:
		nameBg.color = enemyTintColor
		xpUI.visible = false
	_update_base_ui()

	# Create Base Spells
	nonBaseContainer.visible = true
	spellContainer.visible = true
	for __ in range(character.maxSpellSlots):
		var newSpellUI:SpellItemUI = SpellButtonUI.instance()
		spellContainer.add_child(newSpellUI)
		newSpellUI.init_as_empty("Spell")
		spellSlots.append(newSpellUI)

	# Create Weapon
	weaponSlot = _create_item_slot("Weapon")
	armorSlot = _create_item_slot("Armor")
	for __ in range(character.maxRuneSlots):
		runeSlots.append(_create_item_slot("Rune"))

func _create_item_slot(slotName:String):
	var newItemUI = EquippedItemUI.instance()
	listContainer.add_child(newItemUI)
	newItemUI.init_as_empty(slotName)
	return newItemUI
	
func _update_base_ui():
	if inLevelUpSequence:
		return

	if isPlayer:
		var playerChar = character
		#nameLabel.text = str(character.displayName, " (Lvl ", playerChar.get_level()+1, ")")
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
func _on_item_equipped(item, slotType):
	if item.data.is_spell():
		var newSpellUI:SpellItemUI = _get_spell_slot(slotType)
		newSpellUI.init(item)
		equippedSpells[item] = newSpellUI

		newSpellUI.connect("pressed", self, "_on_equip_spell_selected", [item])
	else:
		var newItemUI = _get_item_slot(slotType)
		newItemUI.init(item)
		equippedItems[item] = newItemUI

func _on_item_unequipped(item, slotType):
	if item.data.is_spell():
		if equippedSpells.has(item):
			var newSpellUI:SpellItemUI = _get_spell_slot(slotType)
			newSpellUI.revert_as_empty()
			newSpellUI.disconnect("pressed", self, "_on_equip_spell_selected")
			equippedSpells.erase(item)
	else:
		if equippedItems.has(item):
			var itemUI = _get_item_slot(slotType)
			itemUI.revert_as_empty()
			equippedItems.erase(item)

# SPELLS
func _on_equip_spell_selected(spellItem):
	if spellItem.can_activate():
		character.equipment.activate_spell(spellItem)

# EFFECTS
func on_passive_added(_character, passive):
	var newEffectUI:EffectItemUI = EffectItemUI.instance()
	effectContainer.add_child(newEffectUI)
	newEffectUI.init(passive)
	equippedEffects[passive] = newEffectUI

	effectContainer.visible = true

func on_passive_removed(_character, passive):
	if equippedEffects.has(passive):
		effectContainer.remove_child(equippedEffects[passive])
		equippedEffects.erase(passive)
		
	if equippedEffects.size()==0:
		effectContainer.visible = false

func on_status_effect_added(_character, statusEffect):
	var newEffectUI = EffectItemUI.instance()
	effectContainer.add_child(newEffectUI)
	newEffectUI.init(statusEffect)
	equippedEffects[statusEffect] = newEffectUI

	effectContainer.visible = true

func on_status_effect_removed(_character, statusEffect):
	if equippedEffects.has(statusEffect):
		effectContainer.remove_child(equippedEffects[statusEffect])
		equippedEffects.erase(statusEffect)
		
	if equippedEffects.size()==0:
		effectContainer.visible = false

func on_ability_added(_character, ability):
	var newEffectUI = EffectItemUI.instance()
	effectContainer.add_child(newEffectUI)
	newEffectUI.init(ability.data)
	equippedEffects[ability] = newEffectUI

	effectContainer.visible = true

func on_ability_removed(_character, ability):
	if equippedEffects.has(ability):
		effectContainer.remove_child(equippedEffects[ability])
		equippedEffects.erase(ability)
		
	if equippedEffects.size()==0:
		effectContainer.visible = false
	
func has_entity(entity):
	return character == entity

# HELPERS
func _get_spell_slot(slotType):
	var slotIdx:int = _get_spell_slotIndex(slotType)
	if slotIdx>=0:
		return spellSlots[slotIdx]

	return null

func _get_spell_slotIndex(slotType):
	if slotType == Constants.ITEM_EQUIP_SLOT.SPELL_1:
		return 0
	elif slotType == Constants.ITEM_EQUIP_SLOT.SPELL_2:
		return 1
	elif slotType == Constants.ITEM_EQUIP_SLOT.SPELL_3:
		return 2
	elif slotType == Constants.ITEM_EQUIP_SLOT.SPELL_4:
		return 3

	return -1

func _get_item_slot(slotType):
	if slotType == Constants.ITEM_EQUIP_SLOT.WEAPON:
		return weaponSlot
	elif slotType == Constants.ITEM_EQUIP_SLOT.ARMOR:
		return armorSlot
	elif slotType == Constants.ITEM_EQUIP_SLOT.RUNE_1:
		return runeSlots[0]
	elif slotType == Constants.ITEM_EQUIP_SLOT.RUNE_2:
		return runeSlots[1]

	return null
