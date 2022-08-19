extends Node

class_name HitResolutionManager

signal OnAttack(attacker, defender, dmg)
signal OnPreHit(sourceChar, defender, dmg)
signal OnBlockedHit(sourceChar, defender, dmg)
signal OnPostHit(sourceChar, defender, dmg)
signal OnKill(sourceChar, defender)

func _init():
	pass

func do_hit(sourceChar, targetChar, damage):
	var finalDamage:int = damage
	emit_signal("OnPreHit", sourceChar, targetChar, damage)

	if targetChar.status.is_invulnerable():
		targetChar.on_blocked_hit(sourceChar)
		emit_signal("OnBlockedHit", sourceChar, targetChar, finalDamage)
		return 0

	targetChar.show_damage_from_hit(sourceChar, damage)

	var targetHealth:int = targetChar.modify_stat_value(StatData.STAT_TYPE.HEALTH, -damage)
	if targetHealth<=0:
		emit_signal("OnKill", sourceChar, targetChar)
		targetChar.die()
	else:
		emit_signal("OnPostHit", sourceChar, targetChar, finalDamage)

	return finalDamage
