# Character.gd
extends Node

class_name Character

onready var damageText:Label = get_node("DamageText")

var displayName: String = ""
var team: int = 0
var stamina: int = 0
var cell
var isDead:bool = false

var stats:Array = []
var moveAction:Action
var attackAction:Action

var status:CharacterStatus

var inventory:Inventory
var equipment:Equipment

var currentRoom = null
var prevRoom = null

var targetList:Array = []

var statusEffectList:Array = []
var passiveList:Array = []

signal OnCharacterMove(x, y)
signal OnCharacterMoveToCell()
signal OnCharacterRoomChanged(newRoom)
signal OnStatChanged(character)
signal OnDeath()

signal OnPreAttack(defender, dmg)
signal OnAttackConnect(defender, dmg)
signal OnPostAttack(defender, dmg)
signal OnHit(attacker, dmg)
var successfulDamageThisFrame:int

var originalColor:Color

func init(charData, teamVal):
	displayName = charData.displayName
	team = teamVal
	originalColor = self.self_modulate
	if team==Constants.TEAM.ENEMY:
		damageText.self_modulate = Dungeon.battleInstance.view.playerDamageColor
	else:
		damageText.self_modulate = Dungeon.battleInstance.view.enemyDamageColor

	# Stats
	for statData in charData.statDataList:
		var stat = Stat.new(statData)
		if stat!=null:
			stats.append(stat)

	# Actions
	moveAction = ActionTypes.create(charData.moveAction, self)
	attackAction = ActionTypes.create(charData.attackAction, self)

	# Status
	status = CharacterStatus.new()

	inventory = Inventory.new(self)
	equipment = Equipment.new(self)

# MOVEMENT
func move(x, y):
	if x==0 and y==0:
		return

	var newR:int = cell.row + y
	var newC:int = cell.col + x
	
	var success:bool = cell.room.move_entity(self, cell, newR, newC)
	if success:
		emit_signal("OnCharacterMove", x, y)

func move_to_cell(newCell):
	cell = newCell
	self.position = Vector2(cell.pos.x, cell.pos.y)
	if currentRoom != cell.room:
		prevRoom = currentRoom
		emit_signal("OnCharacterRoomChanged", cell.room)
	currentRoom = cell.room
	emit_signal("OnCharacterMoveToCell")

# STATS
func get_stat_value(statType):
	var statValue:int = 0
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			statValue = statValue + stat.value
	# iterate through items
	statValue = statValue + equipment.get_stat_bonus_from_equipped_items(statType)
	
	return statValue

func get_stat_base_value(statType):
	var statBaseValue:int = 0
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			statBaseValue = statBaseValue + stat.baseValue
	# iterate through items
	statBaseValue = statBaseValue + equipment.get_stat_base_bonus_from_equipped_items(statType)

	return statBaseValue

func modify_stat_value(statType, modifierValue):
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			stat.value = stat.value + modifierValue
			stat.value = clamp(stat.value, 0, stat.baseValue)
			emit_signal("OnStatChanged", self)
			return stat.value

	print("ERROR: Can't find stat type - ", statType)
	return null

func modify_stat_value_from_modifier(statModifierData:StatModifierData):
	# iterate through char
	for stat in stats:
		if stat.type == statModifierData.type:
			stat.baseValue = stat.baseValue + statModifierData.baseValue
			stat.value = stat.value + statModifierData.baseValue
			stat.value = stat.value + statModifierData.value
			stat.value = clamp(stat.value, 0, stat.baseValue)
			emit_signal("OnStatChanged", self)
			return stat.value

	print("ERROR: Can't find stat type - ", statModifierData.type)
	return null

# ITEMS

# For testing when player goes over, they get the item
func pick_item(itemToAdd):
	inventory.add_item(itemToAdd)

# COMBAT
func attack(entity):
	if entity.is_class(self.get_class()):
		# shove towards
		var dirn:int = dirn_to_character(entity)
		if dirn==Constants.DIRN_TYPE.LEFT:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(5, 0), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.RIGHT:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(-5, 0), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.DOWN:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, -5), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)
		elif dirn==Constants.DIRN_TYPE.UP:
			Utils.create_return_tween_vector2(self, "position", self.position, self.position + Vector2(0, 5), 0.05, Tween.TRANS_BOUNCE, Tween.TRANS_LINEAR)

		yield(get_tree().create_timer(0.075), "timeout")
		var damageAmount:int = get_stat_value(StatData.STAT_TYPE.DAMAGE)
		emit_signal("OnPreAttack", entity, damageAmount)
		var damageDone = entity.take_damage(self, damageAmount)
		if damageDone:
			successfulDamageThisFrame = damageAmount
			emit_signal("OnAttackConnect", entity, damageAmount)
		emit_signal("OnPostAttack", entity, damageAmount)

func take_damage(attacker, dmg):
	if status.is_invulnerable():
		emit_signal("OnHit", attacker, dmg)
		show_blocked_text(attacker)
		return false

	var health = modify_stat_value(StatData.STAT_TYPE.HEALTH, -dmg)
	emit_signal("OnHit", attacker, dmg)
	if health<=0:
		isDead = true
		Dungeon.emit_signal("OnKill", attacker, self)
		show_hit(attacker, dmg)
		yield(get_tree().create_timer(0.1), "timeout")
		die()
		emit_signal("OnDeath")
	else:
		show_hit(attacker, dmg)
		Dungeon.emit_signal("OnAttack", attacker, self, dmg)

	return true

func die():
	currentRoom.enemy_died(self)
	if cell.entityObject!=null:
		cell.entityObject.hide()
	cell.clear_entity_on_death()

func show_hit(entity, dmg):
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
	show_damage_text(entity, dmg)
	#Utils.do_hit_pause()

func show_hit_flash():
	self.self_modulate = Color.white
	yield(get_tree().create_timer(0.2), "timeout")
	self.self_modulate = originalColor
	
func show_damage_text(entity, dmg):
	if entity==null:
		return
	
	"""if(entity.team == Constants.TEAM.ENEMY):
		damageText.modulate = Dungeon.battleInstance.view.playerDamageColor
	else:
		damageText.modulate = Dungeon.battleInstance.view.enemyDamageColor"""
	damageText.visible = true
	damageText.text = str(dmg)
	_create_damage_text_tween(entity)
	yield(get_tree().create_timer(0.35), "timeout")
	damageText.visible = false

func show_blocked_text(entity):
	"""if(entity.team == Constants.TEAM.PLAYER):
		damageText.modulate = Dungeon.battleInstance.view.playerDamageColor
	else:
		damageText.modulate = Dungeon.battleInstance.view.enemyDamageColor"""
	damageText.visible = true
	damageText.text = "Immune"
	_create_damage_text_tween(entity)
	yield(get_tree().create_timer(0.5), "timeout")
	damageText.visible = false

func _create_damage_text_tween(entity):
	var dirn:int = dirn_to_character(entity)
	# damage text
	var startPos:Vector2 = Vector2(0,-30)
	var endPos:Vector2 = Vector2(10,-60)
	if dirn==Constants.DIRN_TYPE.RIGHT:
		startPos = Vector2(0, -5)
		endPos = Vector2(20, -3)
	elif dirn==Constants.DIRN_TYPE.LEFT:
		startPos = Vector2(-30, 0)
		endPos = Vector2(-40, 0)
	elif dirn==Constants.DIRN_TYPE.UP:
		startPos = Vector2(0, -30)
		endPos = Vector2(0,-40)
	elif dirn==Constants.DIRN_TYPE.DOWN:
		startPos = Vector2(0, 0)
		endPos = Vector2(10, 20)
	Utils.create_tween_vector2(damageText, "rect_position", startPos, endPos, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)

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

# STATUS EFFECTS
func add_status_effect(statusEffectData:StatusEffectData):
	statusEffectList.append(StatusEffect.new(self, statusEffectData))

func remove_status_effect(statusEffect):
	statusEffectList.erase(statusEffect)

# PASSIVES
func add_passive(passiveData:PassiveData):
	passiveList.append(Passive.new(self, passiveData))

func remove_passive(passiveData):
	passiveList.erase(passiveData)

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
