extends Node

func register_for_conditional_events(triggerConditions:Array, object, parentCharacter:Character):
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_PRE_ATTACK):
		parentCharacter.connect("OnPreAttack", object, "_on_parentCharacter_attack")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_POST_ATTACK):
		parentCharacter.connect("OnPostAttack", object, "_on_parentCharacter_attack")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_PRE_HIT):
		HitResolutionManager.connect("OnPreHit", object, "activate_on_attacker")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_POST_HIT):
		HitResolutionManager.connect("OnPostHit", object, "activate_on_attacker")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_BLOCKED_HIT):
		HitResolutionManager.connect("OnBlockedHit", object, "activate_on_defender")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_TAKE_HIT):
		HitResolutionManager.connect("OnTakeHit", object, "activate_on_defender")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_KILL):
		HitResolutionManager.connect("OnKill", object, "activate_on_attacker")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_DEATH):
		parentCharacter.connect("OnDeath", object, "activate")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_START_TURN):
		Dungeon.connect("OnStartTurn", object, "activate")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_END_TURN):
		Dungeon.connect("OnEndTurn", object, "activate")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_MOVE):
		parentCharacter.connect("OnparentCharacterMove", object, "activate_on_parentCharacter_move")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_SPELL_ACTIVATE):
		parentCharacter.equipment.connect("OnSpellActivated", object, "activate_on_target_or_item")

