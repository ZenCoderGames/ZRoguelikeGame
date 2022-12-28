extends Action

class_name ActionSpawnEffect

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
    var spawnEffectData:ActionSpawnEffectData = actionData as ActionSpawnEffectData

    var parentNode:Node = null
    var position:Vector2 = character.cell.pos
    if spawnEffectData.parent:
        parentNode = character
        position = Vector2.ZERO

    var charSpecificID:String = str(character.charId) + "_" + spawnEffectData.effectId
    GameGlobals.effectManager.spawn_effect(charSpecificID, spawnEffectData.effectPath, position, parentNode, spawnEffectData.lifetime)
