extends Resource
class_name PlayerData

@export var currentXP:int
@export var totalXP:int
@export var heroDataList:Array[PlayerHeroData]
@export var heroDataDict:Dictionary

func init():
	for heroData in heroDataList:
		heroDataDict[heroData.charId] = heroData

func clear():
	currentXP = 0
	totalXP = 0
	for heroData in heroDataList:
		heroData.clear()
	heroDataList[0].unlock()
	
func unlockHero(charId:String):
	heroDataDict[charId].unlock()
