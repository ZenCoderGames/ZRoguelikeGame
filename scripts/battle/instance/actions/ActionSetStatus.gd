
class_name ActionSetStatus extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var actionSetStatusData:ActionSetStatusData = actionData as ActionSetStatusData
	if actionSetStatusData.invulnerable:
		character.status.set_invulnerable(actionSetStatusData.invulnerable)
	if actionSetStatusData.rooted:
		character.status.set_rooted(actionSetStatusData.rooted)
	if actionSetStatusData.untargetable:
		character.status.set_untargetable(actionSetStatusData.untargetable)
	if actionSetStatusData.evasive:
		character.status.set_evasive(actionSetStatusData.evasive)
	if actionSetStatusData.uninterruptible:
		character.status.set_uninterruptible(actionSetStatusData.uninterruptible)
	if actionSetStatusData.immovable:
		character.status.set_immovable(actionSetStatusData.immovable)
	if actionSetStatusData.stunned:
		character.status.set_stunned(actionSetStatusData.stunned)
	if actionSetStatusData.invisible:
		character.status.set_invisible(actionSetStatusData.invisible)
	if actionSetStatusData.critical:
		character.status.set_critical(actionSetStatusData.critical)
