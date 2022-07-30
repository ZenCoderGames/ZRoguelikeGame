class_name CharacterData

var id:String
var displayName:String
var path:String
var maxHealth:int
var damage:int
var maxStamina:int
var actionDataList:Array
var disable:bool

func _init(dataJS):
	id = dataJS["id"]
	displayName = dataJS["displayName"]
	path = dataJS["path"]
	maxHealth = dataJS["maxHealth"]
	damage = dataJS["damage"]
	maxStamina = dataJS["maxStamina"]
	actionDataList = dataJS["actions"]
	if dataJS.has("disable"):
		disable =  dataJS["disable"]
