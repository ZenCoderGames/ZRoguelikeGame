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
	elif actionType==ActionSetStatusData.ID:
		return ActionSetStatusData.new(dataJS)
	elif actionType==ActionLifeDrainData.ID:
		return ActionLifeDrainData.new(dataJS)
	elif actionType==ActionLifeStealData.ID:
		return ActionLifeStealData.new(dataJS)
	elif actionType==ActionApplyStatusEffectData.ID:
		return ActionApplyStatusEffectData.new(dataJS)
	elif actionType==ActionAddStatModifierData.ID:
		return ActionAddStatModifierData.new(dataJS)
	elif actionType==ActionModifyVisualData.ID:
		return ActionModifyVisualData.new(dataJS)

	print_debug("[ERROR] Invalid Action Data Type", actionType)
	return null
