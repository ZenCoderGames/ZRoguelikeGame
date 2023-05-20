
class_name ActionPush extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func can_execute()->bool:
	return true

func execute():
	var pushData:ActionPushData = actionData as ActionPushData

	var targets = character.get_targets()
	for target in targets:
		if !target.isDead:
			HitResolutionManager.push(target, character, pushData.amount, pushData.awayFromSource)
	
