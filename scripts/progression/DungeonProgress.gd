class_name DungeonProgress

var numEnemiesKilled:int
var numMinibossesKilled:int
var numFloorsCompleted:int

const MULTIPLIER_PER_FLOOR:float = 0.2

var enemyKilledList:Array
var enemyKillDict:Dictionary
var enemyXPEarned:int
var totalFloorsCompleted:int

func _init():
	_on_dungeon_init()
	CombatEventManager.connect("OnAnyCharacterDeathFinal",Callable(self,"_on_any_character_death"))

func _on_dungeon_init():
	enemyKilledList.clear()
	enemyKillDict.clear()
	enemyXPEarned = 0
	totalFloorsCompleted = 0

func on_dungeon_floor_completed():
	totalFloorsCompleted = totalFloorsCompleted + 1

func _on_any_character_death(character:Character):
	if character is EnemyCharacter:
		if enemyKillDict.has(character.charData):
			enemyKillDict[character.charData] = enemyKillDict[character.charData] + 1
		else:
			enemyKilledList.append(character.charData)
			enemyKillDict[character.charData] = 1
		enemyXPEarned = enemyXPEarned + character.charData.xp

func get_enemy_count(charData:CharacterData):
	return enemyKillDict[charData]

func get_progress()->int:
	return enemyXPEarned + totalFloorsCompleted * MULTIPLIER_PER_FLOOR * enemyXPEarned

func get_progress_description()->String:
	var dungeonProgressDesc:String = ""

	dungeonProgressDesc = str(dungeonProgressDesc, "Floors Completed: ", totalFloorsCompleted)
	dungeonProgressDesc = str(dungeonProgressDesc, " (+", totalFloorsCompleted * MULTIPLIER_PER_FLOOR * 100, "%)")
	dungeonProgressDesc = str(dungeonProgressDesc, "\nSouls Collected: ", get_progress())

	return dungeonProgressDesc
