# Character.gd
extends Node

class_name Character

@onready var root:Sprite2D = $"%Root"
@onready var damageText:Label = get_node("DamageText")
@onready var animPlayer:AnimationPlayer = get_node("AnimationPlayer")
@onready var soulsIcon:Node = $"%SoulsIcon"
@onready var soulsLabel:Label = $"%SoulsLabel"

const DEATH_SPRITE_PATH:String = "res://entity/characters/textures/Death.png"

var charData:CharacterData
var displayName: String = ""
var team: int = 0
var stamina: int = 0
var prevCell
var cell
var isDead:bool = false
var setToRevive:int = -1
var _hasUpdatedThisTurn:bool = false
var _hasRevivedThisTurn:bool = false

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
var specialDict:Dictionary = {}
var specialList:Array = []

var attackModifier:AttackModifier

var maxSpellSlots:int = 2
var maxRuneSlots:int = 2

var specialSelectedDirnX:int
var specialSelectedDirnY:int
var specialSelectedCells:Array[DungeonCell]

signal OnCharacterMove(x, y)
signal OnCharacterFailedToMove(x, y)
signal OnCharacterMoveToCell()
signal OnCharacterItemPicked()
signal OnCharacterRoomChanged(newRoom)
signal OnStatChanged(character)
signal OnReviveStart()
signal OnReviveEnd()
signal OnDeath()
signal OnDeathFinal()
signal HideCharacterUI()

signal OnPreAttack(attacker, defender)
signal OnPostAttack(attacker, defender)
var successfulDamageThisTurn:int
var skipThisTurn:bool
var attackTween:Tween

signal OnConsumableAdded(character, consumable)
signal OnConsumableRemoved(character, consumable)
signal OnStatusEffectAdded(character, statusEffect)
signal OnStatusEffectAddedToEnemy(character, statusEffect)
signal OnStatusEffectRemoved(character, statusEffect)
signal OnPassiveAdded(character, passive)
signal OnPassiveRemoved(character, passive)
signal OnAbilityAdded(character, ability)
signal OnAbilityRemoved(character, ability)
signal OnDungeonModifierAdded(character, dungeonModifierData)
signal OnNearEnemy()
signal OnAnySpecialActivated()
signal OnSpecialAdded(character, special)
signal OnAnySpecialAdded()
signal OnSpecialRemoved(character, special)

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

	emit_signal("OnInitialized")

	equipment.connect("OnItemEquipped",Callable(self,"_on_item_equipped"))
	equipment.connect("OnItemUnEquipped",Callable(self,"_on_item_unequipped"))
	CombatEventManager.connect("OnAnyCharacterMoved",Callable(self,"_on_any_character_moved"))

	# need this for some edge case initialization flow
	await get_tree().create_timer(0.05).timeout

	if !charData.specials.is_empty():
		for special in charData.specials:
			add_special(GameGlobals.dataManager.get_special_data(special))

	if !charData.passives.is_empty():
		for passive in charData.passives:
			add_passive(GameGlobals.dataManager.get_passive_data(passive))

	# Visuals
	if !charData.spritePath.is_empty():
		set_sprite(str("res://") + charData.spritePath)

		if animPlayer!=null:
			animPlayer.play("Idle")

# MOVEMENT
func move(x, y, stopAtFirstCollision:bool=false, triggerTurnCompleted:bool=true):
	if x==0 and y==0:
		return

	var newR:int = cell.row + y
	var newC:int = cell.col + x
	
	var success:bool = cell.room.move_entity(self, cell, newR, newC, stopAtFirstCollision, triggerTurnCompleted)
	if success:
		emit_signal("OnCharacterMove", x, y)
		CombatEventManager.emit_signal("OnAnyCharacterMoved", self)
	else:
		emit_signal("OnCharacterFailedToMove", x, y)

	return success

func move_incrementally(x, y):
	if x==0 and y==0:
		return

	if x>0:
		for i in x:
			if !move(1, 0):
				return
	elif x<0:
		for i in -x:
			if !move(-1, 0):
				return

	if y>0:
		for i in y:
			if !move(0, 1):
				return
	elif y<0:
		for i in -y:
			if !move(-1, 0):
				return


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

func _on_any_character_moved(_charThatMoved:Character):
	var adjacentChars:Array = GameGlobals.dungeon.get_adjacent_characters(self, Constants.RELATIVE_TEAM.ENEMY, 1)
	if adjacentChars.size()>0:
		emit_signal("OnNearEnemy")

# STATS
func has_stat(statType):
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			return true
	
	return false

func get_stat_base_value(statType):
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
			elif statModifierData.absoluteValue!=0:
				stat.modify_max(stat.maxValue + statModifierData.absoluteValue)
				stat.modify(stat.value + statModifierData.absoluteValue)
			elif statModifierData.percentOfCurrentValue!=0:
				stat.modify(stat.value + statModifierData.percentOfCurrentValue * stat.value)
			elif statModifierData.percentOfMaxValue!=0:
				stat.modify(stat.value + statModifierData.percentOfMaxValue * stat.maxValue)

			on_stats_changed()
			return stat.value

	print("ERROR: Can't find stat type - ", statModifierData.type)
	return null

func get_stat(statType):
	for stat in stats:
		if stat.type == statType:
			return stat

	return null

func stat_compare(statType:int):
	for stat in stats:
		if stat.type == statType:
			return stat.compare_with_max()

	return 0

# REVIVE
func initiate_revive(numTurns):
	setToRevive = numTurns
	emit_signal("OnReviveStart")
	#_show_generic_text(self, str("Revive x", str(numTurns)))

func revive():
	reset_all_stats()
	emit_signal("OnReviveEnd")
	_hasRevivedThisTurn = true
	# Maybe play an animation here

func has_revived_this_turn():
	return _hasRevivedThisTurn

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
func attack(entity, triggerTurnCompleted:bool=true):
	if entity.is_class(self.get_class()):
		emit_signal("OnPreAttack", self, entity)
		
		# shove towards
		if attackTween!=null:
			attackTween.stop()
			attackTween = null
			self.position = cell.pos
		var SHOVE_AMOUNT:float = 7
		var dirn:int = dirn_to_character(entity)
		var originalPos:Vector2 = self.position
		if dirn==Constants.DIRN_TYPE.LEFT:
			attackTween = Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(SHOVE_AMOUNT, 0), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.RIGHT:
			attackTween = Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(-SHOVE_AMOUNT, 0), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.DOWN:
			attackTween = Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, -SHOVE_AMOUNT), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.UP:
			attackTween = Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, SHOVE_AMOUNT), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		
		await get_tree().create_timer(0.1).timeout

		if attackTween!=null:
			attackTween.stop()
			attackTween = null
		self.position = cell.pos

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

		await get_tree().create_timer(Constants.CHARACTER_POST_ATTACK_DELAY).timeout

		emit_signal("OnPostAttack", self, entity)
		
		self.position = cell.pos # just in case of edge cases

		if triggerTurnCompleted:
			on_turn_completed()
	else:
		if triggerTurnCompleted:
			on_turn_completed()

func pre_hit(_sourceChar:Character, _targetChar:Character, _damageFromHit:int):
	var evasionStat:int = get_evasion()
	var evadeThisHit:bool = Utils.random_chance((float)(evasionStat)/100.0)
	if evadeThisHit:
		status.set_evasive(1)

func post_hit(_sourceChar:Character, _targetChar:Character, _damageTakenFromHit:int):
	if status.is_evasive():
		status.set_evasive(-1)

func is_targetable():
	if isDead:
		return false
	
	return true

func can_take_damage()->bool:
	if status.is_invulnerable():
		return false

	if status.is_evasive():
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

	if setToRevive>=0:
		pass
	else:
		isDead = true
		
		currentRoom.enemy_died(self)

		emit_signal("OnDeathFinal")
		CombatEventManager.emit_signal("OnAnyCharacterDeathFinal", self)
		
		if soulsIcon!=null:
			soulsIcon.visible = true
			soulsLabel.text = str(charData.xp)
			var startScale:Vector2 = Vector2(1, 1)
			var endScale:Vector2 = Vector2(1.25, 1.25)
			Utils.create_return_tween_vector2(soulsIcon, "scale", startScale, endScale, 0.25, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, 0.25)

		clean_up_on_death()
		await get_tree().create_timer(0.5).timeout
		cell.clear_entity_on_death()

		if soulsIcon!=null:
			soulsIcon.visible = false

func show_hit(entity, _dmg, isCritical):
	# shove
	if !isDead:
		if attackTween!=null:
			attackTween.stop()
			attackTween = null
			self.position = cell.pos
		var dirn:int = dirn_to_character(entity)
		if dirn==Constants.DIRN_TYPE.RIGHT:
			attackTween = Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(10, 0), 0.05, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.LEFT:
			attackTween = Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(-10, 0), 0.05, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.UP:
			attackTween = Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, -10), 0.05, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.DOWN:
			attackTween = Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, 10), 0.05, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		
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
	if status.is_evasive():
		_show_generic_text(entity, "Miss")
	else:
		_show_generic_text(entity, "Immune")

func show_critical(entity):
	_show_generic_text(entity, "Crit")

func show_stun():
	_show_generic_text(self, "Stun")

func show_stunned():
	_show_generic_text(self, "Stunned")

func show_text_on_self(val:String, duration:float=0.75):
	_show_generic_text(self, val, duration)

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

func is_due_to_skip_turn():
	return status.is_stunned() or is_reviving()

func pre_update():
	successfulDamageThisTurn = 0
	skipThisTurn = false
	_hasUpdatedThisTurn = false
	_hasRevivedThisTurn = false

func update():
	if _hasUpdatedThisTurn:
		return

	_hasUpdatedThisTurn = true

	if setToRevive>=0:
		if setToRevive==0:
			_show_generic_text(self, str("Revive"))
		else:
			_show_generic_text(self, str("Revive (", str(setToRevive), ")"))
		setToRevive = setToRevive - 1
		skipThisTurn = true
		if setToRevive==-1:
			revive()
		return

	if status.is_stunned():
		skipThisTurn = true
		return

func post_update():
	targetList = []
	successfulDamageThisTurn = 0
	_hasUpdatedThisTurn = false

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

func has_passive(passiveData:PassiveData):
	for passive in passiveList:
		if passive.data == passiveData:
			return true

	return false

# SPECIAL
func add_special(specialData:SpecialData):
	var special = Special.new(self, specialData)
	specialList.append(special)
	specialDict[special.data.id] = special
	emit_signal("OnSpecialAdded", self, special)
	emit_signal("OnAnySpecialAdded")

func get_last_special_added()->Special:
	return specialList[specialList.size()-1]

func add_special_modifier(specialId:String, specialModifier:SpecialModifier):
	if !specialId.is_empty():
		specialDict[specialId].add_modifier(specialModifier)
	else:
		for special in specialList:
			special.add_modifier(specialModifier)

func remove_special(specialId:String):
	var special:Special = specialDict[specialId]
	emit_signal("OnSpecialRemoved", self, special)
	specialList.erase(special)
	specialDict.erase(specialId)

func has_special(specialData:SpecialData):
	return specialDict.has(specialData.id)

func force_special_ready(specialId:String):
	if !specialId.is_empty():
		specialDict[specialId].force_ready()
	else:
		for special in specialList:
			special.force_ready()

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
	await get_tree().create_timer(0.25).timeout
	on_turn_completed()

# DUNGEON MODIFIERS
func add_dungeon_modifier(dungeonModifierData:DungeonModifierData):
	for statModifierData in dungeonModifierData.statModifierDataList:
		modify_stat_value_from_modifier(statModifierData)
	if !dungeonModifierData.passiveId.is_empty():
		add_passive(GameGlobals.dataManager.get_passive_data(dungeonModifierData.passiveId))
	
	emit_signal("OnDungeonModifierAdded", self, dungeonModifierData)

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

func consume_energy(val:int):
	get_stat(StatData.STAT_TYPE.ENERGY).add(-val)
	on_stats_changed()

func get_energy():
	return get_stat_value(StatData.STAT_TYPE.ENERGY)

func get_max_energy():
	return get_stat_max_value(StatData.STAT_TYPE.ENERGY)

func get_evasion():
	return get_stat_value(StatData.STAT_TYPE.EVASION)

func get_critical_chance():
	return get_stat_value(StatData.STAT_TYPE.CRITICAL_CHANCE)

func get_critical_damage():
	return get_stat_value(StatData.STAT_TYPE.CRITICAL_DAMAGE)

func get_summary()->String:
	var summary:String = ""

	if statusEffectList.size()>0 or passiveList.size()>0:
		summary = summary + "\nEffects: "
		for statusEffect in statusEffectList:
			summary = summary + statusEffect.data.get_display_name() + " "

		for passive in passiveList:
			summary = summary + passive.data.get_display_name() + " "

	return summary

func set_sprite(spritePath:String):
	var root_node:Node = self
	var mySprite:Sprite2D = root_node as Sprite2D
	mySprite.texture = load(spritePath)

func clean_up_on_death():
	if animPlayer!=null:
		animPlayer.play("Death")
	else:
		set_sprite(DEATH_SPRITE_PATH)
