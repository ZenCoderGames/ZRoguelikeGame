extends Resource
class_name PlayerHeroData

@export var unlocked:bool
@export var charId:String
@export var prevXp:int
@export var xp:int
@export var levelsCompleted:Array[String]

var MAX_XP:int = 1000

func init(charIdVal:String, xpVal:int):
	charId = charIdVal
	prevXp = xpVal
	xp = xpVal

func unlock():
	unlocked = true

func level_completed(levelId:String):
	levelsCompleted.append(levelId)

func add_xp(val:int):
	prevXp = xp
	xp = xp + val
	if xp>MAX_XP:
		xp = MAX_XP
	
func set_hero_xp_as_seen():
	prevXp = xp

func get_prev_xp_for_next_level():
	return 100 - (prevXp%100)

func get_xp_for_next_level():
	return (xp%100)

func get_level():
	return 1 + floor(xp/100)

func reset():
	unlocked = false
	xp = 0
	levelsCompleted.clear()
