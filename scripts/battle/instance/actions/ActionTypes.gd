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
	elif actionData.type==ActionLifeDrainData.ID:
		return ActionLifeDrain.new(actionData, parentChar)
	elif actionData.type==ActionLifeStealData.ID:
		return ActionLifeSteal.new(actionData, parentChar)
	elif actionData.type==ActionAddStatusEffectData.ID:
		return ActionAddStatusEffect.new(actionData, parentChar)
	elif actionData.type==ActionAddStatModifierData.ID:
		return ActionAddStatModifier.new(actionData, parentChar)
	elif actionData.type==ActionModifyVisualData.ID:
		return ActionModifyVisual.new(actionData, parentChar)
	elif actionData.type==ActionSpawnEffectData.ID:
		return ActionSpawnEffect.new(actionData, parentChar)
	elif actionData.type==ActionDestroyEffectData.ID:
		return ActionDestroyEffect.new(actionData, parentChar)
	elif actionData.type==ActionAddPassiveData.ID:
		return ActionAddPassive.new(actionData, parentChar)
	elif actionData.type==ActionRemovePassiveData.ID:
		return ActionRemovePassive.new(actionData, parentChar)
	elif actionData.type==ActionPushData.ID:
		return ActionPush.new(actionData, parentChar)
	elif actionData.type==ActionModifySpecialData.ID:
		return ActionModifySpecial.new(actionData, parentChar)
	elif actionData.type==ActionModifyStatusEffectData.ID:
		return ActionModifyStatusEffect.new(actionData, parentChar)
	elif actionData.type==ActionModifyAttackData.ID:
		return ActionModifyAttack.new(actionData, parentChar)
	elif actionData.type==ActionPlayAudioData.ID:
		return ActionPlayAudio.new(actionData, parentChar)
	elif actionData.type==ActionReviveData.ID:
		return ActionRevive.new(actionData, parentChar)
	elif actionData.type==ActionHideCharacterUIData.ID:
		return ActionHideCharacterUI.new(actionData, parentChar)
	elif actionData.type==ActionShowCharacterUITextData.ID:
		return ActionShowCharacterUIText.new(actionData, parentChar)
	elif actionData.type==ActionSpawnCharacterData.ID:
		return ActionSpawnCharacter.new(actionData, parentChar)

	print_debug("[ERROR] Invalid Action Type", actionData.type)
	return null
