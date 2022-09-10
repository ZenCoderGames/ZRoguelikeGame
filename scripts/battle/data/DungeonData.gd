extends Node

class_name DungeonData

var numRooms:int
var roomMinRows:int
var roomMaxRows:int
var roomMinCols:int
var roomMaxCols:int
var itemCountMin:int
var itemCountMax:int
var itemHeighestTier:int

func _init(dataJS):
	numRooms = Utils.get_data_from_json(dataJS, "numRooms", 3)
	roomMinRows = Utils.get_data_from_json(dataJS, "roomMinRows", 3)
	roomMaxRows = Utils.get_data_from_json(dataJS, "roomMaxRows", 5)
	roomMinCols = Utils.get_data_from_json(dataJS, "roomMinCols", 3)
	roomMaxCols = Utils.get_data_from_json(dataJS, "roomMaxCols", 5)
	itemCountMin = Utils.get_data_from_json(dataJS, "itemCountMin", 2)
	itemCountMax = Utils.get_data_from_json(dataJS, "itemCountMax", 4)
	itemHeighestTier = Utils.get_data_from_json(dataJS, "itemHeighestTier", 3)