
class_name ActionSpawnCharacter extends Action

func _init(actionData,parentChar):
	super(actionData, parentChar)
	pass

func execute():
	var spawnCharacterData:ActionSpawnCharacterData = actionData as ActionSpawnCharacterData

	for i in spawnCharacterData.count:
		var enemy:EnemyCharacter = character.cell.room.generate_enemy(spawnCharacterData.characterId)
		if enemy!=null:
			enemy.add_status_effect(character, GameGlobals.dataManager.get_status_effect_data("STATUS_EFFECT_STUN"))
