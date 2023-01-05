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
	var isCritical:bool = sourceChar.status.has_critical()
	if isCritical:
		finalDamage = finalDamage * 2
	if generateHits:
		emit_signal("OnPreHit", sourceChar, targetChar, finalDamage)
		sourceChar.lastHitTarget = targetChar

	if !targetChar.can_take_damage():
		if generateHits:
			targetChar.on_blocked_hit(sourceChar)
			emit_signal("OnBlockedHit", sourceChar, targetChar, finalDamage)
		return 0

	var prevHealth:int = targetChar.get_health()
	var targetHealth:int = targetChar.take_damage(sourceChar, finalDamage)

	sourceChar.successfulDamageThisFrame = prevHealth-targetHealth

	if targetHealth<=0:
		targetChar.die()
		sourceChar.lastKilledTarget = targetChar
		emit_signal("OnKill", sourceChar, targetChar, finalDamage)
		
	if generateHits:
		if targetHealth<prevHealth:
			targetChar.show_damage_from_hit(sourceChar, finalDamage, isCritical)
		emit_signal("OnTakeHit", sourceChar, targetChar, finalDamage)
		emit_signal("OnPostHit", sourceChar, targetChar, finalDamage)

	return finalDamage

func push(target, source, amount:int, awayFromSource:bool):
	if awayFromSource:
		var dirnX:int = (source.cell.col - target.cell.col) * amount
		var dirnY:int = (source.cell.row - target.cell.row) * amount

		target.move(-dirnX, -dirnY)
