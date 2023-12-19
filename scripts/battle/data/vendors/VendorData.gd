class_name VendorData

var id:String
var displayName:String
var description:String
var path:String
var tintColor:String
var oneTimePurchaseOnly:bool
var onlyUniquePurchases:bool
var abilities:Array
var specials:Array
var passives:Array
var items:Array
var runes:Array
var numItemsShown:int

func _init(dataJS):
	id = dataJS["id"]
	displayName = dataJS["name"]
	description = dataJS["description"]
	path = dataJS["path"]
	tintColor = Utils.get_data_from_json(dataJS, "tintColor", "")
	numItemsShown = Utils.get_data_from_json(dataJS, "numItemsShown", 1)
	oneTimePurchaseOnly = Utils.get_data_from_json(dataJS, "oneTimePurchaseOnly", false)
	onlyUniquePurchases = Utils.get_data_from_json(dataJS, "onlyUniquePurchases", false)

	if dataJS.has("abilities"):
		abilities = dataJS["abilities"]

	if dataJS.has("specials"):
		specials = dataJS["specials"]

	if dataJS.has("passives"):
		passives = dataJS["passives"]

	if dataJS.has("items"):
		items = dataJS["items"]

	if dataJS.has("runes"):
		runes = dataJS["runes"]
