extends Node

signal OnStartTurn()
signal OnEndTurn()
signal OnEnemyMovedAdjacentToPlayer(enemy)
signal OnRoomCombatStarted(room)
signal OnRoomCombatEnded(room)
signal OnPlayerTurnCompleted()
signal OnAllEnemyTurnsCompleted()
signal OnAnyAttack(isKillingBlow)
signal OnPlayerSpecialAbilityProgress(percent)
signal OnPlayerSpecialAbilityReady()
signal OnPlayerSpecialAbilityPressed()
signal OnPlayerSpecialAbilityReset()
signal OnToggleInventory()
signal OnShowInfo(title, content)
signal OnHideInfo()
signal OnTouchButtonPressed(dirn)
signal OnSkipTurnPressed()
signal OnDetailInfoShow(strVal, duration)

func register_for_conditional_events(triggerConditions:Array, object, parentCharacter:Character):
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_PRE_ATTACK):
		parentCharacter.connect("OnPreAttack", object, "activate_on_parentCharacter_attack")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_POST_ATTACK):
		parentCharacter.connect("OnPostAttack", object, "activate_on_parentCharacter_attack")
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
		connect("OnStartTurn", object, "activate")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_END_TURN):
		connect("OnEndTurn", object, "activate")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_MOVE):
		parentCharacter.connect("OnCharacterMoveToCell", object, "activate_on_parentCharacter_move")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_SPELL_ACTIVATE):
		parentCharacter.equipment.connect("OnSpellActivated", object, "activate_on_parentCharacter_spell")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_ADD_STATUS_EFFECT_TO_SELF):
		parentCharacter.connect("OnStatusEffectAdded", object, "activate_on_add_status_effect")
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_ADD_STATUS_EFFECT_TO_ENEMY):
		parentCharacter.connect("OnStatusEffectAddedToEnemy", object, "activate_on_add_status_effect")

func on_room_combat_started(room):
	emit_signal("OnRoomCombatStarted", room)

func on_room_combat_ended(room):
	emit_signal("OnRoomCombatEnded", room)

func on_all_enemy_turn_completed(_room):
	emit_signal("OnAllEnemyTurnsCompleted")

func on_any_attack(isKillingBlow):
	emit_signal("OnAnyAttack", isKillingBlow)

func on_show_info(title:String, content:String):
	emit_signal("OnShowInfo", title, content)

func on_hide_info():
	emit_signal("OnHideInfo")

func on_player_special_ability_progress(percent:float):
	emit_signal("OnPlayerSpecialAbilityProgress", percent)

func on_player_special_ability_ready():
	emit_signal("OnPlayerSpecialAbilityReady")

func on_player_special_ability_pressed():
	emit_signal("OnPlayerSpecialAbilityPressed")

func on_player_special_ability_reset():
	emit_signal("OnPlayerSpecialAbilityReset")

func clean_up():
	Utils.clean_up_all_signals(self)

func on_touch_button_pressed(dirn):
	emit_signal("OnTouchButtonPressed", dirn)

func on_skip_turn_pressed():
	emit_signal("OnSkipTurnPressed")
