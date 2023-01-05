# Character.gd
extends Node

class_name Character

onready var damageText:Label = get_node("DamageText")

var charData:CharacterData
var displayName: String = ""
var team: int = 0
var stamina: int = 0
var prevCell
var cell
var isDead:bool = false

var stats:Array = []
var statDict:Dictionary = {}
var moveAction:Action
var attackAction:Action

var status:CharacterStatus

var inventory:Inventory
var equipment:Equipment

var currentRoom = null
var prevRoom = null

var targetList:Array = []
var lastHitTarget:Character
var lastKilledTarget:Character
var lastEnemyThatHitMe:Character

var statusEffectList:Array = []
var statusEffectModifierList:Array = []
var passiveList:Array = []
var abilityList:Array = []

var special:Special
var specialModifierList:Array = []
var specialPassive:Passive

var maxSpellSlots:int = 2
var maxRuneSlots:int = 2

signal OnCharacterMove(x, y)
signal OnCharacterMoveToCell()
signal OnCharacterRoomChanged(newRoom)
signal OnStatChanged(character)
signal OnDeath()

signal OnPreAttack(defender)
signal OnPostAttack(defender)
var successfulDamageThisFrame:int

signal OnStatusEffectAdded(character, statusEffect)
signal OnStatusEffectAddedToEnemy(character, statusEffect)
signal OnStatusEffectRemoved(character, statusEffect)
signal OnPassiveAdded(character, passive)
signal OnPassiveRemoved(character, passive)
signal OnAbilityAdded(character, ability)
signal OnAbilityRemoved(character, ability)

signal OnTurnCompleted()
signal OnInitialized()

var originalColor:Color

var charId:int

func init(id:int, charDataVal, teamVal):
	charId = id
	charData = charDataVal
	displayName = charData.displayName
	team = teamVal
	if team == Constants.TEAM.PLAYER:
		originalColor = GameGlobals.battleInstance.view.playerDamageColor
		#damageText.self_modulate = GameGlobals.battleInstance.view.enemyDamageColor
	elif team == Constants.TEAM.ENEMY:
		originalColor = GameGlobals.battleInstance.view.enemyDamageColor
		#damageText.self_modulate = GameGlobals.battleInstance.view.playerDamageColor

	# Stats
	for statData in charData.statDataList:
		var stat = Stat.new(statData)
		if stat!=null:
			stats.append(stat)
			statDict[statData.type] = stat
			# Disable Complex Stats for now
			#if GameGlobals.dataManager.is_complex_stat_data(statData.type):
			#	var complexStatData:ComplexStatData = GameGlobals.dataManager.get_complex_stat_data(statData.type)
			#	_create_linked_stat(complexStatData.linkedStatType, statData.type, complexStatData.linkedStatMultiplier)

	var attackData:Dictionary = {}
	attackData["type"] = "ATTACK"
	attackData["params"] = {}
	attackData["params"]["damageMultiplier"] = 1.0
	attackAction = ActionTypes.create(ActionDataTypes.create(attackData), self)

	# Status
	status = CharacterStatus.new()

	inventory = Inventory.new(self)
	equipment = Equipment.new(self)

	if charData.active!=null:
		special = Special.new(self, charData.active)

	if !charData.passive.empty():
		specialPassive = add_passive(GameGlobals.dataManager.get_passive_data(charData.passive))

	emit_signal("OnInitialized")

	equipment.connect("OnItemEquipped", self, "_on_item_equipped")
	equipment.connect("OnItemUnEquipped", self, "_on_item_unequipped")

# MOVEMENT
func move(x, y):
	if x==0 and y==0:
		return

	var newR:int = cell.row + y
	var newC:int = cell.col + x
	
	var success:bool = cell.room.move_entity(self, cell, newR, newC)
	if success:
		emit_signal("OnCharacterMove", x, y)

# Mostly for AI
func failed_to_move():
	on_turn_completed()

func move_to_cell(newCell, triggerTurnCompleteEvent:bool=false):
	prevCell = cell
	cell = newCell
	if currentRoom != cell.room:
		prevRoom = currentRoom
		emit_signal("OnCharacterRoomChanged", cell.room)
	currentRoom = cell.room

	emit_signal("OnCharacterMoveToCell")

	Utils.create_tween_vector2(self, "position", self.position, Vector2(cell.pos.x, cell.pos.y), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
	yield(get_tree().create_timer(0.05), "timeout")

	if triggerTurnCompleteEvent:
		on_turn_completed()

# STATS
func get_stat_value(statType):
	var statValue:int = 0
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			statValue = statValue + stat.get_value()
	# iterate through items
	statValue = statValue + equipment.get_stat_bonus_from_equipped_items(statType)
	
	return statValue

func get_stat_base_value(statType):
	var statBaseValue:int = 0
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			statBaseValue = statBaseValue + stat.get_base_value()
	# iterate through items
	statBaseValue = statBaseValue + equipment.get_stat_base_bonus_from_equipped_items(statType)

	return statBaseValue

func modify_absolute_stat_value(statType, modifierValue):
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			stat.modify_absolute_value(stat.get_value() + modifierValue)
			on_stats_changed()
			return stat.get_value()

	print("ERROR: Can't find stat type - ", statType)
	return null

func modify_stat_value(statType, modifierValue):
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			stat.modify_value(stat.get_value() + modifierValue)
			on_stats_changed()
			return stat.get_value()

	print("ERROR: Can't find stat type - ", statType)
	return null

func modify_stat_value_from_modifier(statModifierData:StatModifierData):
	# iterate through char
	for stat in stats:
		if stat.type == statModifierData.type:
			if GameGlobals.dataManager.is_complex_stat_data(statModifierData.type):
				stat.modify_base_value(stat.get_base_value() + statModifierData.value)
				var complexStatData:ComplexStatData = GameGlobals.dataManager.get_complex_stat_data(statModifierData.type)
				refresh_linked_stat_value(complexStatData.linkedStatType)
			
			if statModifierData.value!=0:
				stat.modify_value(stat.get_value() + statModifierData.value)
			elif statModifierData.baseValue!=0:
				stat.modify_base_value(stat.get_base_value() + statModifierData.baseValue)
				stat.modify_value(stat.get_value() + statModifierData.baseValue)

			on_stats_changed()
			return stat.get_value()

	print("ERROR: Can't find stat type - ", statModifierData.type)
	return null

func get_stat(statType):
	for stat in stats:
		if stat.type == statType:
			return stat

	return null

func refresh_linked_stat_value(statType):
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			stat.update_from_modified_linked_stat()
			on_stats_changed()
			return stat.get_value()

	print("ERROR: Can't find stat type - ", statType)
	return null

func reset_stat_value(statType):
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			stat.reset_value()
			on_stats_changed()
			return stat.get_value()

	print("ERROR: Can't find stat type - ", statType)
	return null

func on_stats_changed():
	emit_signal("OnStatChanged", self)

# ITEMS

# For testing when player goes over, they get the item
func pick_item(itemToAdd):
	inventory.add_item(itemToAdd)

func _on_item_equipped(_item, _slotType):
	on_stats_changed()

func _on_item_unequipped(_item, _slotType):
	on_stats_changed()

# COMBAT
func attack(entity):
	if entity.is_class(self.get_class()):
		# shove towards
		var SHOVE_AMOUNT:float = 7
		var dirn:int = dirn_to_character(entity)
		if dirn==Constants.DIRN_TYPE.LEFT:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(SHOVE_AMOUNT, 0), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.RIGHT:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(-SHOVE_AMOUNT, 0), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.DOWN:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, -SHOVE_AMOUNT), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.UP:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, SHOVE_AMOUNT), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)

		yield(get_tree().create_timer(0.075), "timeout")

		emit_signal("OnPreAttack", entity)
		var damageAmount:int = get_stat_value(StatData.STAT_TYPE.DAMAGE)
		successfulDamageThisFrame = HitResolutionManager.do_hit(self, entity, damageAmount)
		
		# Feels
		if entity.isDead:
			Utils.freeze_frame(Constants.HIT_PAUSE_KILL_AMOUNT, Constants.HIT_PAUSE_KILL_DURATION)
		else:
			Utils.freeze_frame(Constants.HIT_PAUSE_DEFAULT_AMOUNT, Constants.HIT_PAUSE_DEFAULT_DURATION)
		CombatEventManager.on_any_attack(entity.isDead)

		yield(get_tree().create_timer(0.1), "timeout")

		emit_signal("OnPostAttack", entity)

		on_turn_completed()
	else:
		on_turn_completed()

func can_take_damage()->bool:
	if status.is_invulnerable():
		return false

	return true

func take_damage(_damageSource, damage):
	modify_stat_value(StatData.STAT_TYPE.HEALTH, -damage)
	if _damageSource!=null:
		lastEnemyThatHitMe = _damageSource
	return get_health()

func on_blocked_hit(_attacker):
	show_blocked_text(self)
	if _attacker!=null:	
		lastEnemyThatHitMe = _attacker

func show_damage_from_hit(attacker, dmg, isCritical):
	show_hit(attacker, dmg, isCritical)

func die():
	isDead = true
	currentRoom.enemy_died(self)
	emit_signal("OnDeath")

	yield(get_tree().create_timer(0.1), "timeout")

	if cell.entityObject!=null:
		cell.entityObject.hide()
	cell.clear_entity_on_death()

func show_hit(entity, _dmg, isCritical):
	# shove
	if !isDead:
		var dirn:int = dirn_to_character(entity)
		if dirn==Constants.DIRN_TYPE.RIGHT:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(10, 0), 0.05, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.LEFT:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(-10, 0), 0.05, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.UP:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, -10), 0.05, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.DOWN:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, 10), 0.05, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	
	show_hit_flash()
	if isCritical:
		show_critical(entity)
	#show_damage_text(entity, dmg)

func show_hit_flash():
	self.self_modulate = Color.white
	yield(get_tree().create_timer(0.1), "timeout")
	reset_color()

func reset_color():
	self.self_modulate = originalColor
	
# Deprecated
func show_damage_text(entity, dmg):
	if entity==null:
		return
	
	"""if(entity.team == Constants.TEAM.ENEMY):
		damageText.modulate = GameGlobals.battleInstance.view.playerDamageColor
	else:
		damageText.modulate = GameGlobals.battleInstance.view.enemyDamageColor"""
	_show_generic_text(entity, str(dmg), 0.35)

func show_blocked_text(entity):
	_show_generic_text(entity, "Immune")

func show_critical(entity):
	_show_generic_text(entity, "Crit")

func show_stun():
	_show_generic_text(self, "Stun")

func show_stunned():
	_show_generic_text(self, "Stunned")

func _show_generic_text(entity, val:String, duration:float=0.75):
	damageText.visible = true
	damageText.text = val
	_create_damage_text_tween(entity)
	yield(get_tree().create_timer(duration), "timeout")
	damageText.visible = false

func _create_damage_text_tween(entity):
	var dirn:int = dirn_to_character(entity)
	# damage text
	var startPos:Vector2 = Vector2(0,-30)
	var endPos:Vector2 = Vector2(10,-60)
	if dirn==Constants.DIRN_TYPE.RIGHT:
		startPos = Vector2(0, -5)
		endPos = Vector2(10, -3)
	elif dirn==Constants.DIRN_TYPE.LEFT:
		startPos = Vector2(-20, 0)
		endPos = Vector2(-30, 0)
	elif dirn==Constants.DIRN_TYPE.UP:
		startPos = Vector2(0, -20)
		endPos = Vector2(0,-30)
	elif dirn==Constants.DIRN_TYPE.DOWN:
		startPos = Vector2(0, 0)
		endPos = Vector2(0, 10)
	#Utils.create_tween_vector2(damageText, "rect_position", startPos, endPos, 0.25, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	#Utils.create_tween_vector2(damageText, "rect_position", startPos, startPos, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	Utils.create_tween_vector2(damageText, "rect_size", Vector2(20,20), Vector2(40,40), 0.25, Tween.TRANS_LINEAR, Tween.EASE_OUT)

func pre_update():
	successfulDamageThisFrame = 0

func update():
	pass

func post_update():
	targetList = []
	successfulDamageThisFrame = 0

# TARGETING
func add_target(target):
	targetList.append(target)

func has_targets():
	return targetList.size()>0

func get_random_target():
	targetList.shuffle()

	for target in targetList:
		if target.isDead:
			continue

		return target

	return null

func get_targets():
	return targetList

func clear_targets():
	targetList.clear()

# SPELLS
func on_spell_activated(_spellItem):
	pass
	#on_turn_completed()

# STATUS EFFECTS
func add_status_effect(sourceChar:Character, statusEffectData:StatusEffectData):
	var statusEffect = StatusEffect.new(self, statusEffectData)
	statusEffectList.append(statusEffect)
	emit_signal("OnStatusEffectAdded", self, statusEffect)
	if sourceChar!=self:
		sourceChar.emit_signal("OnStatusEffectAddedToEnemy", self, statusEffect)
	on_stats_changed()
	_update_status_effect_visuals()

	return statusEffect

func remove_status_effect(statusEffect):
	statusEffectList.erase(statusEffect)
	emit_signal("OnStatusEffectRemoved", self, statusEffect)
	on_stats_changed()
	#_update_status_effect_visuals()

func _update_status_effect_visuals():
	#if status.is_stunned():
	#	show_stun()
	pass

func has_status_effect(statusEffectId:String):
	for statusEffect in statusEffectList:
		if statusEffect.data.id == statusEffectId:
			return true

	return false

func add_status_effect_modifier(statusEffectModifier:StatusEffectModifier):
	statusEffectModifierList.append(statusEffectModifier)

func remove_status_effect_modifier(statusEffectId:String):
	for i in range(statusEffectModifierList.size() - 1, -1, -1):
		if (statusEffectId == statusEffectModifierList[i].statusEffectId):
			statusEffectModifierList.remove(i)

func get_status_effect_modifiers(statusEffectId:String):
	var matchedStatusEffectModifiers:Array = []
	for statusEffectModifier in statusEffectModifierList:
		if statusEffectModifier.statusEffectId == statusEffectId:
			matchedStatusEffectModifiers.append(statusEffectModifier)

	return matchedStatusEffectModifiers

# PASSIVES
func add_passive(passiveData:PassiveData):
	# Don't add duplicates
	for passive in passiveList:
		if passive.data == passiveData:
			return passive

	var passive:Passive = Passive.new(self, passiveData)
	passiveList.append(passive)
	emit_signal("OnPassiveAdded", self, passive)
	on_stats_changed()
	return passive

func remove_passive(passive:Passive):
	passiveList.erase(passive)
	emit_signal("OnPassiveRemoved", self, passive)
	on_stats_changed()

func remove_passive_from_data(passiveData:PassiveData):
	for passive in passiveList:
		if passive.data == passiveData:
			passiveList.erase(passive)
			emit_signal("OnPassiveRemoved", self, passive)
			on_stats_changed()
			break

# SPECIAL
func add_special_modifier(specialModifier:SpecialModifier):
	specialModifierList.append(specialModifier)
	special.check_for_ready()

func remove_special_modifier(specialId:String):
	for i in range(specialModifierList.size() - 1, -1, -1):
		if (specialId == specialModifierList[i].specialId):
			specialModifierList.remove(i)

func get_special_modifiers(specialId:String):
	var matchedspecialModifiers:Array = []
	for specialModifier in specialModifierList:
		if specialModifier.specialId == specialId:
			matchedspecialModifiers.append(specialModifier)

	return matchedspecialModifiers

# ABILITIES
func add_ability(abilityData:AbilityData):
	var ability = Ability.new(self, abilityData)
	abilityList.append(ability)
	emit_signal("OnAbilityAdded", self, ability)
	on_stats_changed()
	return ability

func remove_ability(ability):
	abilityList.erase(ability)
	emit_signal("OnAbilityRemoved", self, ability)
	on_stats_changed()

# TURNS
func on_turn_completed():
	emit_signal("OnTurnCompleted")

func skip_turn():
	if status.is_stunned():
		show_stunned()
	on_turn_completed()

# HELPERS
func is_in_room(room):
	return currentRoom == room

func is_prev_room(room):
	return prevRoom == room

func adjacent_character(character):
	return (abs(character.cell.col-cell.col)==0 and abs(character.cell.row-cell.row)==1) or\
			(abs(character.cell.row-cell.row)==0 and abs(character.cell.col-cell.col)==1) 

func dirn_to_character(character) -> int:
	if character.cell.col-cell.col<0:
		return Constants.DIRN_TYPE.RIGHT
	elif character.cell.col-cell.col>0:
		return Constants.DIRN_TYPE.LEFT
	elif character.cell.row-cell.row<0:
		return Constants.DIRN_TYPE.DOWN
	elif character.cell.row-cell.row>0:
		return Constants.DIRN_TYPE.UP

	return -1

func is_opposite_team(entity):
	return team != entity.team

func get_health():
	return get_stat_value(StatData.STAT_TYPE.HEALTH)

func get_max_health():
	return get_stat_base_value(StatData.STAT_TYPE.HEALTH)

func get_damage():
	return get_stat_value(StatData.STAT_TYPE.DAMAGE)

func get_armor():
	return get_stat_value(StatData.STAT_TYPE.ARMOR)

func _create_linked_stat(type:int, linkedStatType:int, linkedStatMultiplier:float):
	var newStatData:StatData = StatData.new()
	newStatData.init_from_code(type, 0)
	var newStat:Stat = Stat.new(newStatData)
	newStat.add_link_to_stat(statDict[linkedStatType], linkedStatMultiplier)
	stats.append(newStat)
	statDict[newStatData.type] = newStat

func get_summary()->String:
	var summary:String = ""

	if statusEffectList.size()>0 or passiveList.size()>0:
		summary = summary + "\nEffects: "
		for statusEffect in statusEffectList:
			summary = summary + statusEffect.data.get_display_name() + " "

		for passive in passiveList:
			summary = summary + passive.data.get_display_name() + " "

	return summary
