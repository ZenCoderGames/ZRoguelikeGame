extends Camera2D

func _unhandled_input(event: InputEvent) -> void:
	_zoom_input(event)
	_move_input(event)

func _zoom_input(event: InputEvent):
	var zoom:float = 0
	
	if event.is_action_pressed(Constants.INPUT_CAM_ZOOM_OUT):
		zoom = 0.5
	elif event.is_action_pressed(Constants.INPUT_CAM_ZOOM_IN):
		zoom = -0.5

	self.zoom.x += zoom
	self.zoom.y += zoom

func _move_input(event: InputEvent):
	var x:int = 0
	var y:int = 0
	
	if event.is_action_pressed(Constants.INPUT_CAM_MOVE_LEFT):
		x = -1
	elif event.is_action_pressed(Constants.INPUT_CAM_MOVE_RIGHT):
		x = 1
	elif event.is_action_pressed(Constants.INPUT_CAM_MOVE_UP):
		y = -1
	elif event.is_action_pressed(Constants.INPUT_CAM_MOVE_DOWN):
		y = 1

	self.position += Vector2(x * 20, y * 20)
