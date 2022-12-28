extends Node

class_name EffectManager

var effectList:Array
var effectDict:Dictionary

func _init():
	GameGlobals.set_effect_manager(self)

func spawn_effect(id:String, path:String, pos:Vector2, parent:Node, lifetime:float):
	var effectPrefab := load(str("res://", path))
	var newEffect = effectPrefab.instance()
	newEffect.position = pos
	if parent==null:
		self.add_child(newEffect)
	else:
		parent.add_child(newEffect)
	effectList.append(newEffect)
	effectDict[id] = newEffect
	newEffect.init(id, lifetime)
	return newEffect

func destroy_effect(effectId:String):
	if effectDict.has(effectId):
		var effectObj = effectDict[effectId]
		effectList.erase(effectObj)
		effectDict.erase(effectId)
		effectObj.queue_free()
