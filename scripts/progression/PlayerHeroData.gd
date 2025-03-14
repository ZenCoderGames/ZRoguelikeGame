extends Resource
class_name PlayerHeroData

@export var unlocked:bool
@export var enabledSkills:Array[String]
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

func is_skill_enabled(skillId:String):
	return enabledSkills.has(skillId)

func can_enable_skill(skillId:String):
	var currentLevel:int = get_level()
	var currentSkillCost:int = get_enabled_skill_cost()
		
	currentSkillCost = currentSkillCost + GameGlobals.dataManager.get_skill_data(skillId).enableCost
		
	return currentSkillCost<=currentLevel

func get_enabled_skill_cost():
	var currentSkillCost:int = 0
	for currentSkillId in enabledSkills:
		currentSkillCost = currentSkillCost + GameGlobals.dataManager.get_skill_data(currentSkillId).enableCost
	return currentSkillCost
	
func get_remaining_skill_threshold():
	var currentLevel:int = get_level()
	var currentSkillCost:int = get_enabled_skill_cost()
	
	return currentLevel - currentSkillCost

func get_enabled_skills()->Array[String]:
	return enabledSkills

func enable(skillId:String):
	enabledSkills.append(skillId)
	
func disable(skillId:String):
	enabledSkills.erase(skillId)
	
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
	enabledSkills.clear()
