
class_name ActionSpawnEffect extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var spawnEffectData:ActionSpawnEffectData = actionData as ActionSpawnEffectData

	var parentNode:Node = null
	var position:Vector2 = character.cell.pos
	if spawnEffectData.parent:
		parentNode = character
		position = Vector2.ZERO

	var charSpecificID:String = str(character.charId) + "_" + spawnEffectData.effectId
	GameGlobals.effectManager.spawn_effect(charSpecificID, spawnEffectData.effectPath, position, parentNode, spawnEffectData.lifetime)
