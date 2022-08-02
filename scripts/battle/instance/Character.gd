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
var actions:Array = []
var items:Array = []

var currentRoom = null
var prevRoom = null

signal OnCharacterMove(x, y)
signal OnCharacterRoomChanged(newRoom)
signal OnHealthChanged(displayName, newVal, maxHealth)
signal OnDeath()

var originalColor:Color

func init(charData, teamVal):
	displayName = charData.displayName
	team = teamVal
	originalColor = self.self_modulate
	if team==Constants.TEAM.ENEMY:
		damageText.self_modulate = Dungeon.battleInstance.playerDamageColor
	else:
		damageText.self_modulate = Dungeon.battleInstance.enemyDamageColor

	# Stats
	for statData in charData.statDataList:
		var stat = Stat.new(statData)
		if stat!=null:
			stats.append(stat)

	# Actions
	for actionData in charData.actionDataList:
		var action = ActionTypes.create(actionData, self)
		if action!=null:
			actions.append(action)

	actions.sort_custom(self, "sort_actions_by_priority")

func sort_actions_by_priority(a, b):
	return a.actionData.priority >= b.actionData.priority

func get_action(actionType):
	for action in actions:
		if action.actionData.type == actionType:
			return action

	return null

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

# STATS
func get_stat_value(statType):
	var statValue:int = 0
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			statValue = statValue + stat.value
	# iterate through items
	for item in items:
		for statData in item.data.statDataList:
			if statData.type == statType:
				statValue = statValue + statData.value
	
	return statValue

func get_stat_base_value(statType):
	var statBaseValue:int = 0
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			statBaseValue = statBaseValue + stat.baseValue
	# iterate through items
	for item in items:
		for statData in item.data.statDataList:
			if statData.type == statType:
				statBaseValue = statBaseValue + statData.baseValue

	return statBaseValue

func modify_stat(statType, statModifier):
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			statModifier.modify(stat)

func modify_stat_value(statType, modifierValue):
	# iterate through char
	for stat in stats:
		if stat.type == statType:
			stat.value = stat.value + modifierValue
			return stat.value

	print("ERROR: Can't find stat type - ", statType)
	return null

# ITEMS
func add_item(itemToAdd):
	items.append(itemToAdd)

func remove_item(itemToRemove):
	var matchingItems:Array = []
	for item in items:
		if item == itemToRemove:
			matchingItems.append(itemToRemove)

	for item in matchingItems:
		items.erase(item)

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
		entity.take_damage(self, get_stat_value(StatData.STAT_TYPE.DAMAGE))

func take_damage(entity, dmg):
	var health = modify_stat_value(StatData.STAT_TYPE.HEALTH, -dmg)
	var maxHealth = get_stat_base_value(StatData.STAT_TYPE.HEALTH)
	if health<=0:
		isDead = true
		Dungeon.emit_signal("OnKill", entity, self)
		show_hit(entity, dmg)
		yield(get_tree().create_timer(0.1), "timeout")
		die()
		emit_signal("OnHealthChanged", displayName, 0, maxHealth)
		emit_signal("OnDeath")
	else:
		show_hit(entity, dmg)
		Dungeon.emit_signal("OnAttack", entity, self, dmg)
		emit_signal("OnHealthChanged", displayName, health, maxHealth)

func die():
	cell.room.enemy_died(self)
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
		
	damageText.visible = true
	damageText.text = str(dmg)

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
	yield(get_tree().create_timer(0.35), "timeout")
	damageText.visible = false
	
func update():
	pass

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
