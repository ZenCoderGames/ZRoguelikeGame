class_name Spell

var spellData:SpellData
var timelineActions:Array

func _init(spellDataDef, character):
	spellData = spellDataDef
	for actionData in spellData.timeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

# add mana or stamina here
func can_activate():
	return true

func activate():
	for action in timelineActions:
		action.execute()
