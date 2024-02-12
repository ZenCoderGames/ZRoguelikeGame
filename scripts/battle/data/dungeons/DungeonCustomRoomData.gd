class_name DungeonCustomRoomData

var tutorialPickUps:Array
var encounterId:String
var itemId:String
var vendorId:String

func _init(dataJS):
	var tutorialPickupList = dataJS["tutorialPickups"]
	for tutorialPickup in tutorialPickupList:
		tutorialPickUps.append(tutorialPickup)

	encounterId = Utils.get_data_from_json(dataJS, "encounterId", "")
	itemId = Utils.get_data_from_json(dataJS, "itemId", "")
	vendorId = Utils.get_data_from_json(dataJS, "vendorId", "")
