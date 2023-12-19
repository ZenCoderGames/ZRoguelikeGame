extends TextureRect

class_name ResourceSlotUIItem

@onready var innerCircle:TextureRect = $"%InnerCircle"

func _ready():
	clear()

func set_filled():
	innerCircle.self_modulate = Color.GREEN
	
func set_empty():
	innerCircle.self_modulate = Color.WHITE

func clear():
	self.self_modulate = Color.TRANSPARENT
	innerCircle.self_modulate = Color.WHITE
