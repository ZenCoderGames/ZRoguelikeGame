class_name ActionTypes

static func create(actionData:ActionData, parentChar):
	if actionData.type==ActionMoveData.ID:
		return ActionMove.new(actionData, parentChar)
	elif actionData.type==ActionAttackData.ID:
		return ActionAttack.new(actionData, parentChar)
	elif actionData.type==ActionFindTargetsData.ID:
		return ActionFindTargets.new(actionData, parentChar)
	elif actionData.type==ActionDoDamageToTargetsData.ID:
		return ActionDoDamageToTargets.new(actionData, parentChar)
	elif actionData.type==ActionSetStatusData.ID:
		return ActionSetStatus.new(actionData, parentChar)
	elif actionData.type==ActionLifeDrain.ID:
		return ActionLifeDrain.new(actionData, parentChar)

	print_debug("[ERROR] Invalid Action Type", actionData.type)
	return null
