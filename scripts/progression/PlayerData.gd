extends Resource
class_name PlayerData

@export var currentXP:int
@export var totalXP:int
@export var heroDataList:Array[PlayerHeroData]
var heroDataDict:Dictionary
@export var skillUnlockedDataList:Array[String]
@export var skillUnlockedDataDict:Dictionary

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
