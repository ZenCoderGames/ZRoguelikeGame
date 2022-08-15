extends Action

class_name ActionSetStatus

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
    var actionSetStatusData:ActionSetStatusData = actionData as ActionSetStatusData
    if actionSetStatusData.invulnerable:
	    character.status.set_invulnerable(true, actionSetStatusData.numTurns)
    if actionSetStatusData.rooted:
        character.status.set_rooted(true, actionSetStatusData.numTurns)
    if actionSetStatusData.untargetable:
        character.status.set_untargetable(true, actionSetStatusData.numTurns)
    if actionSetStatusData.evasive:
        character.status.set_evasive(true, actionSetStatusData.numTurns)
    if actionSetStatusData.uninterruptible:
        character.status.set_uninterruptible(true, actionSetStatusData.numTurns)
    if actionSetStatusData.immovable:
        character.status.set_immovable(true, actionSetStatusData.numTurns)
    if actionSetStatusData.stunned:
        character.status.set_stunned(true, actionSetStatusData.numTurns)