class_name ActionDataTypes

static func create(dataJS):
	var actionType = dataJS["type"]
	if actionType==ActionMoveData.ID:
		return ActionMoveData.new(dataJS)
	elif actionType==ActionAttackData.ID:
		return ActionAttackData.new(dataJS)
	elif actionType==ActionFindTargetsData.ID:
		return ActionFindTargetsData.new(dataJS)
	elif actionType==ActionDoDamageToTargetsData.ID:
		return ActionDoDamageToTargetsData.new(dataJS)

	print_debug("[ERROR] Invalid Action Data Type", actionType)
	return null
