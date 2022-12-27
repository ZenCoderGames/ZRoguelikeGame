
class_name CombatEventReceiver

var _parentReturnFunc:FuncRef
var _character

func _init(triggerConditions:Array, character, returnFunc:FuncRef):
	_parentReturnFunc = returnFunc
	_character = character
	CombatEventManager.register_for_conditional_events(triggerConditions, self, character)

func activate_on_parentCharacter_attack(_attacker):
	activate()

func activate_on_parentCharacter_move():
	activate()

func activate_on_target_or_item(_targetOrSpell):
	activate()

func activate_on_attacker(_attacker, _defender, _data):
	if _character==_attacker:
		activate()

func activate_on_defender(_attacker, _defender, _data):
	if _character==_defender:
		activate()	

func activate():
	_parentReturnFunc.call_func()
