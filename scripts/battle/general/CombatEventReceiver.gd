
class_name CombatEventReceiver

var _parentReturnFunc:FuncRef
var _character
var _triggerConditionParams:Dictionary

func _init(triggerConditions:Array, triggerConditionParams:Dictionary, character, returnFunc:FuncRef):
	_parentReturnFunc = returnFunc
	_character = character
	_triggerConditionParams = triggerConditionParams
	CombatEventManager.register_for_conditional_events(triggerConditions, self, character)

func activate_on_parentCharacter_attack(_attacker):
	_checkForConditionsAndActivate()

func activate_on_parentCharacter_move():
	_checkForConditionsAndActivate()

func activate_on_parentCharacter_spell(_spellItem):
	_checkForConditionsAndActivate()

func activate_on_attacker(_attacker, _defender, _data):
	if _character==_attacker:
		_checkForConditionsAndActivate()

func activate_on_defender(_attacker, _defender, _data):
	if _character==_defender:
		_checkForConditionsAndActivate()	

func activate_on_add_status_effect(_sourceCharacterOfStatusEffect, statusEffect):
	if statusEffect.data.id == _triggerConditionParams["statusEffectId"]:
		activate()

func _checkForConditionsAndActivate():
	if _triggerConditionParams.size()==0:
		activate()
	else:
		if _triggerConditionParams.has("statusEffectId"):
			if _character.has_status_effect(_triggerConditionParams["statusEffectId"]):
				activate()

func activate():
	_parentReturnFunc.call_func()
