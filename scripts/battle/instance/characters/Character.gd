# Character.gd
extends Node

class_name Character

@onready var damageText:Label = get_node("DamageText")
@onready var animPlayer:AnimationPlayer = get_node("AnimationPlayer")

var charData:CharacterData
var displayName: String = ""
var team: int = 0
var stamina: int = 0
var prevCell
var cell
var isDead:bool = false
var setToRevive:int = -1

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

var attackModifier:AttackModifier

var maxSpellSlots:int = 2
var maxRuneSlots:int = 2

signal OnCharacterMove(x, y)
signal OnCharacterFailedToMove(x, y)
signal OnCharacterMoveToCell()
signal OnCharacterItemPicked()
signal OnCharacterRoomChanged(newRoom)
signal OnStatChanged(character)
signal OnReviveStart()
signal OnReviveEnd()
signal OnDeath()

signal OnPreAttack(defender)
signal OnPostAttack(defender)
var successfulDamageThisTurn:int
var skipThisTurn:bool

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

	if !charData.passive.is_empty():
		specialPassive = add_passive(GameGlobals.dataManager.get_passive_data(charData.passive))

	emit_signal("OnInitialized")

	equipment.connect("OnItemEquipped",Callable(self,"_on_item_equipped"))
	equipment.connect("OnItemUnEquipped",Callable(self,"_on_item_unequipped"))

# MOVEMENT
func move(x, y):
	if x==0 and y==0:
		return

	var newR:int = cell.row + y
	var newC:int = cell.col + x
	
	var success:bool = cell.room.move_entity(self, cell, newR, newC)
	if success:
		emit_signal("OnCharacterMove", x, y)
	else:
		emit_signal("OnCharacterFailedToMove", x, y)

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
	await get_tree().create_timer(0.05).timeout

	if triggerTurnCompleteEvent:
		on_turn_completed()

# STATS
func get_stat_base_value(statType:Stat):
	var statValue:int = 0
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			statValue = statValue + stat.value
	
	return statValue

func get_stat_value(statType):
	var statValue:int = 0
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			statValue = statValue + stat.value
	# iterate through items
	statValue = statValue + equipment.get_stat_bonus_from_equipped_items(statType)
	
	return statValue

func get_stat_max_value(statType):
	var statMaxValue:int = 0
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			statMaxValue = statMaxValue + stat.maxValue
	# iterate through items
	statMaxValue = statMaxValue + equipment.get_stat_max_bonus_from_equipped_items(statType)

	return statMaxValue

func modify_absolute_stat_value(statType, modifierValue):
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			stat.modify_absolute(stat.value + modifierValue)
			on_stats_changed()
			return stat.value

	print("ERROR: Can't find stat type - ", statType)
	return null

func modify_stat_value(statType, modifierValue):
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			stat.modify(stat.value + modifierValue)
			on_stats_changed()
			return stat.value

	print("ERROR: Can't find stat type - ", statType)
	return null

func modify_stat_value_from_modifier(statModifierData:StatModifierData):
	# iterate through char
	for stat in stats:
		if stat.type == statModifierData.type:
			if statModifierData.value!=0:
				stat.modify(stat.value + statModifierData.value)
			elif statModifierData.maxValue!=0:
				stat.modify_max(stat.maxValue + statModifierData.maxValue)
				stat.modify(stat.value + statModifierData.maxValue)

			on_stats_changed()
			return stat.value

	print("ERROR: Can't find stat type - ", statModifierData.type)
	return null

func get_stat(statType):
	for stat in stats:
		if stat.type == statType:
			return stat

	return null

func initiate_revive(numTurns):
	setToRevive = numTurns
	emit_signal("OnReviveStart")
	#_show_generic_text(self, str("Revive x", str(numTurns)))

func revive():
	reset_all_stats()
	emit_signal("OnReviveEnd")
	# Maybe play an animation here

func reset_all_stats():
	for stat in stats:
		stat.reset()
	on_stats_changed()

func reset_stat_value(statType):
	for stat in stats:
		if stat.type == statType:
			stat.reset()
			on_stats_changed()
			return stat.value

	print("ERROR: Can't find stat type - ", statType)
	return null

func on_stats_changed():
	emit_signal("OnStatChanged", self)

# ITEMS

# For testing when player goes over, they get the item
func pick_item(itemToAdd):
	inventory.add_item(itemToAdd)
	emit_signal("OnCharacterItemPicked")

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
		var originalPos:Vector2 = self.position
		if dirn==Constants.DIRN_TYPE.LEFT:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(SHOVE_AMOUNT, 0), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.RIGHT:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(-SHOVE_AMOUNT, 0), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.DOWN:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, -SHOVE_AMOUNT), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.UP:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, SHOVE_AMOUNT), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		
		await get_tree().create_timer(0.075).timeout

		self.position = originalPos

		emit_signal("OnPreAttack", entity)

		var damageAmount:int = get_stat_value(StatData.STAT_TYPE.DAMAGE)

		if attackModifier!=null:
			damageAmount = int(damageAmount * attackModifier.damageMultiplier)
			var targets = get_targets()
			for target in targets:
				HitResolutionManager.do_hit(self, target, damageAmount)
		else:
			HitResolutionManager.do_hit(self, entity, damageAmount)
		
		# Feels
		if entity.isDead:
			Utils.freeze_frame(Constants.HIT_PAUSE_KILL_AMOUNT, Constants.HIT_PAUSE_KILL_DURATION)
		else:
			Utils.freeze_frame(Constants.HIT_PAUSE_DEFAULT_AMOUNT, Constants.HIT_PAUSE_DEFAULT_DURATION)
		CombatEventManager.on_any_attack(entity)

		await get_tree().create_timer(0.1).timeout

		emit_signal("OnPostAttack", entity)

		on_turn_completed()
	else:
		on_turn_completed()

func can_take_damage()->bool:
	if is_reviving():
		return false

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
	emit_signal("OnDeath")
	CombatEventManager.emit_signal("OnAnyCharacterDeath", self)

	if setToRevive>0:
		pass
	else:
		isDead = true
		if animPlayer!=null:
			animPlayer.play("Death")
		
		currentRoom.enemy_died(self)
		
		await get_tree().create_timer(0.1).timeout
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
	self.self_modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
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
	await get_tree().create_timer(duration).timeout
	damageText.visible = false

func _create_damage_text_tween(_entity):
	"""var dirn:int = dirn_to_character(entity)
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
		endPos = Vector2(0, 10)"""

	var colorOriginal:Color = damageText.self_modulate
	colorOriginal.a = 1.0
	var colorNew:Color = damageText.self_modulate
	colorNew.a = 0.0

	#Utils.create_tween_vector2(damageText, "position", startPos, endPos, 0.25, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	#Utils.create_tween_vector2(damageText, "position", startPos, startPos, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	Utils.create_tween_vector2(damageText, "self_modulate", colorOriginal, colorNew, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)

func pre_update():
	successfulDamageThisTurn = 0
	skipThisTurn = false

func update():
	if setToRevive>=0:
		setToRevive = setToRevive - 1
		skipThisTurn = true
		if setToRevive==-1:
			revive()
		else:
			_show_generic_text(self, str("Revive x", str(setToRevive+1)))
		return

	if status.is_stunned():
		skipThisTurn = true
		return

func post_update():
	targetList = []
	successfulDamageThisTurn = 0

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
	if status.is_stunned():
		show_stun()
	#pass

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
			statusEffectModifierList.remove_at(i)

func get_status_effect_modifiers(statusEffectId:String):
	var matchedStatusEffectModifiers:Array = []
	for statusEffectModifier in statusEffectModifierList:
		if statusEffectModifier.statusEffectId == statusEffectId:
			matchedStatusEffectModifiers.append(statusEffectModifier)

	return matchedStatusEffectModifiers

# PASSIVES
func add_passive(passiveData:PassiveData):
	# Don't add duplicates (may need this in the future ?)
	#for passive in passiveList:
	#	if passive.data == passiveData:
	#		return passive

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
			passive.clear_events()
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
			specialModifierList.remove_at(i)

func get_special_modifiers(specialId:String):
	var matchedspecialModifiers:Array = []
	for specialModifier in specialModifierList:
		if specialModifier.specialId == specialId:
			matchedspecialModifiers.append(specialModifier)

	return matchedspecialModifiers

# ATTACK
func add_attack_modifier(attackModifierVal:AttackModifier):
	attackModifier = attackModifierVal

func remove_attack_modifier():
	attackModifier = null

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

func has_ability(abilityData:AbilityData):
	for ability in abilityList:
		if ability.data == abilityData:
			return true

	return false

# TURNS
func on_turn_completed():
	emit_signal("OnTurnCompleted")

func skip_turn():
	if status.is_stunned():
		show_stunned()
	await get_tree().create_timer(0.5).timeout
	on_turn_completed()

# HELPERS
func is_reviving():
	return setToRevive>=0

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
	return get_stat_max_value(StatData.STAT_TYPE.HEALTH)

func get_damage():
	return get_stat_value(StatData.STAT_TYPE.DAMAGE)

func get_max_damage():
	return get_stat_max_value(StatData.STAT_TYPE.DAMAGE)

func get_armor():
	return get_stat_value(StatData.STAT_TYPE.ARMOR)

func get_max_armor():
	return get_stat_max_value(StatData.STAT_TYPE.ARMOR)

func get_summary()->String:
	var summary:String = ""

	if statusEffectList.size()>0 or passiveList.size()>0:
		summary = summary + "\nEffects: "
		for statusEffect in statusEffectList:
			summary = summary + statusEffect.data.get_display_name() + " "

		for passive in passiveList:
			summary = summary + passive.data.get_display_name() + " "

	return summary
