extends Resource
class_name PlayerHeroData

@export var unlocked:bool
@export var charId:String
@export var levelsCompleted:Array[String]

func unlock():
	unlocked = true

func level_completed(levelId:String):
	levelsCompleted.append(levelId)

func reset():
	unlocked = false
	levelsCompleted.clear()
