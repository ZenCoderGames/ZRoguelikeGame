extends Node2D

class_name Upgrade

enum UPGRADE_TYPE { SHARED, CLASS_SPECIFIC, HYBRID }
@export var upgradeType:UPGRADE_TYPE

func activate():
	CombatEventManager.emit_signal("ShowUpgrade", upgradeType)

func get_display_name():
	if upgradeType==UPGRADE_TYPE.HYBRID:
		return "Hybrid Perk"

	if upgradeType==UPGRADE_TYPE.CLASS_SPECIFIC:
		return "Class Upgrade"
	
	return "General Upgrade"

func get_description():
	if upgradeType==UPGRADE_TYPE.HYBRID:
		return "This is a class specific or general perk"
		
	if upgradeType==UPGRADE_TYPE.CLASS_SPECIFIC:
		return "This is a class specific upgrade"
	
	return "This is a basic Upgrade"
