extends Node

class_name EffectManager

var effectList:Array

func _init():
	pass

func spawn_effect(path:String, pos:Vector2, parent:Node=null):
	var effectPrefab := load(str("res://", path))
	var newEffect = effectPrefab.instance()
	newEffect.position = pos
	if parent==null:
		self.add_child(newEffect)
	else:
		parent.add_child(newEffect)
	effectList.append(newEffect)
	return newEffect

func remove_effect(effectObj):
	effectList.erase(effectObj)
	effectObj.queue_free()
