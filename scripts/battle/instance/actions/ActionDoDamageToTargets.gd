
class_name ActionDoDamageToTargets extends Action

func _init(actionData,parentChar):
	super(actionData, parentChar)
	pass

func can_execute()->bool:
	if !super.can_execute():
		return false
		
	if GameGlobals.battleInstance.pauseAIAttack and character.team == Constants.TEAM.ENEMY:
		return false

	return character.has_targets()

func execute():
	var doDamageToTargetsData:ActionDoDamageToTargetsData = actionData as ActionDoDamageToTargetsData

	var targets:Array = character.get_targets()
	var duplicateTargetList:Array = targets.duplicate()
	for target in duplicateTargetList:
		var damageVal:int = doDamageToTargetsData.damage
		if doDamageToTargetsData.useCharacterDamage:
			damageVal = character.get_damage()
		HitResolutionManager.do_hit(character, target, damageVal)
