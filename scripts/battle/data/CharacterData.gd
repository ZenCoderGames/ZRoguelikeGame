class_name CharacterData

var id
var displayName
var path
var maxHealth
var damage
var maxStamina

func _init(dataJS):
	id = dataJS["id"]
	displayName = dataJS["displayName"]
	path = dataJS["path"]
	maxHealth = dataJS["maxHealth"]
	damage = dataJS["damage"]
	maxStamina = dataJS["maxStamina"]
