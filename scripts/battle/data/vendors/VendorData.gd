class_name VendorData

var id:String
var displayName:String
var description:String
var path:String
var disable:bool
var perks:Array

func _init(itemDataJS):
	id = itemDataJS["id"]
	displayName = itemDataJS["name"]
	description = itemDataJS["description"]
	path = itemDataJS["path"]
	disable = Utils.get_data_from_json(itemDataJS, "disable", false)
	var perkDataJSList:Array = itemDataJS["perks"]
	for perkDataJS in perkDataJSList:
		var newAbilityData = AbilityData.new(perkDataJS)
		perks.append(newAbilityData)