extends Resource
class_name PlayerData

@export var currentXP:int
@export var totalXP:int
@export var heroDataList:Array[PlayerHeroData]
var heroDataDict:Dictionary
@export var skillDataDict:Dictionary

func init():
	for heroData in heroDataList:
		heroDataDict[heroData.charId] = heroData

func clear():
	currentXP = 0
	totalXP = 0
	for heroData in heroDataList:
		heroData.clear()
	heroDataList[0].unlock()
	skillDataDict.clear()
	
func unlockHero(charId:String):
	heroDataDict[charId].unlock()

func isSkillUnlocked(skillId:String):
	return skillDataDict.has(skillId)

func unlockSkill(skillId:String):
	skillDataDict[skillId] = true
