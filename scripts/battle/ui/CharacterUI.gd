extends Node

class_name CharacterUI

@onready var baseContainer:PanelContainer = get_node(".")
@onready var listContainer:VBoxContainer = get_node("HSplitContainer/Base")
#@onready var nameBg:ColorRect = get_node("HSplitContainer/Base/Name/Bg")
@onready var nameLabel:Label = get_node("HSplitContainer/Base/Name/NameLabel")
@onready var xpUI:PanelContainer = get_node("HSplitContainer/Base/XP")
@onready var xpBar:ProgressBar = get_node("HSplitContainer/Base/XP/XPBar")
@onready var levelUpBar:ProgressBar = get_node("HSplitContainer/Base/XP/LevelUpBar")
@onready var xpLabel:Label = get_node("HSplitContainer/Base/XP/XPLabel")
const EquippedItemUIScene := preload("res://ui/battle/EquippedItemUI.tscn")
@onready var soulsIcon:TextureRect = $"%SoulsIcon"
@onready var soulsLabel:Label = $"%SoulsLabel"
@onready var ResourceContainer:GridContainer = $"%ResourceContainer"
const ResourceSlotUI := preload("res://ui/battle/ResourceSlotUI.tscn")
var resourceSlots:Array = []

@onready var nonBaseContainer:Node = $"%NonBase"

@onready var spellContainer:VBoxContainer = $"%SpellContainer"
const SpellButtonUI := preload("res://ui/battle/SpellButtonUI.tscn")

@onready var potionContainer:VBoxContainer = $"%PotionContainer"
@onready var potionGridContainer:GridContainer = $"%PotionGridContainer"
const ConsumableItemUIScene := preload("res://ui/battle/ConsumableItemUI.tscn")

@onready var effectContainer:VBoxContainer = $"%EffectContainer"
@onready var effectGridContainer:GridContainer = $"%EffectGridContainer"
const EffectItemUIScene := preload("res://ui/battle/EffectItemUI.tscn")

@onready var dungeonModContainer:VBoxContainer = $"%DungeonModContainer"
@onready var dungeonModGridContainer:GridContainer = $"%DungeonModGridContainer"

@export var playerTintColor:Color
@export var enemyTintColor:Color

@export var baseContainerFlashColor:Color
@export var healthBarFlashColor:Color

var originalHealthBarColor:Color
var character:Character

var equippedItems:Dictionary = {}
var equippedSpells:Dictionary = {}
var equippedEffects:Dictionary = {}
var dungeonModifiers:Dictionary = {}
var equippedPotions:Dictionary = {}
var spellSlots:Array = []
var weaponSlot
var armorSlot
var runeSlots:Array = []

var isPlayer:bool

var xpTween:Tween = null

func init(entityObj):
	character = entityObj as Character
	#nameLabel.text = character.displayName
	#character.connect("OnStatChanged",Callable(self,"_on_stat_changed"))
	character.inventory.connect("OnConsumableItemAdded",Callable(self,"on_consumable_added"))
	character.inventory.connect("OnConsumableItemRemoved",Callable(self,"on_consumable_removed"))
	character.connect("OnPassiveAdded",Callable(self,"on_passive_added"))
	character.connect("OnPassiveRemoved",Callable(self,"on_passive_removed"))
	character.connect("OnStatusEffectAdded",Callable(self,"on_status_effect_added"))
	character.connect("OnStatusEffectRemoved",Callable(self,"on_status_effect_removed"))
	character.connect("OnDungeonModifierAdded",Callable(self,"on_dungeon_modifier_added"))
	#character.connect("OnAbilityAdded",Callable(self,"on_ability_added"))
	#character.connect("OnAbilityRemoved",Callable(self,"on_ability_removed"))
	character.equipment.connect("OnItemEquipped",Callable(self,"_on_item_equipped"))
	character.equipment.connect("OnItemUnEquipped",Callable(self,"_on_item_unequipped"))
	if character.team == Constants.TEAM.PLAYER:
		#nameBg.color = playerTintColor
		isPlayer = true
		xpUI.visible = true
		var playerChar = character
		playerChar.connect("OnXPGained",Callable(self,"_update_base_ui"))
		playerChar.connect("OnSoulsModified",Callable(self,"_update_base_ui"))
		#playerChar.connect("OnLevelUp",Callable(self,"_show_level_up"))
	elif character.team == Constants.TEAM.ENEMY:
		#nameBg.color = enemyTintColor
		xpUI.visible = false
	_update_base_ui()

	# Create Base Spells
	nonBaseContainer.visible = true
	spellContainer.visible = false
	'''for __ in range(character.maxSpellSlots):
		var newSpellUI:SpellItemUI = SpellButtonUI.instantiate()
		spellContainer.add_child(newSpellUI)
		newSpellUI.init_as_empty("Spell")
		spellSlots.append(newSpellUI)'''

	# Weapon
	weaponSlot = _create_item_slot("Weapon")
	# Armor
	armorSlot = _create_item_slot("Armor")
	# Runes
	for __ in range(character.maxRuneSlots):
		runeSlots.append(_create_item_slot("Rune"))

	# Energy
	_init_resource_slots()

func _create_item_slot(slotName:String):
	var newItemUI = EquippedItemUIScene.instantiate()
	listContainer.add_child(newItemUI)
	newItemUI.init_as_empty(slotName)
	return newItemUI
	
func _update_base_ui():
	if inLevelUpSequence:
		return

	if isPlayer:
		var playerChar = character
		#nameLabel.text = str(character.displayName, " (Lvl ", playerChar.get_level()+1, ")")
		'''var xpToLevelUp:float = float(playerChar.get_xp_to_level_xp())
		if playerChar.is_at_max_level():
			xpLabel.text = "Max Level"
		else:
			xpLabel.text = str("Xp: ", playerChar.get_xp_from_current_level(), "/", playerChar.get_xp_to_level_xp())
		var pctXP:float = 1
		if xpToLevelUp>0:
			pctXP = float(playerChar.get_xp_from_current_level())/xpToLevelUp
		#xpBar.value = pctXP * 100
		xpTween = Utils.create_tween_float(xpBar, "value", xpBar.value, pctXP * 100, 0.25, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)'''
		soulsLabel.text = str(playerChar.get_souls())
		var startScale:Vector2 = Vector2(1, 1)
		var endScale:Vector2 = Vector2(1.5, 1.5)
		Utils.create_return_tween_vector2(soulsIcon, "scale", startScale, endScale, 0.25, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, 0.25)


var inLevelUpSequence:bool
func _show_level_up():
	inLevelUpSequence = true
	if xpTween!=null:
		xpTween.stop()
	levelUpBar.visible = true
	xpLabel.text = "Level Up!"
	if get_tree()!=null:
		await get_tree().create_timer(1.0).timeout 
	levelUpBar.visible = false
	inLevelUpSequence = false
	_update_base_ui()

# ITEMS
func _on_item_equipped(item, slotType):
	if item.data.is_spell():
		var newSpellUI:SpellItemUI = _get_spell_slot(slotType)
		newSpellUI.init(item)
		equippedSpells[item] = newSpellUI

		newSpellUI.connect("pressed",Callable(self,"_on_equip_spell_selected").bind(item))
	else:
		var newItemUI = _get_item_slot(slotType)
		newItemUI.init(item)
		equippedItems[item] = newItemUI

func _on_item_unequipped(item, slotType):
	if item.data.is_spell():
		if equippedSpells.has(item):
			var newSpellUI:SpellItemUI = _get_spell_slot(slotType)
			newSpellUI.revert_as_empty()
			newSpellUI.disconnect("pressed",Callable(self,"_on_equip_spell_selected"))
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

# POTIONS
func on_consumable_added(item):
	var consumableItemUI:ConsumableItemUI = ConsumableItemUIScene.instantiate()
	potionGridContainer.add_child(consumableItemUI)
	consumableItemUI.init(item)
	equippedPotions[item] = consumableItemUI

	potionContainer.visible = true

func on_consumable_removed(item):
	if equippedPotions.has(item):
		potionGridContainer.remove_child(equippedPotions[item])
		equippedPotions.erase(item)
		
	if equippedPotions.size()==0:
		potionContainer.visible = false

# EFFECTS
func on_passive_added(_character, passive):
	if passive.data.dontDisplayInUI:
		return

	if passive.data.isFromSkillTree:
		on_dungeon_modifier_added(_character, passive)
	else:
		var newEffectUI:EffectItemUI = EffectItemUIScene.instantiate()
		effectGridContainer.add_child(newEffectUI)
		newEffectUI.init(passive, Color.ORANGE)
		equippedEffects[passive] = newEffectUI

		effectContainer.visible = true

func on_passive_removed(_character, passive):
	if passive.data.dontDisplayInUI:
		return
		
	if equippedEffects.has(passive):
		effectGridContainer.remove_child(equippedEffects[passive])
		equippedEffects.erase(passive)
		
	if equippedEffects.size()==0:
		effectContainer.visible = false

func on_status_effect_added(_character, statusEffect):
	var newEffectUI = EffectItemUIScene.instantiate()
	effectGridContainer.add_child(newEffectUI)
	newEffectUI.init(statusEffect, Color.CYAN)
	equippedEffects[statusEffect] = newEffectUI

	effectContainer.visible = true

func on_status_effect_removed(_character, statusEffect):
	if equippedEffects.has(statusEffect):
		effectGridContainer.remove_child(equippedEffects[statusEffect])
		equippedEffects.erase(statusEffect)
		
	if equippedEffects.size()==0:
		effectContainer.visible = false

func on_ability_added(_character, ability):
	var newEffectUI = EffectItemUIScene.instantiate()
	effectGridContainer.add_child(newEffectUI)
	newEffectUI.init(ability, Color.YELLOW)
	equippedEffects[ability] = newEffectUI

	effectContainer.visible = true

func on_ability_removed(_character, ability):
	if equippedEffects.has(ability):
		effectGridContainer.remove_child(equippedEffects[ability])
		equippedEffects.erase(ability)
		
	if equippedEffects.size()==0:
		effectContainer.visible = false
	
func on_dungeon_modifier_added(_character, dungeonModifierData):
	var newEffectUI = EffectItemUIScene.instantiate()
	dungeonModGridContainer.add_child(newEffectUI)
	newEffectUI.init(dungeonModifierData, Color.BEIGE)
	dungeonModifiers[dungeonModifierData] = newEffectUI

	dungeonModContainer.visible = true

func has_entity(entity):
	return character == entity

# RESOURCES
func _init_resource_slots():
	_create_all_resource_slots()
	character.connect("OnStatChanged",Callable(self,"_on_player_resource_updated"))

func _create_all_resource_slots():
	var maxEnergy:int = character.get_stat_max_value(StatData.STAT_TYPE.ENERGY)
	for i in maxEnergy:
		_create_resource_slot()
	_refresh_resources()

func _create_resource_slot():
	var resourceSlot := ResourceSlotUI.instantiate()
	ResourceContainer.add_child(resourceSlot)
	resourceSlots.append(resourceSlot)

func _refresh_resources():
	var currentEnergy:int = character.get_stat_value(StatData.STAT_TYPE.ENERGY)
	var maxEnergy:int = character.get_stat_max_value(StatData.STAT_TYPE.ENERGY)

	if resourceSlots.size() != maxEnergy:
		_clean_up_resource_slots()
		_create_all_resource_slots()

	for i in maxEnergy:
		resourceSlots[i].clear()
		if currentEnergy<=i:
			resourceSlots[i].set_empty()
		else:
			resourceSlots[i].set_filled()

func _on_player_resource_updated(_character):
	_refresh_resources()

func _clean_up_resource_slots():
	for resourceSlot in resourceSlots:
		resourceSlot.queue_free()
	resourceSlots.clear()

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
