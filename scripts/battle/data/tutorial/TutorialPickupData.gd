class_name TutorialPickupData

"""{
	"id": "TUTORIAL_MOVEMENT",
	"name": "Tutorial: Movement",
	"description": "Use WASD or the ARROW keys to move"
}"""

var id:String
var name:String
var description:String

func _init(tutorialDataJS):
	id = tutorialDataJS["id"]
	name = tutorialDataJS["name"]
	description = tutorialDataJS["description"]