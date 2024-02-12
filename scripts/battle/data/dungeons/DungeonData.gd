class_name DungeonData

var numRooms:int
var roomMinRows:int
var roomMaxRows:int
var roomMinCols:int
var roomMaxCols:int
var obstacleChance:float
var minObstacles:int
var maxObstacles:int
var itemCountMin:int
var itemCountMax:int
var itemHeighestTier:int
var enemyDifficultyHighestTier:int
var enemyMinCostPerRoom:int = 5
var enemyExtraCostForSingleRoom:int = 5
var enemyScalingCostPerRoom:int = 3
var customRoomList:Array

func _init(dataJS):
	numRooms = Utils.get_data_from_json(dataJS, "numRooms", 3)
	roomMinRows = Utils.get_data_from_json(dataJS, "roomMinRows", 3)
	roomMaxRows = Utils.get_data_from_json(dataJS, "roomMaxRows", 5)
	roomMinCols = Utils.get_data_from_json(dataJS, "roomMinCols", 3)
	roomMaxCols = Utils.get_data_from_json(dataJS, "roomMaxCols", 5)
	obstacleChance = Utils.get_data_from_json(dataJS, "obstacleChance", 0)
	minObstacles = Utils.get_data_from_json(dataJS, "minObstacles", 0)
	maxObstacles = Utils.get_data_from_json(dataJS, "maxObstacles", 0)
	itemCountMin = Utils.get_data_from_json(dataJS, "itemCountMin", 2)
	itemCountMax = Utils.get_data_from_json(dataJS, "itemCountMax", 4)
	itemHeighestTier = Utils.get_data_from_json(dataJS, "itemHeighestTier", 3)
	enemyDifficultyHighestTier = Utils.get_data_from_json(dataJS, "enemyDifficultyHighestTier", 1)
	enemyMinCostPerRoom = Utils.get_data_from_json(dataJS, "enemyMinCostPerRoom", 5)
	enemyExtraCostForSingleRoom = Utils.get_data_from_json(dataJS, "enemyExtraCostForSingleRoom", 5)
	enemyScalingCostPerRoom = Utils.get_data_from_json(dataJS, "enemyScalingCostPerRoom", 3)
	if dataJS.has("customRooms"):
		var customRoomJSList = dataJS["customRooms"]
		for customRoomJS in customRoomJSList:
			var customRoomData:DungeonCustomRoomData = DungeonCustomRoomData.new(customRoomJS)
			customRoomList.append(customRoomData)