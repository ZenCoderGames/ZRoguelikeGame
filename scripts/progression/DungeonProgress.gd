class_name DungeonProgress

var numEnemiesKilled:int
var numMinibossesKilled:int
var numFloorsCompleted:int

func _init():
    CombatEventManager.connect("OnAnyCharacterDeath",Callable(self,"_on_any_character_death"))

func _on_any_character_death(character:Character):
    if character is EnemyCharacter:
        numEnemiesKilled = numEnemiesKilled + 1
        var enemyChar:EnemyCharacter = character as EnemyCharacter
        if enemyChar.isMiniboss:
            numMinibossesKilled = numMinibossesKilled + 1