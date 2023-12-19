extends Node

signal OnCombatInitialized()
signal OnStartTurn()
signal OnEndTurn()
signal OnEnemyMovedAdjacentToPlayer(enemy)
signal OnAnyCharacterMoved(char)
signal OnRoomCombatStarted(room)
signal OnRoomCombatEnded(room)
signal OnPlayerTurnCompleted()
signal OnAllEnemyTurnsCompleted()
signal OnAnyAttack(isKillingBlow)
signal OnPlayerSpecialAbilityReady(special)
signal OnPlayerSpecialAbilityActivated(special)
signal OnPlayerSpecialAbilityPressed(special)
signal OnPlayerSpecialAbilityFailedToActivate(special)
signal OnToggleInventory()
signal OnShowInfo(title, content)
signal OnHideInfo()
signal OnTouchButtonPressed(dirn)
signal OnSkipTurnPressed()
signal OnDetailInfoShow(strVal, duration)
signal OnAnyCharacterDeath(character)
signal OnConsumeItem(itemData)
signal OnLevelUpAbilitySelected(abilityData)
signal ShowUpgrade(upgradeType)
signal ShowVendor(vendorChar, vendorData)
signal OnVendorItemSelected(abilityData)
signal OnVendorClosed()

func register_for_conditional_events(triggerConditions:Array, object, parentCharacter:Character):
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_PRE_ATTACK):
		parentCharacter.connect("OnPreAttack",Callable(object,"activate_on_parentCharacter_attack"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_POST_ATTACK):
		parentCharacter.connect("OnPostAttack",Callable(object,"activate_on_parentCharacter_attack"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_PRE_HIT):
		HitResolutionManager.connect("OnPreHit",Callable(object,"activate_on_attacker"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_POST_HIT):
		HitResolutionManager.connect("OnPostHit",Callable(object,"activate_on_attacker"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_BLOCKED_HIT):
		HitResolutionManager.connect("OnBlockedHit",Callable(object,"activate_on_defender"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_TAKE_HIT):
		HitResolutionManager.connect("OnTakeHit",Callable(object,"activate_on_defender"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_KILL):
		HitResolutionManager.connect("OnKill",Callable(object,"activate_on_attacker"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_DEATH):
		parentCharacter.connect("OnDeath",Callable(object,"activate"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_START_TURN):
		connect("OnStartTurn",Callable(object,"activate"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_END_TURN):
		connect("OnEndTurn",Callable(object,"activate"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_MOVE):
		parentCharacter.connect("OnCharacterMoveToCell",Callable(object,"activate_on_parentCharacter_move"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_SPELL_ACTIVATE):
		parentCharacter.equipment.connect("OnSpellActivated",Callable(object,"activate_on_parentCharacter_spell"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_SPECIAL_ACTIVATE):
		parentCharacter.connect("OnAnySpecialActivated",Callable(object,"activate"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_ADD_STATUS_EFFECT_TO_SELF):
		parentCharacter.connect("OnStatusEffectAdded",Callable(object,"activate_on_add_status_effect"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_ADD_STATUS_EFFECT_TO_ENEMY):
		parentCharacter.connect("OnStatusEffectAddedToEnemy",Callable(object,"activate_on_add_status_effect"))
	if triggerConditions.has(Constants.TRIGGER_CONDITION.ON_NEAR_ENEMY):
		parentCharacter.connect("OnNearEnemy",Callable(object,"activate"))

func on_room_combat_started(room):
	emit_signal("OnRoomCombatStarted", room)

func on_room_combat_ended(room):
	emit_signal("OnRoomCombatEnded", room)

func on_all_enemy_turn_completed(_room):
	emit_signal("OnAllEnemyTurnsCompleted")

func on_any_attack(entity):
	emit_signal("OnAnyAttack", entity)

func on_show_info(title:String, content:String):
	emit_signal("OnShowInfo", title, content)

func on_hide_info():
	emit_signal("OnHideInfo")

func clean_up():
	#Utils.clean_up_all_signals(self)
	pass

func on_touch_button_pressed(dirn):
	emit_signal("OnTouchButtonPressed", dirn)

func on_skip_turn_pressed():
	emit_signal("OnSkipTurnPressed")
