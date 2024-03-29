
class_name ActionModifyStatusEffect extends Action

var StatusEffectModifier = load("res://scripts/battle/instance/characters/statusEffects/StatusEffectModifier.gd")

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var data:ActionModifyStatusEffectData = actionData as ActionModifyStatusEffectData
	
	var statusEffectModifier = StatusEffectModifier.new(data)
	
	character.add_status_effect_modifier(statusEffectModifier)
