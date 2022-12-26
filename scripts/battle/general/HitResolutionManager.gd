extends Node

signal OnPreHit(sourceChar, defender, dmg)
signal OnBlockedHit(sourceChar, defender, dmg)
signal OnTakeHit(sourceChar, defender, dmg)
signal OnPostHit(sourceChar, defender, dmg)
signal OnKill(sourceChar, defender, dmg)

func _init():
	pass

func do_hit(sourceChar, targetChar, damage, generateHits=true):
	var finalDamage:int = damage
	if generateHits:
		emit_signal("OnPreHit", sourceChar, targetChar, damage)
		sourceChar.lastHitTarget = targetChar

	if !targetChar.can_take_damage():
		if generateHits:
			targetChar.on_blocked_hit(sourceChar)
			emit_signal("OnBlockedHit", sourceChar, targetChar, finalDamage)
		return 0

	var prevHealth:int = targetChar.get_health()
	var targetHealth:int = targetChar.take_damage(sourceChar, damage)
	if targetHealth<=0:
		targetChar.die()
		sourceChar.lastKilledTarget = targetChar
		emit_signal("OnKill", sourceChar, targetChar, finalDamage)
		
	if generateHits:
		if targetHealth<prevHealth:
			targetChar.show_damage_from_hit(sourceChar, damage)
		emit_signal("OnTakeHit", sourceChar, targetChar, finalDamage)
		emit_signal("OnPostHit", sourceChar, targetChar, finalDamage)

	return finalDamage
