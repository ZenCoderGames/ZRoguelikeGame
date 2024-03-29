extends Resource
class_name PlayerData

@export var currentXP:int
@export var totalXP:int
@export var hero2Unlocked:bool
@export var hero3Unlocked:bool
@export var heroClasslessUnlocked:bool

func clear():
	currentXP = 0
	totalXP = 0
	hero2Unlocked = false
	hero3Unlocked = false
	heroClasslessUnlocked = false
