
class_name ActionModifyAttack extends Action

func _init(actionData,parentChar):
	super(actionData, parentChar)
	pass

func execute():
	var data:ActionModifyAttackData = actionData as ActionModifyAttackData
	
	if data.removeModifier:
		character.remove_attack_modifier()
	else:
		var attackModifier:AttackModifier = AttackModifier.new(data.damageMultiplier, data.applyToTargets)
		character.add_attack_modifier(attackModifier)
