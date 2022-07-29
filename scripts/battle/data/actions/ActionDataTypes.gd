class_name ActionDataTypes

static func create(dataJS):
	var actionType = dataJS["type"]
	if actionType==ActionMoveData.ID:
		return ActionMoveData.new(dataJS)
	elif actionType==ActionAttackData.ID:
		return ActionAttackData.new(dataJS)

	print_debug("[ERROR] Invalid Action Type", actionType)
	return null
