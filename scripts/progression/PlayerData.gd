extends Resource
class_name PlayerData

@export var currentXP:int
@export var totalXP:int
@export var heroDataList:Array[PlayerHeroData]
var heroDataDict:Dictionary
@export var skillUnlockedDataList:Array[String]
@export var skillUnlockedDataDict:Dictionary

func init_as_new() -> void:
	heroDataList.append(add_hero_to_starting_list("PALADIN"))
	heroDataList.append(add_hero_to_starting_list("BERSERKER"))
	heroDataList.append(add_hero_to_starting_list("ASSASSIN"))
	heroDataList.append(add_hero_to_starting_list("GENERIC_HERO"))

func add_hero_to_starting_list(heroId:String):
	var heroData:PlayerHeroData = PlayerHeroData.new()
	heroData.init(heroId, 0)
	return heroData

func init():
	for heroData in heroDataList:
		heroDataDict[heroData.charId] = heroData

func clear():
	currentXP = 0
	totalXP = 0
	for heroData in heroDataList:
		heroData.reset()
	heroDataList[0].unlock()
	skillUnlockedDataDict.clear()
	skillUnlockedDataList.clear()
	
func unlockHero(charId:String):
	heroDataDict[charId].unlock()

func isSkillUnlocked(skillId:String):
	return skillUnlockedDataDict.has(skillId)

func unlockSkill(skillId:String):
	skillUnlockedDataDict[skillId] = true
	skillUnlockedDataList.append(skillId)

func get_unlocked_skills()->Array[String]:
	return skillUnlockedDataList

# Hero XP and Levels
func get_hero_prev_xp(charId:String):
	return heroDataDict[charId].get_prev_xp_for_next_level()

func get_hero_xp_for_next_level(charId:String):
	return heroDataDict[charId].get_xp_for_next_level()

func add_hero_xp(charId:String, xpToAdd:int):
	heroDataDict[charId].add_xp(xpToAdd)

func set_hero_xp_as_seen(charId:String):
	heroDataDict[charId].set_hero_xp_as_seen()

func get_hero_level(charId:String):
	return heroDataDict[charId].get_level()
