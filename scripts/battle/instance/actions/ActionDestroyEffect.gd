
class_name ActionDestroyEffect extends Action

func _init(actionData,parentChar):
	super(actionData, parentChar)
	pass

func execute():
	var destroyEffectData:ActionDestroyEffectData = actionData as ActionDestroyEffectData

	var charSpecificID:String = str(character.charId) + "_" + destroyEffectData.effectId
	GameGlobals.effectManager.destroy_effect(charSpecificID)
