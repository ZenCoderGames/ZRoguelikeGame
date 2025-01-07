class_name DungeonModifierData

var id:String
var name:String
var description:String
var isPositive:bool
var statModifierDataList:Array
var passiveId:String
var dungeonStartSouls:int
var vendorCostMultiplier:float
var spawnEquipment:bool
var spawnConsumable:bool
var spawnAdditionalItem:bool

func _init(dataJS):
	id = Utils.get_data_from_json(dataJS, "id", "INVALID_ID")
	name = Utils.get_data_from_json(dataJS, "name", "INVALID_DESCRIPTION")
	description = Utils.get_data_from_json(dataJS, "description", "INVALID_DESCRIPTION")
	isPositive = Utils.get_data_from_json(dataJS, "isPositive", false)

	if dataJS.has("statModifiers"):
		var statModifierDataJSList = dataJS["statModifiers"]
		for statModifierDataJS in statModifierDataJSList:
			statModifierDataList.append(StatModifierData.new(statModifierDataJS))
	
	passiveId = Utils.get_data_from_json(dataJS, "passiveId", "")
	dungeonStartSouls = Utils.get_data_from_json(dataJS, "dungeonStartSouls", 0)
	vendorCostMultiplier = Utils.get_data_from_json(dataJS, "vendorCostMultiplier", 0.0)
	spawnEquipment = Utils.get_data_from_json(dataJS, "spawnEquipment", false)
	spawnConsumable = Utils.get_data_from_json(dataJS, "spawnConsumable", false)
	spawnAdditionalItem = Utils.get_data_from_json(dataJS, "spawnAdditionalItem", false)

func get_display_name():
	return name

func get_description():
	return description
