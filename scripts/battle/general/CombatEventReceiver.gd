
class_name CombatEventReceiver

var _parentReturnFunc:FuncRef
var _character

func _init(triggerConditions:Array, character, returnFunc:FuncRef):
	_parentReturnFunc = returnFunc
	_character = character
	CombatEventManager.register_for_conditional_events(triggerConditions, self, character)

func activate_on_parentCharacter_attack(attacker):
	activate()

func activate_on_parentCharacter_move():
	activate()

func activate_on_target_or_item(targetOrSpell):
	activate()

func activate_on_attacker(attacker, defender, data):
	if _character==attacker:
		activate()

func activate_on_defender(attacker, defender, data):
	if _character==defender:
		activate()	

func activate():
	_parentReturnFunc.call_func()
