extends Node

class_name EffectInstance

var effectId:String

func _init():
	pass

func init(id:String, lifetime:float):
	effectId = id
	if lifetime>-1:
		yield(get_tree().create_timer(lifetime), "timeout")
		GameGlobals.effectManager.destroy_effect(effectId)
