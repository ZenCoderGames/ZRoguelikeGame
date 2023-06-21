class_name Spell

var character
var spellData:SpellData
var timelineActions:Array
var _cooldownTimer:int

func _init(spellDataDef,characterRef):
	character = characterRef
	spellData = spellDataDef
	for actionData in spellData.timeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

	_cooldownTimer = -1

func can_activate():
	return !is_on_cooldown()

func is_on_cooldown():
	return _cooldownTimer>=0 && GameGlobals.dungeon.turnsTaken-_cooldownTimer<spellData.cooldown

func activate():
	for action in timelineActions:
		if action.can_execute():
			action.execute()
	
	_cooldownTimer = GameGlobals.dungeon.turnsTaken

func get_remaining_cooldown():
	if _cooldownTimer==-1:
		return 0

	return spellData.cooldown - (GameGlobals.dungeon.turnsTaken-_cooldownTimer)
