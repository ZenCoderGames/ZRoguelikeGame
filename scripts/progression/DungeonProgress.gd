class_name DungeonProgress

var numEnemiesKilled:int
var numMinibossesKilled:int
var numFloorsCompleted:int

const XP_PER_ENEMY:int = 1

var enemyKilledList:Array
var totalXPEarned:int

func _init():
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	CombatEventManager.connect("OnAnyCharacterDeath",Callable(self,"_on_any_character_death"))

func _on_dungeon_init():
	enemyKilledList.clear()
	totalXPEarned = 0

func _on_any_character_death(character:Character):
	if character is EnemyCharacter:
		enemyKilledList.append(character.charData)
		totalXPEarned = totalXPEarned + character.charData.xp

func get_progress()->int:
	return totalXPEarned

func get_progress_description()->String:
		return str("Souls Collected: ", totalXPEarned)
