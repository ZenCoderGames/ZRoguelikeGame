
class_name ActionLifeDrain extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func can_execute()->bool:
	if !super.can_execute():
		return false
		
	var targets:Array = character.get_targets()
	return targets.size()>0

func execute():
	var lifeDrainData:ActionLifeDrainData = actionData as ActionLifeDrainData

	var targets = character.get_targets()
	for target in targets:
		if !target.isDead:
			var targetCharHealth:int = target.get_health()
			var lifeDrainAmount:int = lifeDrainData.flatAmount
			if targetCharHealth<lifeDrainAmount:
				lifeDrainAmount = targetCharHealth
			character.modify_stat_value(StatData.STAT_TYPE.HEALTH, lifeDrainAmount)
			HitResolutionManager.do_hit(character, target, lifeDrainAmount, false)
