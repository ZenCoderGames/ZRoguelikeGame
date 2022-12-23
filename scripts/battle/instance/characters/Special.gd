class_name Special

var character
var data:SpecialData
var timelineActions:Array = []
var currentCount:int
var isAvailable:bool

func _init(parentChar, specialData:SpecialData):
	character = parentChar
	data = specialData
	_reset()

	for actionData in data.timeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

	CombatEventManager.register_for_conditional_events(data.triggerConditions, self, character)
	Dungeon.connect("OnPlayerSpecialAbilityPressed", self, "_activate")

func activate_on_character_move(x, y):
	_increment()

func activate_on_target_or_item(targetOrSpell):
	_increment()

func activate_on_attacker(attacker, defender, data):
	if character==attacker:
		_increment()

func activate_on_defender(attacker, defender, data):
	if character==defender:
		_increment()

func _increment():
	currentCount = currentCount + 1
	CombatEventManager.on_player_special_ability_progress((float(currentCount))/(float(data.count)))
	if currentCount==data.count:
		_make_available()

func _make_available():
	isAvailable = true
	CombatEventManager.on_player_special_ability_ready()

func _activate():
	for action in timelineActions:
		action.execute()
	_reset()

func _reset():
	isAvailable = false
	currentCount = 0
	CombatEventManager.on_player_special_ability_reset()
