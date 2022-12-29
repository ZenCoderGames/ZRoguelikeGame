extends Action

class_name ActionPush

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
    var pushData:ActionPushData = actionData as ActionPushData

    var targets = character.get_targets()
    for target in targets:
        if !target.isDead:
            HitResolutionManager.push(target, character, pushData.amount, pushData.awayFromSource)
    